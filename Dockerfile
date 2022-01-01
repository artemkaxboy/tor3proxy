# 3proxy docker

FROM alpine:3.15 as builder

RUN apk add --no-cache --no-progress alpine-sdk git && \
    git clone https://github.com/artemkaxboy/3proxy.git /3proxy && \
    make -f /3proxy/Makefile.Linux -C /3proxy

# STEP 2

FROM alpine:3.15

RUN mkdir /etc/3proxy

COPY --from=builder /3proxy/bin/3proxy /etc/3proxy/

RUN apk --no-cache --no-progress add curl shadow tini tor bash tzdata && \
    chmod +x /etc/3proxy/3proxy && \
    mkdir /etc/3proxy/cfg && \
    mkdir -p /etc/tor/run && \
    chown -Rh tor. /var/lib/tor /etc/tor/run && \
    chmod 0750 /etc/tor/run && \
    rm -rf /tmp/*

ARG VERSION=DEBUG
ARG REVISION=LOCAL
ARG REF_NAME
ARG CREATED

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.created=${CREATED}
LABEL org.opencontainers.image.authors="artemkaxboy@gmail.com"
LABEL org.opencontainers.image.url="https://github.com/artemkaxboy/tor3proxy"
LABEL org.opencontainers.image.documentation="https://github.com/artemkaxboy/tor3proxy"
LABEL org.opencontainers.image.source="https://github.com/artemkaxboy/tor3proxy"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.revision=${REVISION}
LABEL org.opencontainers.image.vendor="artemkaxboy@gmail.com"
LABEL org.opencontainers.image.licenses="GNU General Public License v3.0"
LABEL org.opencontainers.image.ref.name=${REF_NAME}
LABEL org.opencontainers.image.title="tor3proxy"
LABEL org.opencontainers.image.description="TOR network proxy connector"

ENV VERSION=${VERSION}
ENV REVISION=${REVISION}
ENV CREATED=${CREATED}

COPY torrc /etc/tor/
COPY torproxy.sh /usr/bin/
COPY 3proxy.cfg /etc/3proxy/cfg/

EXPOSE 1080 5353/udp 9040 9050

HEALTHCHECK --interval=60s --timeout=15s --start-period=90s \
            CMD curl --socks5-hostname localhost:9050 -L 'https://api.ipify.org'

VOLUME ["/etc/tor", "/var/lib/tor", "/data"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/torproxy.sh"]
