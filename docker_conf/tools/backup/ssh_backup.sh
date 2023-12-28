#!/bin/bash
HOST=$1
BACKUP_PREFFIX=docker-backup
OUTPUT=$BACKUP_PREFFIX-`date +"%s"`.tgz
BACKUP_DIR=$HOME/backup-$HOST
MAX_BACKUP=10

rotate_backup() {
    mkdir -p $BACKUP_DIR
    if [ `ls -rt $BACKUP_DIR | wc -l` -ge $MAX_BACKUP ] ; then
        cd $BACKUP_DIR
        rm -- "$(ls -rt $BACKUP_DIR | head -1)" && rotate_backup
    fi
}

rotate_backup
ssh $HOST "cd / && tar cz docker-data" > $BACKUP_DIR/$OUTPUT
if [ $? -eq 0 ]; then
    echo "Backup $OUTPUT created"
    exit 0
else
    echo "Backup from $HOST failed"
    exit 1
fi
