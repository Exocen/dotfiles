#!/bin/sh
# Use with ssh_backup.sh

! sqlite3 --version &>/dev/null && echo "sqlite3 needs to be installed." && exit 1

BACKUP_PATH="/docker-data/vaultwarden/sqlite3_backups/"
DB_PATH="/docker-data/vaultwarden/db.sqlite3"
BACKUP_FILE="db_$(date "+%F-%H%M%S").sqlite3"

mkdir -p $BACKUP_PATH

# rm any backups older than 30 days
find $BACKUP_PATH/* -mtime +30 -exec rm {} \;

# use sqlite3 to create backup (avoids corruption if db write in progress)
sqlite3 $DB_PATH "VACUUM INTO  '$BACKUP_PATH/$BACKUP_FILE'"

# From https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault
# Make sure vaultwarden is stopped, and then simply replace each file or directory in the data dir with its backed up version.

# When restoring a backup created using .backup or VACUUM INTO, make sure to first delete any existing db.sqlite3-wal file, as this could potentially result in database corruption when SQLite tries to recover db.sqlite3 using a stale/mismatched WAL file. However, if you backed up the database using a straight copy of db.sqlite3 and its matching db.sqlite3-wal file, then you must restore both files as a pair. You don't need to back up or restore the db.sqlite3-shm file.
