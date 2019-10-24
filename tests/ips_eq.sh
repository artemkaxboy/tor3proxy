#!/bin/bash

set -e

cd "$(dirname "$0")" || exit

# does not work in quotes
# shellcheck disable=SC2086
ip1=$(./get_ip.sh ${1//[=,]/ })

# does not work in quotes
# shellcheck disable=SC2086
ip2=$(./get_ip.sh ${2//[=,]/ })

if [[ "$ip1" != "$ip2" ]] ; then
  exit 12
fi
