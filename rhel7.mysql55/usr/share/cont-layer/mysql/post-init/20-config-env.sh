# warning: this is not recommended way of changing the configuration
# the recomended way is to provide own config file

mysql_config_from_env() {
	env_prefix=$1
	config_file=$2

	# end here if no env vars defined with the prefix
	set | grep -e "^${env_prefix}" &>/dev/null || return

	touch $config_file

	# all variables are specific to the daemon
	echo '[mysqld]' >>$config_file

	# take env variables without prefix as options
	set | grep -e "^${env_prefix}" | sed -e "s/^${env_prefix}//g" >>$config_file
}

mysql_config_from_env MYSQL_CONFIG_ /etc/my.cnf.d/generated.cnf
unset -f mysql_config_from_env
