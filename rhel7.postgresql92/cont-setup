#!/bin/bash

# fix owner for data directory
mkdir -p /var/lib/pgsql
chmod 0700 /var/lib/pgsql
chown -R postgres:postgres /var/lib/pgsql
restorecon -R /var/lib/pgsql

