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

# 1. Explicitly typing the workdir inside the script acts as a safety net to guarantee 
echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [1/9] Let go inside Wordpress's volume!"
cd /var/www/html

# 2. Check if WordPress core is extracted. If empty, populate it.
# Copy pre-downloaded files instead of hitting the internet
if [ ! -f /var/www/html/index.php ]; then
    # WP-CLI executes exactly where your WordPress files are supposed to go.
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [2/9] Hmmm... WordPress core not found. Let's extract it!"
    cp -r /tmp/wordpress/* /var/www/html/
fi

# 3. Check if WordPress configuration exists
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [1~2/9] Core Wordpress files extracted!"
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [3/9] Generating fresh wp-config.php dynamically..."

    # 4. Download core WordPress files
    # !not using this anymore - takes double the time than extracting cached wp files (~33s)
    # echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥 [3/9] Installing core Wordpress files..."
    # wp-cli core download --allow-root

	# 4. Create wp-config.php using environment variables/secrets
    # Note: If using Docker secrets, read the password from the secret file path
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [4/9] Installing wp-config.php..."
    wp-cli config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER_USERNAME}" \
        --dbpass="${MYSQL_USER_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

	# 5. Install WordPress and create the core administrator account
    # CRITICAL: Admin username MUST NOT contain "admin" or "administrator"
    # --skip-email = Skip the wp_mail() initialization check entirely for this step."
    # When WordPress is installed via wp core install, it auto attempts to send a "Welcome to WordPress" email to the admin email
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [5/9] Installing Wordpress & creating admin account..."
    # echo "Debugging Vars: URL=${WP_DOMAIN_URL} Title=${WP_WEBSITE_TITLE} User=${WP_ADMIN_USERNAME}"
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
    # do not need to add --skip-email here because the wp user create command does not send an installation email by default.
    # If you try to add --skip-email to wp user create, WP-CLI will throw an error because --skip-email is not a valid flag for that specific subcommand.
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [6/9] Creating regular user account..."
    wp-cli user create \
        "${WP_USER_USERNAME}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
        
else
    echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [1~6/9] Existing wp-config.php detected. Skipping configuration."
fi

# 7. Ensure ALL downloaded WordPress files belong to www-data
chown -R www-data:www-data /var/www/html
echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [7/9] All WordPress files belong to www-data!"

# 8. Ensure PHP-FPM listens on network port 9000 for Nginx, not a local unix socket
echo "listen = 9000" >> /etc/php/8.2/fpm/pool.d/www.conf
echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [8/9] PHP-FPM listens on network port 9000 for Nginx!"


echo "❤️‍🔥WORDPRESS SETUP❤️‍🔥      [9/9] WordPress setup completed successfully!"

# 8. Hand over PID 1 to PHP-FPM running in the foreground (No infinite loops!)
# "$@" = default arguments set by CMD after ENTRYPOINT in Dockerfile - professional industry standard pattern used in most official Docker images.
echo "❤️‍🔥WORDPRESS EXECUTION❤️‍🔥        Starting PHP-FPM in the foreground with runtime command: $@"
# exec php-fpm8.2 -F
exec "$@"

