#!/bin/bash
if [ $# -eq 2 ]
then
    sudo mysql -u root -e "INSERT INTO mailserver.virtual_aliases (domain_id, source, destination) VALUES ('1', '$1', '$2');"
else
    echo "Usage: ./script alias_email email"
fi
