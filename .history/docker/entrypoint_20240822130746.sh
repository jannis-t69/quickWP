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
    echo "Reinstalling ..."

    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/8.3/fpm/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php/8.3/fpm/php.ini

    # Init db
    /usr/bin/mysql_install_db --user=mysql --ldata=/var/lib/mysql/

    # Start our daemons
    service mariadb start
    service php8.3-fpm start

    # Create database.
    /usr/bin/mysql -uroot -e "CREATE DATABASE app;"
    /usr/bin/mysql -e "CREATE USER 'QUICKWP'@'localhost' IDENTIFIED BY 'QUICKWP';"
    /usr/bin/mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'QUICKWP'@'localhost';"
    /usr/bin/mysql -e "FLUSH PRIVILEGES;"

    # Download WordPress
    /usr/local/bin/wp core download --allow-root --path=/var/www/html --force --locale=$QUICKWP_LOCALE

    /usr/local/bin/wp config create --allow-root --dbname=app --dbuser=QUICKWP --dbpass=QUICKWP --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_HOME', "http://$QUICKWP_URL:$QUICKWP_PORT" );
define( 'WP_SITEURL', "http://$QUICKWP_URL:$QUICKWP_PORT" );
PHP

    # Install
    /usr/local/bin/wp core install --allow-root --url=$QUICKWP_URL --title=QUICKWP --admin_user=QUICKWP --admin_password=QUICKWP --admin_email=info@example.com

    # Uninstall WordPress default plugins
    /usr/local/bin/wp plugin uninstall --all --allow-root

    # Install my standard plugins
    /usr/local/bin/wp plugin install woocommerce log-http-requests --activate --allow-root 

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

# Add write permissions to uploads.
mkdir -p /var/www/html/wp-content/uploads/
chmod -R 777 /var/www/html/wp-content/uploads/
chown -R www-data:www-data /var/www/html

echo "All done! Now open your browser: http://192.168.2.5:6080"

# Run nginx
exec nginx
