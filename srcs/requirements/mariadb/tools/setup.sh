#!/bin/bash
set -e

echo "Starting MariaDB setup..."

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    echo "Starting temporary MariaDB for setup..."
    mysqld_safe --datadir=/var/lib/mysql --nowatch &
    
    # Wait for server to start
    echo "Waiting for MariaDB to start..."
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 2
    done
    
    echo "Configuring MariaDB users and database..."
    # Set root password and create database with proper user permissions
    mysql -uroot <<-EOSQL
        -- Set root password
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
        
        -- Delete anonymous users
        DELETE FROM mysql.user WHERE User='';
        
        -- Create database (THIS WAS MISSING!)
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        
        -- Create user with access from any host
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        
        -- Grant privileges
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        
        -- Apply changes
        FLUSH PRIVILEGES;
EOSQL
    
    echo "Stopping temporary MariaDB..."
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    sleep 5
else
    echo "MariaDB already initialized, checking if database exists..."
    # Start temporary to check/create database if missing
    mysqld_safe --datadir=/var/lib/mysql --nowatch &
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 2
    done
    
    # Create database if it doesn't exist
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    sleep 3
fi

echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql