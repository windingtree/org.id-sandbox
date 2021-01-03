#!/usr/bin/env sh
set -e

# Working dir
cd /org.id-directories
rm -f /org.id-directories/.openzeppelin/private*.json # remove old deployment configs

# Build contracts
npx truffle compile

# Deploy Lif token
npx truffle --network development \
    exec ./setup/lif.js \
    from=0x28D9F2192F8CeC7724c6C71e3048D03372F8d5D0
LIF_ADDRESS="$(jq -r '.address' '/org.id-directories/lif.json')"

# Distribute Lif tokens
npx tools --network development \
    cmd=task \
    file=/org.id-directories/setup/setup-task.json \
    params=LIF_ADDRESS:$LIF_ADDRESS \
    params=FROM:0x28D9F2192F8CeC7724c6C71e3048D03372F8d5D0 \
    params=LIFS:1000000000000000000000000 \
    params=HOLDER1:0x5aafeD2ea1ca9EA4d80664b3260126058B46Da20 \
    params=HOLDER2:0xc5e2c01C8FdB4B090aaB30c81BeaB0BC230D0F82 \
    params=HOLDER3:0x5a4D34eCD771DA77996a600F1Cd9Ec720ece643e \
    params=HOLDER4:0x41BF14dEB94C32FF85FD588672A75a559690C783 \
    params=HOLDER5:0x35B547C0d8CaE443D7aD7310CcE16755baB9cF22 \
    params=HOLDER6:0xb0460F188FCDE04269401c755978f78Cd44e474F \
    params=HOLDER7:0x4b6Aa7b3Aec71cE0922056AD19d60414655a5642 \
    params=HOLDER8:0x06f2b88ed6E64B95Fe7d20948Db2c4109cDD5e89 \
    params=HOLDER9:0xB86cc04D6dBd61E4e9E872D129C8F51f1afEDE63 \
    params=HOLDER10:0xE45020B420144307A86C33e1C35377EAE81AB471 \
    params=HOLDER11:0x37A376EA0823AdbD6Ee0B82f02856d1742734226 \
    params=HOLDER12:0xb6Be0C762d4464cF51A48EbEA2D0da8c832Da459 \
    params=HOLDER13:0xC815A089883b7B0b8821CdC4EE91eB8DC45def61 \
    params=HOLDER14:0x27Beec4FA99F73d3eE659C38F9a2F89b1bf43d6B \
    params=HOLDER15:0xeb83D7c63d4224790A635d9e198CFBbD6F63D9C5 \
    params=HOLDER16:0x9EFF1F1c235B20037EA8318a4b14Bf1d5F1F92d0 \
    params=HOLDER17:0xa6e96AC2C446F89699479FBb1bf0DE93719E2105 \
    params=HOLDER18:0x57416D88bf105A955e39b615a693A42F77b3e570 \
    params=HOLDER19:0x0CfF2c6E3D5e5a8A977089D5C0f5AC71Ca6dF67B

# Deploy Arbitrator
npx truffle --network development \
    exec ./setup/arbitrator.js \
    governor=0x28D9F2192F8CeC7724c6C71e3048D03372F8d5D0
ARBITRATOR_ADDRESS="$(jq -r '.address' '/org.id-directories/arbitrator.json')"
ORGID_ADDRESS="$(jq -r '.contract.proxy' '/org.id/.openzeppelin/private-OrgId.json')"

# Deploy Directory Index
npx tools --network development \
    cmd=task \
    file=/org.id-directories/setup/setup-directories-task.json \
    params=ORGID_ADDRESS:$ORGID_ADDRESS \
    params=FROM:0x28D9F2192F8CeC7724c6C71e3048D03372F8d5D0 \
    params=LIF_ADDRESS:$LIF_ADDRESS \
    params=ARBITRATOR_ADDRESS:$ARBITRATOR_ADDRESS