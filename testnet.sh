#!/usr/bin/env bash
set -e

docker build -t testnet .
docker run --rm -it -p 8545:8545 -p 30303:30303 --name testnet-01 testnet
