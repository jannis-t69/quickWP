# InstantWP

InstantWP is a Docker based tool to instantly spin up a WordPress site. It's meant for rapid prototyping and testing plugins and themes.

## Requirements

- Docker

## Usage

- Run `./instantwp`
- Open your browser with the parameter (-u) specified for IP/Domain : http://<IP/Domain> or the defaul one set in instantwp.sh

## Available parameters

- i: Domain or IP
- w: List of plugins you want to install. Comma separated list.
- l: Locale ([https://make.wordpress.org/polyglots/teams/](https://make.wordpress.org/polyglots/teams/))
- r: Set to no for no-reinstall
- p: Set the port for Wordpress to docker's forward port

Example command with parameters:  
`./instantwp -i localhost -p 6080 -l en_US -r no -w woocommerce`

WordPress files are located in the public folder. SQL files are located in the mysql-data folder.

## Credentials

WP admin account: `instantwp` / `instantwp`

## Cleanup and reinstall

By default the script resets the installation and spins up the container in detached mode.
If you don't want to remove the current WordPress installation and reinstall it you can run:  
`./instantwp -r no`

## Port forwarding and WordPress URL

If docker port-forwarding is used then the following two setting must be set for wp-confing.php

- `define( 'WP_HOME', "http://$INSTANTWP_URL:<forwarded host-Port>" );`
- `define( 'WP_SITEURL', "http://$INSTANTWP_URL:<forwarded host-Port>" );`

