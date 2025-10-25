#!/bin/sh
set -e

echo "Waiting for MariaDB..."
# More robust waiting with timeout
counter=0
while ! mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SHOW DATABASES;" >/dev/null 2>&1; do
  sleep 3
  counter=$((counter+1))
  if [ $counter -gt 20 ]; then
    echo "ERROR: Could not connect to MariaDB after 60 seconds"
    exit 1
  fi
  echo "Still waiting for MariaDB... ($counter/20)"
done

echo "MariaDB is ready!"

# Download WordPress if not present
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Downloading WordPress..."
  wp core download --allow-root --locale=en_US

  echo "Creating wp-config.php..."
  wp config create --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="mariadb:3306" \
    --locale=en_US

  echo "Installing WordPress..."
  wp core install --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  echo "Creating additional user..."
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}" --role=author --allow-root
  
  echo "WordPress installation completed!"
else
  echo "WordPress is already installed."
fi

# Fix permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm7.4 -F