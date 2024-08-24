#!/bin/bash

# This script creates a database backup dump, which then can be used
# to save and reload a given state of the Worpress database

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

mkdir -p ${DB_BACKUP_PATH}/SQL/${TODAY}
read -p "Enter SQl-file name description: " sqlfile
echo "Backup started for database - ${DATABASE_NAME}"

docker exec ${DOCKER_CONTAINER} /usr/bin/mysqldump --no-tablespaces -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} ${DATABASE_NAME} > ${DB_BACKUP_PATH}/SQL/${TODAY}/${DATABASE_NAME}-${sqlfile}.sql


if [ $? -eq 0 ]; then
    echo "Database backup successfully completed"
else
    echo "Error found during database backup"
    exit 1
fi