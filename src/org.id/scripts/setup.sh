#!/usr/bin/env sh
set -e

rm -f /org.id/.openzeppelin/private*.json # remove old deployment configs
cd /org.id
npx tools --network development \
    cmd=task \
    file=/org.id/setup/setup-task.json \
    params=FROM:0x28D9F2192F8CeC7724c6C71e3048D03372F8d5D0
