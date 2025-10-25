#!/bin/bash
set -e

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start temporary server for initial setup
    mysqld_safe --datadir=/var/lib/mysql &
    
    # Wait for server to start
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
    
    # Set root password and create database
    mysql -uroot <<-EOSQL
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL
    
    # Stop temporary server
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    sleep 3
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql