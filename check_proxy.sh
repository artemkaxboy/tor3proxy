#!/usr/bin/env bash

curl -v --socks5 127.0.0.1:8010 --proxy-user user:password -L http://jsonip.com
