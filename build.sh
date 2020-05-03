#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SRC="${DIR}/src"
DATADIR="${DIR}/testnet-datadir"
CONTRACT_OWNER="0xa6e96ac2c446f89699479fbb1bf0de93719e2105"

rm -fr $DATADIR
mkdir -p $DATADIR
cp -r "${SRC}/keystore" $DATADIR
rm -fr "${SRC}/lif-dev/build"

# Initialize blockhain
geth --datadir $DATADIR init "${SRC}/genesis.json" 2>/dev/null

# DevLif
## Compile
cd "${SRC}/lif-dev"
solc --combined-json abi,bin -o build LifDev.sol --overwrite
echo "var combined=$(cat build/combined.json)" > build/combined.js
## Deploy
geth --datadir $DATADIR js "${SRC}/lif-dev/deploy.js" --unlock $CONTRACT_OWNER --password "${SRC}/password"

exit 1
###
### Stuck here
###

## Distribute DevLif to accounts
geth --datadir $DATADIR js "${SRC}/lif-dev/distribute.js" 2>/dev/null

# org.id
## Compile
git clone https://github.com/windingtree/org.id.git ${DIR}/src/org.id
cd ${DIR}/src/org.id && npm i && npm link
## Deploy
orgid-tools --network development cmd=deploy name=OrgId from=${CONTRACT_OWNER} initMethod=initialize initArgs=${CONTRACT_OWNER},${LIF_ADDRESS}
