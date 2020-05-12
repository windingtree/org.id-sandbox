#!/usr/bin/env sh
set -e

geth \
    --datadir /org.id-testnet \
    init /org.id-testnet/genesis.json