#!/bin/bash
if [ $# -eq 2 ]
then
    sudo mysql -u root -e "INSERT INTO mailserver.virtual_users (domain_id, password , email) VALUES ('1', TO_BASE64(UNHEX(SHA2('$2', 512))), '$1');"
else
    echo "Usage: ./script email password"
fi
