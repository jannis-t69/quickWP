# QuickWP

QuickWP script can be used to spin up a detached docker WordPress container for a temporary test site. It is not meant for production purposes

## Requirements

- Docker and a shell

## Usage

- Run `./quichwp`
- After container deployment open your browser with the parameter specified for IP and port http://<IP/Domain>:<forwarded host-Port> or the default ones set in quickwp.sh

## Commandline parameters

- i: Domain or IP
- w: List of plugins you want to install. Comma separated list.
- l: Wordpress locale ([https://wpastra.com/docs/complete-list-wordpress-locale-codes/])
- r: Set to no for no-reinstall
- p: Set the port for Wordpress to docker's forward port

Example command with parameters:  
`./quickwp -i localhost -p 6080 -l en_US -r no -w woocommerce`

WordPress files are located in the public folder. SQL files are located in the mysql-data folder.

## Wordpress & Adminer Database Editor Admin Login

- username `quickwp`
- password `quickwp`

## Database Editor

Adminer has been added as a database editor with the same credentials as WordPress

- `http://URL:Port/adminer.php`

## Port forwarding and WordPress URL

For docker port-forwarding, other the default port 80, the following two settings must be set in wp-config.php so that Wordpress can be accessed from outside the container.

- `define( 'WP_HOME', "http://$QUICKWP_URL:<forwarded host-Port>" );`
- `define( 'WP_SITEURL', "http://$QUICKWP_URL:<forwarded host-Port>" );`

Those can be set in quickwp.sh as default or specified with the -i and -p parameters

## Database current state backup and restore

Most of the time during testing i need the WordPress installation to have a certain state, for example with WooCommerce and Elementor enabled, so i use the two shell scripts to save and restore the database's state

- `wordpress-quickwp-script-SQL-Backup.sh`
- `wordpress-quickwp-script-SQL-Restore.sh`

The `wordpress-quickwp-script-SQL-Backup.sh` script asks for a description which will be added to the SQL dump's filename.
The `wordpress-quickwp-script-SQL-Restore.sh` script lists the .sql files found in the script's configured database dump folder, which then i can copy/paste to restore the database state needed

## Cleanup and reinstall

By default the script resets the installation and spins up the container in detached mode.
If you don't want to remove the current WordPress installation and reinstall it you can run:  
`./quickwp -r no`

## Delete container and image

- `reset-installation.sh` can be used to delete WordPress and MySQL files, stop and delete the container and image
