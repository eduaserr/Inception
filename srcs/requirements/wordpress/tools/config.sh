#!/bin/sh

if [ ! -f "/var/www/html/index.php" ]; then
   wget -O wordpress.zip https://wordpress.org/wordpress-6.8.1.zip && \
   unzip wordpress.zip && \
   cp -rf wordpress/* . && \
   rm -rf wordpress wordpress.zip
fi


mkdir -p /run/php/
sed -i "s|listen = /run/php/php8.2-fpm.sock|listen = 9443|g" /etc/php/8.2/fpm/pool.d/www.conf

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

until mysql -h mariadb -u"$DB_USER" -p"$DB_PASS" -e "USE ${DB_NAME};" 2>/dev/null; do
   echo "Waiting for the database to be ready..."
   sleep 3
done

if [ ! -f "/var/www/html/wp-config.php" ]; then
   wp config create --allow-root --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASS} --dbhost=${DB_HOST} --path="/var/www/html" &&
   wp core install --allow-root --url="${WP_URL}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="${WP_ADMIN_PASS}" --admin_email="${WP_ADMIN_EMAIL}" --path="/var/www/html"
   wp user create --allow-root ${WP_USER} ${WP_USER_EMAIL} --role=author --user_pass=${WP_USER_PASS} --path="/var/www/html"
fi

exec /usr/sbin/php-fpm8.2 -F