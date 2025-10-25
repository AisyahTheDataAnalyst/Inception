#!/bin/bash
set -e

# Initialize MySQL data directory if empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MySQL data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL temporarily for setup
echo "Starting MySQL for initial setup..."
mysqld_safe --datadir=/var/lib/mysql --nowatch &

# Wait for MySQL to start
echo "Waiting for MySQL to start..."
until mysqladmin ping >/dev/null 2>&1; do
    sleep 1
done

# Secure installation and create database/user
echo "Configuring MySQL..."
mysql -uroot <<-EOSQL
    -- Set root password
    UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
    
    -- Remove anonymous users
    DELETE FROM mysql.user WHERE User='';
    
    -- Remove remote root access
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    
    -- Drop test database
    DROP DATABASE IF EXISTS test;
    
    -- Create application database
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    
    -- Create application user
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    
    -- Grant privileges
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    
    -- Apply changes
    FLUSH PRIVILEGES;
EOSQL

echo "MySQL configuration completed."

# Stop the temporary MySQL instance
mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown

# Start MySQL in foreground (proper PID 1)
echo "Starting MySQL in foreground..."
exec mysqld --datadir=/var/lib/mysql --user=mysql