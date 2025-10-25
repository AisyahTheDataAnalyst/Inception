#!/bin/bash
set -e

echo "Starting MariaDB setup..."

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    
    echo "Starting temporary MariaDB for setup..."
    mysqld_safe --datadir=/var/lib/mysql --nowatch &
    
    # Wait for server to start
    echo "Waiting for MariaDB to start..."
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 2
    done
    
    echo "Configuring MariaDB..."
    mysql -uroot <<-EOSQL
        -- Update root password
        UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
        
        -- Remove anonymous users
        DELETE FROM mysql.user WHERE User='';
        
        -- Remove test database
        DROP DATABASE IF EXISTS test;
        
        -- Create our database
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        
        -- Create user with access from any host
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        
        -- Grant privileges
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        
        -- Apply changes
        FLUSH PRIVILEGES;
EOSQL
    echo "MariaDB configuration completed!"
    
    # Stop temporary instance
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    sleep 3
fi

echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql