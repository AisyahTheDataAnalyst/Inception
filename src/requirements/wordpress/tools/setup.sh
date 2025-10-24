#!/bin/sh

# Wait for MariaDB to be ready
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SHOW DATABASES;" >/dev/null 2>&1; do
  echo "Waiting for MariaDB..."
  sleep 3
done

# If WordPress is not installed yet
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Downloading WordPress..."
  wp core download --allow-root

  echo "Creating wp-config.php..."
  wp config create --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="mariadb:3306"

  echo "Installing WordPress..."
  wp core install --allow-root \
    --url="https://localhost" \
    --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}" --role=author --allow-root
fi

# Make sure permissions are correct
chown -R www-data:www-data /var/www/html

# Run PHP-FPM in foreground
php-fpm7.4 -F
