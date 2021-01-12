#!/usr/bin/env bash
set -e

docker run --rm -it \
    -p 8545:8545 \
    -p 8546:8546 \
    -p 30303:30303 \
    -p 3306:3306 \
    -p 3333:3333 \
    -p 4444:4444 \
    -p 9001:9001 \
    --name org.id-sandbox windingtree/org.id-sandbox
