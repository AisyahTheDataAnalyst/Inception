#!/bin/sh

# Wait for MariaDB to be ready before running WordPress setup
# => relied on depends_on in compose

# Injecting passwords into secret variables
MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

echo "❤️‍🔥WORDPRESS INIT SETUP❤️‍🔥 [1/2]⏳ Waiting for MariaDB to accept connections..."
while ! mariadb-admin ping -h"mariadb" -u"${MYSQL_USER_USERNAME}" -p"${MYSQL_USER_PASSWORD}" --silent; do
    sleep 1
done
echo "❤️‍🔥WORDPRESS INIT SETUP❤️‍🔥 [2/2]✅ MariaDB is fully up and running!"

# 1. Check if WordPress is already downloaded in the volume
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [1/8] Hmmm... WordPress not found. Let's set it up!"

	# 2. Explicitly typing the workdir inside the script acts as a safety net to guarantee 
    #       WP-CLI executes exactly where your WordPress files are supposed to go.
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [2/8] Now we're inside Wordpress's volume!"
    cd /var/www/html

    # 3. Download core WordPress files
    # 
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [3/8] Installing core Wordpress files..."
    wp-cli core download --allow-root

	# 4. Create wp-config.php using environment variables/secrets
    # Note: If using Docker secrets, read the password from the secret file path
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [4/8] Installing wp-config.php..."
    wp-cli config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER_USERNAME}" \
        --dbpass="${MYSQL_USER_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

	# 5. Install WordPress and create the core administrator account
    # CRITICAL: Admin username MUST NOT contain "admin" or "administrator"
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [5/8] Installing Wordpress & creating admin account..."
    echo "Debugging Vars: URL=${WP_DOMAIN_URL} Title=${WP_WEBSITE_TITLE} User=${WP_ADMIN_USERNAME}"
    wp-cli core install \
        --url="${WP_DOMAIN_URL}" \
        --title="${WP_WEBSITE_TITLE}" \
        --admin_user="${WP_ADMIN_USERNAME}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # 6. Create the second regular user required by the project
    # syntax: wp user create <username> <email> --user_pass=<password> [options]
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [6/8] Creating regular user account..."
    wp-cli user create \
        "${WP_USER_USERNAME}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
        
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [7/8] WordPress setup completed successfully!"
fi

# 7. Ensure ALL downloaded WordPress files belong to www-data
chown -R www-data:www-data /var/www/html

# 8. Hand over PID 1 to PHP-FPM running in the foreground (No infinite loops!)
# "$@" = default arguments set by CMD after ENTRYPOINT in Dockerfile - professional industry standard pattern used in most official Docker images.
echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [8/8] Starting PHP-FPM in the foreground with runtime command: $@"
# exec php-fpm8.2 -F
exec "$@"

