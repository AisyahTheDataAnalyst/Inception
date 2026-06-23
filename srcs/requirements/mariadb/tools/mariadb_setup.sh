#!/bin/sh

# 1. Check if the database has already been initialized
if [ ! -d "/var/lib/mysql/wordpress" ]; then

    # Initialize the system tables/data directory first
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB safely in the background to run setup SQL commands
    mysqld_safe --skip-networking &
    pid=$!

    # Wait for the database server to fully wake up
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    # 2. Run the SQL configuration using environment variables from your .env file
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    # Shutdown the temporary background instance gracefully
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown
    wait $pid
fi

# 3. Hand over PID 1 to MariaDB executing normally in the foreground
exec mysqld_safe