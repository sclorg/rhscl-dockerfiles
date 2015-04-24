function mysql_usage() {
	if [ $# == 2 ]; then
		echo "error: $1"
	fi
	echo "You may optionally specify the following environment variables:"
	echo "  \$MYSQL_ROOT_PASSWORD (regex: '$mysql_password_regex')"
	echo "  \$MYSQL_USER (regex: '$mysql_identifier_regex')"
	echo "  \$MYSQL_PASSWORD (regex: '$mysql_password_regex')"
	echo "  \$MYSQL_DATABASE (regex: '$mysql_identifier_regex')"
	exit 1
}

function mysql_initdb_base() {


	mysqladmin $admin_flags -f drop test

	if [ -v MYSQL_ROOT_PASSWORD ]; then

	        echo "Initializing authentication for root"

		[[ "$MYSQL_ROOT_PASSWORD" =~ $mysql_password_regex ]] || mysql_usage "Invalid root password"
		mysql $mysql_flags <<-EOSQL
			GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		EOSQL
	fi

	if [[ -v MYSQL_USER || -v MYSQL_PASSWORD || -v MYSQL_DATABASE ]]; then
		# if any of them is specified, all must be specified
		if [[ -v MYSQL_USER && -v MYSQL_PASSWORD && -v MYSQL_DATABASE ]]; then
			# validate user input
			[[ "$MYSQL_USER"     =~ $mysql_identifier_regex ]] || mysql_usage "Invalid MySQL username"
			[ ${#MYSQL_USER} -le 16 ] || mysql_usage "MySQL username too long (maximum 16 characters)"
			[[ "$MYSQL_PASSWORD" =~ $mysql_password_regex   ]] || mysql_usage "Invalid password"
			[[ "$MYSQL_DATABASE" =~ $mysql_identifier_regex ]] || mysql_usage "Invalid database name"
			[ ${#MYSQL_DATABASE} -le 64 ] || mysql_usage "Database name too long (maximum 64 characters)"

		        echo "Initializing authentication for user $MYSQL_USER and database $MYSQL_DATABASE"

			mysql $mysql_flags <<EOSQL
				CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
				GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' ;
				FLUSH PRIVILEGES ;
EOSQL
		else
			mysql_usage "All of MYSQL_USER, MYSQL_PASSWORD and MYSQL_DATABASE must be specified if any of it is."
		fi
	fi
}

mysql_initdb_base

unset -f mysql_initdb_base mysql_usage
unset MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE MYSQL_ROOT_PASSWORD
