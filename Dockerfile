# 3proxy docker

FROM alpine:3.10 as builder
LABEL maintainer="Artem Kolin <artemkaxboy@gmail.com>"

RUN apk add --no-cache --no-progress alpine-sdk git bash && \
    git clone https://github.com/artemkaxboy/3proxy.git /3proxy && \
    make -f /3proxy/Makefile.Linux -C /3proxy

# STEP 2

FROM artemkaxboy/baseimage:app-0.1
LABEL maintainer="Artem Kolin <artemkaxboy@gmail.com>"

RUN mkdir /etc/3proxy/

COPY --from=builder /3proxy/bin/3proxy /etc/3proxy/

RUN apk --no-cache --no-progress add bash curl shadow tini tor && \
    chmod +x /etc/3proxy/3proxy && \
    mkdir /etc/3proxy/cfg && \
    mkdir -p /etc/tor/run && \
    chown -Rh tor. /var/lib/tor /etc/tor/run && \
    chmod 0750 /etc/tor/run && \
    rm -rf /tmp/*

COPY torrc /etc/tor/
COPY torproxy.sh /usr/bin/
COPY 3proxy.cfg /etc/3proxy/cfg/

EXPOSE 1080 5353/udp 9040 9050

HEALTHCHECK --interval=60s --timeout=15s --start-period=90s \
            CMD curl --socks5-hostname localhost:9050 -L 'https://api.ipify.org'

VOLUME ["/etc/tor", "/var/lib/tor", "/data"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/torproxy.sh"]
