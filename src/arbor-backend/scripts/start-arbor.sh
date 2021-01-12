#!/usr/bin/env sh
set -e

# Start SQL server
/var/lib/mysql/start-mysql.sh &

# Start JSON files server
/org.id/setup/serve-data.sh &

sleep 30

# Start the Arbor
# @todo Use pm2 manager
node /arbor-backend/server.js
