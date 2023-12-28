#!/bin/bash
HOST=$1
BACKUP_PREFFIX=docker-backup
OUTPUT=$BACKUP_PREFFIX-`date +"%s"`.tgz
BACKUP_DIR=$HOME/backup-$HOST
MAX_BACKUP=10

mkdir -p $BACKUP_DIR
backup_to_remove_count=$((`ls -rta $BACKUP_DIR | wc -l` - $MAX_BACKUP))
if [ $backup_to_remove_count -gt 0 ] ; then
    rm -- "$(ls -rta $BACKUP_DIR | head -$backup_to_remove_count)"
fi

ssh $HOST "cd / && tar cz docker-data" > $BACKUP_DIR/$OUTPUT
if [ $? -eq 0 ]; then
    echo "Backup $OUTPUT created"
    exit 0
else
    echo "Backup from $HOST failed"
    exit 1
fi
