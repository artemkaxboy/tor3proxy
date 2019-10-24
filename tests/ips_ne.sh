#!/bin/bash

cd "$(dirname "$0")" || exit

# shellcheck disable=SC2091
./ips_eq.sh "$@"

if [[ $? != 12 ]] ; then
  exit 1
fi
