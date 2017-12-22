#!/bin/bash

echo "What is your destination email ?"
read email
echo $email" ? (y/n)"
read answer
if [ "$answer" == "Y" ] || [ "$answer" == "y" ] || [ "$answer" == "YES" ] || [ "$answer" == "yes" ];then
    sudo bash -c 'echo "@$HOSTNAME "'$email' >> /etc/postfix/virtual'
    sudo postmap /etc/postfix/virtual
    sudo systemctl restart postfix
else
    echo 'Cancel'
fi
