#!/bin/sh

# Injecting secrets variables
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)

# 1. ONLY run installation if the foundational system tables don't exist yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🚀MARIADB SETUP🚀 Initializing fresh MariaDB system tables..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# 2. Only run custom SQL configuration if your specific database doesn't exist yet
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "🚀MARIADB SETUP🚀 [1/3] Configuring custom database and users..."

    # 2.1 Start MariaDB safely in the background to run setup MYSQL commands
    # 2.2 The ampersand (&) forces the shell to fork a child process in the background as below:
    #   PID 1: Your mariadb_setup.sh script.
    #   PID 7 (or similar): The temporary mysqld_safe background daemon.
    mysqld_safe --skip-networking & pid=$!

    # 2.3 The wait loop. for the database server to fully wake up
    # mysqladmin ping = sends a quick "Are you alive?" request to the database
    # >/dev/null 2>&1 = silences the command, throwing away both standard output and error messages so your terminal doesn't get cluttered with connection errors.
    # will get the 1st mysqlq_safe logs on terminal (in docker logs mariadb) - as the child process
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    # 2.4 Create your application database and user first (while root has no password by default)
    # -e = execute 
    # => allows you to run MYSQL commands directly from the command line without opening an interactive database prompt.    
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER_USERNAME}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER_USERNAME}'@'%';"
    mysql -e "FLUSH PRIVILEGES;"
    # 2.5 Change the root password LAST so you don't lock yourself out of the session
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

    # 2.6 Shutdown using the newly created password
    echo "🚀MARIADB SETUP🚀 [2/3] Shutting down temporary mysql process that just to init database creation"
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $pid
fi

echo "🚀MARIADB SETUP🚀 [3/3] MariaDB setup completed successfully!"

# making mysql daemon becoming PID1 => forced to work in the foreground, not background as per set by '&' above
# Hand over PID 1 (forced to work in foreground) to whatever command was passed into the CMD directive
# "$@" = default arguments set by CMD after ENTRYPOINT in Dockerfile - professional industry standard pattern used in most official Docker images.
echo "🚀MARIADB EXECUTION🚀   Executing MariaDB in the foreground with runtime command: $@"
# exec mysqld_safe
exec "$@"
# will get the 2nd mysqlq_safe logs on terminal (in docker logs mariadb) - as the PID1



# 1. Check if the database has already been initialized

    # 2. Initialize the data directory/ foundational system tables

    # 3. Start MariaDB safely in the background to run setup MYSQL commands

    # 4. The wait loop. for the database server to fully wake up
    # Starting a database takes a few seconds. If our script immediately tries to execute MYSQL commands right after starting mysqld_safe, it will fail because the server isn't fully awake yet.
    # mysqladmin ping = sends a quick "Are you alive?" request to the database
    # >/dev/null 2>&1 = silences the command, throwing away both standard output and error messages so your terminal doesn't get cluttered with connection errors.
    # until ... do sleep 1 = done creates a loop that pauses for 1 second and checks again, looping endlessly until the ping succeeds.
    
    # 5. Run the MYSQL configuration using environment variables from your .env file
    # -e = execute
    #   allows you to run MYSQL commands directly from the command line without opening an interactive database prompt.
    # Line2 - The backticks are escaped (```) so the shell doesn't confuse them with command substitutions.
    # Line3 - Creates a dedicated user account (${MYSQL_USER}) with their own password (${MYSQL_PASSWORD}). The @'% wildcard is critical: it means this user is allowed to connect from any remote host/container (like your WordPress container), not just from within the MariaDB container itself.
    # Line4 - Gives your new user complete control (ALL PRIVILEGES) over all tables (.*) inside your newly created database.
    # Line5 - Tells MariaDB to reload its internal grant tables immediately so that all the user and password changes we just made take effect right away.
    # Line1 - MariaDB root administrative user has no password by default. This command sets a strong password (${MYSQL_ROOT_PASSWORD}) for the local root account.
    
    # 6. Shutdown the temporary background instance gracefully
    # Line1 - Now that configuration is finished, we need to stop the temporary, background database instance that was running with --skip-networking. We pass the root username and the password we just created to order a clean shutdown.
    # Line2 - wait tells the script to pause and wait until the background process ($pid, which we saved earlier) completely finishes shutting down before moving past the fi block. (no zombie processes)

# 7. Hand over PID 1 to MariaDB executing normally in the foreground
# We launch mysqld_safe normally (without --skip-networking), so it reads from our 50-server.cnf and opens port 3306 to the Docker network.
# exec forces MariaDB to completely replace the script process. 
# This makes MariaDB PID 1 inside the container, allowing it to receive shutdown signals directly from Docker when you run docker compose down
# Instead of creating a new process under the script,

# notes: https://app.notion.com/p/Setting-up-services-1-MariaDB-3851c36ba37f806680a9ce75185e6a20
