#!/usr/bin/env sh
set -e

# start geth node
$DATADIR/start.sh &

# Working dir
cd /org.id

# Start Arbor
/arbor-backend/start-arbor.sh &

sleep 35

# Get configs
ORGID_ADDRESS="$(jq -r '.contract.proxy' '/org.id/.openzeppelin/private-OrgId.json')"

# Deploy ORGiDs
npx tools --network development \
    cmd=task \
    file=/org.id/setup/setup-legal-task.json \
    params=ORGID_ADDRESS:$ORGID_ADDRESS

npx tools --network development \
    cmd=task \
    file=/org.id/setup/setup-units-task.json \
    params=ORGID_ADDRESS:$ORGID_ADDRESS
