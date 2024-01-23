#!/bin/bash
# USAGE $1=Host $2=output_dir
HOST=$1
OUTPUT=$HOST-`date +"%Y-%m-%dT%H:%M:%S"`.tgz
BACKUP_DIR=$2/docker-backup/$HOST
MAX_BACKUP=20

rotate_backup() {
    mkdir -p $BACKUP_DIR
    if [ `ls -rt $BACKUP_DIR | wc -l` -ge $MAX_BACKUP ] ; then
        rm -v -- $BACKUP_DIR/$(ls -rt $BACKUP_DIR | head -1) && rotate_backup
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
