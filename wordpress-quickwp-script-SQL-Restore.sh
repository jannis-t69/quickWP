#!/bin/bash

# This script restores a given database backup, created with wordpress-quickwp-script-SQL-Backup.sh script



export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=$(date +"%d%b%Y")
HOURMINUTE=$(date +"%H%M")

################################################################
################## Update below values  ########################
################################################################

DB_BACKUP_PATH="${PWD}/DbBackups"
DOCKER_CONTAINER='quickwp'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='quickwp'
MYSQL_PASSWORD='quickwp'
DATABASE_NAME='wordpress'

################## Update below values  ########################
echo "You can copy/paste one of the following backups to restore: "

find ${DB_BACKUP_PATH}/SQL -printf "%T@ %Tc %p\n" -iregex '.+\.sql' | sort -n
read -p "Enter SQl-file to restore: " sqlfile

echo "Dropping Database: "${DATABASE_NAME}
docker exec ${DOCKER_CONTAINER} /usr/bin/mysql -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} -e "drop database ${DATABASE_NAME}"

echo "Creating Database: "${DATABASE_NAME}
docker exec ${DOCKER_CONTAINER} /usr/bin/mysql -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} -e "create database ${DATABASE_NAME}"

echo "Restoring Database: "${DATABASE_NAME}
cat ${sqlfile} | docker exec -i ${DOCKER_CONTAINER} /usr/bin/mysql -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} ${DATABASE_NAME}

if [ $? -eq 0 ]; then
    echo "Database backup successfully completed"
else
    echo "Error found during database backup"
    exit 1
fi
