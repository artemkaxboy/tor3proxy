#!/usr/bin/env bash

function error() {
  echo "$1"
  exit 1
}

#set -e
#curl -v --socks5 127.0.0.1:8010 --proxy-user user:password -L http://jsonip.com

URL="http://jsonip.com"
DIRECT_IP=$(curl -sL "$URL" | grep -Po '"ip":"\K[^"]*') || error "failed"
PROXY_IP=$(curl -sL --socks5 127.0.0.1:1080 "$URL" | grep -Po '"ip":"\K[^"]*')

echo "$DIRECT_IP"
echo "$PROXY_IP"
