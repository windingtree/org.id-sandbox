#!/usr/bin/env sh
set -e

# Setup config files
CONFIG_FILE3=/arbor-backend/modules/config/lib/3rd-party.json
ORGID_ADDRESS="$(jq -r '.contract.proxy' '/org.id/.openzeppelin/private-OrgId.json')"
DIRECTORY_INDEX_ADDRESS="$(jq -r '.contract.proxy' '/org.id-directories/.openzeppelin/private-DirectoryIndex.json')"
sed -i "s/ORGID_ADDRESS/$ORGID_ADDRESS/g" "$CONFIG_FILE3"
sed -i "s/SENDGRID_API_KEY/$SENDGRID_API_KEY/g" "$CONFIG_FILE3"
sed -i "s/ETHERSCAN_KEY/$ETHERSCAN_KEY/g" "$CONFIG_FILE3"
sed -i "s/DEFI_PULSE_KEY/$DEFI_PULSE_KEY/g" "$CONFIG_FILE3"
sed -i "s/STRIPE_SECRET/$STRIPE_SECRET/g" "$CONFIG_FILE3"
sed -i "s/STRIPE_HOOK_SECRET/$STRIPE_HOOK_SECRET/g" "$CONFIG_FILE3"
sed -i "s/STRIPE_HOOK_SECRET_TEST/$STRIPE_HOOK_SECRET_TEST/g" "$CONFIG_FILE3"
sed -i "s/DIRECTORY_INDEX_ADDRESS/$DIRECTORY_INDEX_ADDRESS/g" "$CONFIG_FILE3"

# parameters
# @todo Move params to build arguments
MYSQL_ROOT_PWD=${MYSQL_ROOT_PWD:-"111111"}
MYSQL_USER=${MYSQL_USER:-"arbor"}
MYSQL_USER_PWD=${MYSQL_USER_PWD:-"111111"}
MYSQL_USER_DB=${MYSQL_USER_DB:-"arbor"}

if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
fi

if [ -d /var/lib/mysql/${MYSQL_USER_DB} ]; then
	echo '[i] MySQL directory already present, skipping creation'
else
	echo "[i] MySQL data directory not found, creating initial DBs"

	# init database
	echo 'Initializing database'
	mysql_install_db --user=root --datadir=/var/lib/mysql > /dev/null
	echo 'Database initialized'

	# create temp file
	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
	    return 1
	fi

	# save sql
	echo "[i] Create temp file: $tfile"
	cat << EOF > $tfile
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PWD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PWD' WITH GRANT OPTION;
EOF

	# Create new database
	if [ "$MYSQL_USER_DB" != "" ]; then
		echo "[i] Creating database: $MYSQL_USER_DB"
		echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_USER_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

		# set new User and Password
		if [ "$MYSQL_USER" != "" ] && [ "$MYSQL_USER_PWD" != "" ]; then
		    echo "[i] Creating user: $MYSQL_USER with password $MYSQL_USER_PWD"
		    echo "GRANT ALL ON \`$MYSQL_USER_DB\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PWD';" >> $tfile
		fi
	else
		# don`t need to create new database,Set new User to control all database.
		if [ "$MYSQL_USER" != "" ] && [ "$MYSQL_USER_PWD" != "" ]; then
		    echo "[i] Creating user: $MYSQL_USER with password $MYSQL_USER_PWD"
		    echo "GRANT ALL ON *.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PWD';" >> $tfile
		fi
	fi

	echo 'FLUSH PRIVILEGES;' >> $tfile

	# run sql in tempfile
	echo "[i] run tempfile: $tfile"
    echo "====================================================================="
    cat $tfile
    echo "====================================================================="
	/usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile
	rm -f $tfile
fi

exec /usr/bin/mysqld --user=root --console &

sleep 5

# Setup database tables and data
echo "[i] Starting database migration script"
npx sequelize-cli db:migrate --url "mysql:$MYSQL_USER:$MYSQL_USER_PWD@0.0.0.0:3306/$MYSQL_USER_DB"
