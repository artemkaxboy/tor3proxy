# 3proxy docker

FROM alpine:latest as builder

ARG VERSION=0.8.12

RUN apk add --update alpine-sdk wget bash && \
    cd / && \
    wget -q  https://github.com/z3APA3A/3proxy/archive/${VERSION}.tar.gz && \
    tar -xf ${VERSION}.tar.gz && \
    mv 3proxy-${VERSION} 3proxy-src && \
    cd 3proxy-src && \
    make -f Makefile.Linux

# STEP 2

FROM alpine
MAINTAINER Artem Kolin <artemkaxboy@gmail.com>

RUN mkdir /etc/3proxy/

COPY --from=builder /3proxy-src/src/3proxy /etc/3proxy/

# Install tor and privoxy
#apk --no-cache --no-progress add bash curl privoxy shadow tini tor && \
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl shadow tini tor && \
    chmod -R +x /etc/3proxy/3proxy && \
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

VOLUME ["/etc/tor", "/var/lib/tor"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/torproxy.sh"]
