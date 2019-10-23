#!/bin/bash

function error() {
  echo "$1"
  exit 1
}

PROXY=
USER=

if [[ -n "$1" ]]; then
  for (( i=1; i<=$#; i++ )) ; do
    case "${!i}" in
    --socks5)
      i=$(("$i"+1))
      PROXY=" --socks5 127.0.0.1:${!i}"
      ;;
    --user)
      i=$(("$i"+1))
      USER=" --proxy-user ${!i}"
      ;;
    esac
  done
fi

URL="http://jsonip.com"
CURL="curl -sL$PROXY$USER $URL"

#DIRECT_IP=$(curl -sL "$URL" | grep -Po '"ip":"\K[^"]*') || error "failed"
#PROXY_IP=$(curl -sL --socks5 127.0.0.1:1080 "$URL" | grep -Po '"ip":"\K[^"]*')

echo "$CURL"
# shellcheck disable=SC2005
echo "$($CURL | grep -Po '"ip":"\K[^"]*' || error "failed to perform request: $CURL")"
