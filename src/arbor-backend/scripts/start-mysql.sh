#!/usr/bin/env sh
set -e

# Start MySQL
exec /usr/bin/mysqld --user=root --console
