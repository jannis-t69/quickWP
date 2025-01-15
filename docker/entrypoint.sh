#!/bin/bash
# set -x

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/log/entrypoint.log 2>&1
# Everything below will go to the file 'log.out':

echo "Deploying the container..."

# Init db
/usr/bin/mysql_install_db --user=mysql --ldata=/var/lib/mysql/

# Start mariadb
service mariadb start

# # Create database.
/usr/bin/mysql -uroot -e "CREATE DATABASE wordpress;"
/usr/bin/mysql -e "CREATE USER 'quickwp'@'localhost' IDENTIFIED BY 'quickwp';"
/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'quickwp'@'localhost';"
/usr/bin/mysql -e "FLUSH PRIVILEGES;"

# Download WordPress
/usr/local/bin/wp core download --allow-root --path=/var/www/html --force --locale=$QUICKWP_LOCALE

/usr/local/bin/wp config create --allow-root --dbname=wordpress --dbuser=quickwp --dbpass=quickwp --extra-php <<PHP
// Enable WP_DEBUG mode
define( 'WP_DEBUG', true );
// Enable Debug logging to the /wp-content/debug.log file
define( 'WP_DEBUG_LOG', true );
// Disable display of errors and warnings
define( 'WP_DEBUG_DISPLAY', false );
@ini_set( 'display_errors', 0 );
// Use dev versions of core JS and CSS files (only needed if you are modifying these core files)
define( 'SCRIPT_DEBUG', false );
define( 'WP_HOME', "https://$QUICKWP_URL" );
define( 'WP_SITEURL', "https://$QUICKWP_URL" );
PHP

# Install
/usr/local/bin/wp core install --allow-root --url=$QUICKWP_URL --title=QUICKWP --admin_user=quickwp --admin_password=quickwp --admin_email=quickwp@example.com

# Uninstall WordPress default plugins
/usr/local/bin/wp plugin uninstall --all --allow-root

# Install MY standard plugins
/usr/local/bin/wp plugin install woocommerce log-http-requests /tmp/plugins/wp-all-import-pro.zip /tmp/plugins/wpai-woocommerce-add-on.zip /tmp/plugins/custom-product-tabs-wp-all-import-add-on.zip /tmp/plugins/atec-cache-info.zip /tmp/plugins/atec-system-info.zip --activate --allow-root

# Install plugins
IFS=',' read -r -a plugins_array <<<"$QUICKWP_PLUGINS"
for plugin in "${plugins_array[@]}"; do
    wp plugin install $plugin --activate --allow-root
done

# Download and install adminer database tool
wget -nv https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-en.php -O /var/www/html/adminer.php

# # Add write permissions to uploads.
# # Set the correct permissions for the case ...
chown -R www-data:www-data /var/www/html
find /var/www/html -type f -exec chmod 644 {} \;
find /var/www/html -type d -exec chmod 755 {} \;

# Start our daemons
echo "Starting daemons..."

# Start php-fpm
service php8.3-fpm start

# Create nginx log directory
mkdir -p /var/log/nginx/
chown -R www-data:www-data /var/log/nginx

# Start nginx
# service nginx start
exec nginx -g 'daemon off;'

# For debugging uncomment and set start nginx as service
# sleep infinity
