#!/bin/sh
set -e

echo "Waiting for MariaDB to be ready..."
# Wait for MariaDB to be fully ready
counter=0
while true; do
    if mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "USE ${MYSQL_DATABASE}; SELECT 1;" >/dev/null 2>&1; then
        echo "MariaDB is ready!"
        break
    fi
    sleep 3
    counter=$((counter+1))
    if [ $counter -gt 30 ]; then
        echo "ERROR: Could not connect to MariaDB after 90 seconds"
        exit 1
    fi
    echo "Still waiting for MariaDB... ($counter/30)"
done

# Check if WordPress is already installed
if wp core is-installed --allow-root >/dev/null 2>&1; then
    echo "WordPress is already installed."
else
    echo "Installing WordPress..."
    
    # Download WordPress if not present
    if [ ! -f /var/www/html/wp-config.php ]; then
        echo "Downloading WordPress..."
        wp core download --allow-root --locale=en_US
    fi

    # Create wp-config.php
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --locale=en_US

    # Install WordPress
    echo "Running WordPress installation..."
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    # Create additional user
    echo "Creating additional user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}" --role=author --allow-root
    
    echo "WordPress installation completed!"
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM..."
exec php-fpm7.4 -F