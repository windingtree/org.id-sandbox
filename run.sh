#!/usr/bin/env bash
set -e

docker run --rm -it \
    -p 8545:8545 \
    -p 8546:8546 \
    -p 30303:30303 \
    --name org.id-sandbox windingtree/org.id-sandbox
