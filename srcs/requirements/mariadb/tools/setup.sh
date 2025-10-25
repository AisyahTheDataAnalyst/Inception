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
    
    # Set root password and create database with proper user permissions
    mysql -uroot <<-EOSQL
        -- Set root password
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
        
        -- Create database
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        
        -- Create user with access from any host (%)
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        
        -- Grant privileges from any host
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        
        -- Also create localhost user for completeness
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
        
        -- Apply changes
        FLUSH PRIVILEGES;
EOSQL
    
    # Stop temporary server
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    sleep 3
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql