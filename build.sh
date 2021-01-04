#!/usr/bin/env bash
set -e

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

docker build \
    --build-arg DATADIR=$DATADIR \
    --build-arg SENDGRID_API_KEY=$SENDGRID_API_KEY \
    --build-arg ETHERSCAN_KEY=$ETHERSCAN_KEY \
    --build-arg DEFI_PULSE_KEY=$DEFI_PULSE_KEY \
    --build-arg STRIPE_SECRET=$STRIPE_SECRET \
    --build-arg STRIPE_HOOK_SECRET=$STRIPE_HOOK_SECRET \
    --build-arg STRIPE_HOOK_SECRET_TEST=$STRIPE_HOOK_SECRET_TEST \
    -t windingtree/org.id-sandbox \
    .
