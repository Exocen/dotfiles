#!/bin/bash
HOST=$1
OUTPUT=$HOST-docker-backup.tgz

ssh $HOST "cd / && tar cz docker-data" > $OUTPUT
if [ $? -eq 0 ]; then
    echo "Backup $OUTPUT created"
    exit 0
else
    echo "Backup from $HOST failed"
    exit 1
fi
