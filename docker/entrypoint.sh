#!/bin/bash
# set -x
QUICKWP_REINSTALL=1

# If either WP dir or MySQL data dirs are empty we are reinstalling everything.

if [ "$(ls -A /var/www/html/)" ] || [ "$(ls -A /var/lib/mysql/)" ]
then
    QUICKWP_REINSTALL=0
else
    QUICKWP_REINSTALL=1
fi

# Do reinstall.
if [ "$QUICKWP_REINSTALL" = 1 ]; then
    echo $QUICKWP_REINSTALL
    echo "Redeploying the container..."

    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/8.3/fpm/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php/8.3/fpm/php.ini

    # Init db
    /usr/bin/mysql_install_db --user=mysql --ldata=/var/lib/mysql/

    # Start our daemons
    service mariadb start
    service php8.3-fpm start

    # Create database.
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
define( 'WP_HOME', "http://$QUICKWP_URL:$QUICKWP_PORT" );
define( 'WP_SITEURL', "http://$QUICKWP_URL:$QUICKWP_PORT" );
PHP

    # Install
    /usr/local/bin/wp core install --allow-root --url=$QUICKWP_URL --title=QUICKWP --admin_user=quickwp --admin_password=quickwp --admin_email=quickwp@example.com

    # Uninstall WordPress default plugins
    /usr/local/bin/wp plugin uninstall --all --allow-root

    # Install MY standard plugins
    /usr/local/bin/wp plugin install woocommerce log-http-requests /tmp/plugins/wp-all-import-pro.zip /tmp/plugins/wpai-woocommerce-add-on.zip /tmp/plugins/custom-product-tabs-wp-all-import-add-on.zip --activate --allow-root 

    # Install plugins
    IFS=',' read -r -a plugins_array <<< "$QUICKWP_PLUGINS"
    for plugin in "${plugins_array[@]}"
    do
        wp plugin install $plugin --activate --allow-root
    done
else
    echo $QUICKWP_REINSTALL
    echo "Starting daemons..."

    # Start our daemons
    service mariadb start
    service php8.3-fpm start
fi

# Download and install adminer database tool
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-en.php -O /var/www/html/adminer.php

# Add write permissions to uploads.
# Set the correct permissions for the case ...
chown -R www-data:www-data /var/www/html
find /var/www/html -type f -exec chmod 644 {} \;
find /var/www/html -type d -exec chmod 755 {} \;

# Run nginx
exec nginx
