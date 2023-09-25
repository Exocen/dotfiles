#!/bin/sh
! sqlite3 --version && echo "Needs sqlite3 installed." && exit 1

BACKUP_PATH="/docker-data/vaultwarden/sqlite3_backups/"
BACKUP_FILE="db.sqlite3_$(date "+%F-%H%M%S")"

mkdir -p $BACKUP_PATH

# rm any backups older than 30 days
find /$BACKUP_PATH/* -mtime +30 -exec rm {} \;

# use sqlite3 to create backup (avoids corruption if db write in progress)
sqlite3 /docker-data/vaultwarden/db.sqlite3 ".backup '$BACKUP_PATH/$BACKUP_FILE'"

