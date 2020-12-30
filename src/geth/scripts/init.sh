#!/usr/bin/env sh
set -e

geth --datadir $DATADIR \
    init $DATADIR/genesis.json
