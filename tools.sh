#!/bin/sh
set -e
cmd="$1"
shift

docker build -q -t tools --target tools .
docker run --rm -it -p 127.0.0.1:7780:7780 \
    -v /etc/resolv.conf:/resolv.conf:ro -v .:/mnt \
    tools "/$cmd" "$@"
