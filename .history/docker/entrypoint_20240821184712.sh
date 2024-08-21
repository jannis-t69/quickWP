#!/bin/bash
# set -x
INSTANTWP_REINSTALL=1

# If either WP dir or MySQL data dirs are empty we are reinstalling everything.

if [ "$(ls -A /var/www/html/)" ] || [ "$(ls -A /var/lib/mysql/)" ]
then
    INSTANTWP_REINSTALL=0
else
    INSTANTWP_REINSTALL=1
fi

# if [ "$(ls -A /var/www/html/)" ]; then
#     echo "WordPress installation exists."
#     INSTANTWP_REINSTALL=0
# else
#     echo "WordPress installation doesn't exist. Force reinstall!"
#     INSTANTWP_REINSTALL=1
# fi
# if [ "$(ls -A /var/lib/mysql/)" ]; then
#     echo "MySQL data exists."
#     INSTANTWP_REINSTALL=0
# else
#     echo "MySQL data files doesn't exist. Force reinstall!"
#     INSTANTWP_REINSTALL=1
# fi

# Alter PHP settings to allow large file uploads.

# Do reinstall.
if [ "$INSTANTWP_REINSTALL" = 1 ]; then
    echo $INSTANTWP_REINSTALL
    echo "Reinstall..."

    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/8.3/fpm/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php/8.3/fpm/php.ini

    # Init db
    /usr/bin/mysql_install_db --user=mysql --ldata=/var/lib/mysql/

    # Start our daemons
    service mariadb start
    service php8.3-fpm start

    # Create database.
    /usr/bin/mysql -uroot -e "CREATE DATABASE app;"
    /usr/bin/mysql -e "CREATE USER 'instantwp'@'localhost' IDENTIFIED BY 'instantwp';"
    /usr/bin/mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'instantwp'@'localhost';"
    /usr/bin/mysql -e "FLUSH PRIVILEGES;"

    # Download WordPress
    /usr/local/bin/wp core download --allow-root --path=/var/www/html --force --locale=$INSTANTWP_LOCALE

    /usr/local/bin/wp config create --allow-root --dbname=app --dbuser=instantwp --dbpass=instantwp --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_HOME', "http://$INSTANTWP_URL:$INSTANTWP_PORT" );
define( 'WP_SITEURL', "http://$INSTANTWP_URL:$INSTANTWP_PORT" );
PHP

    # Install
    /usr/local/bin/wp core install --allow-root --url=$INSTANTWP_URL --title=InstantWP --admin_user=instantwp --admin_password=instantwp --admin_email=info@example.com

    # Uninstall WordPress default plugins
    /usr/local/bin/wp plugin uninstall --all --allow-root

    # Install my standard plugins
    /usr/local/bin/wp plugin install woocommerce log-http-requests --activate --allow-root 

    # Install plugins
    IFS=',' read -r -a plugins_array <<< "$INSTANTWP_PLUGINS"
    for plugin in "${plugins_array[@]}"
    do
        wp plugin install $plugin --activate --allow-root
    done
else
    echo $INSTANTWP_REINSTALL
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
