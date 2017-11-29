yai postfix
cp /etc/postfix/main.conf
cp /etc/postfix/master.cf
#openssl dhparam -out /etc/postfix/dhparam.pem 2048
postalias /etc/postfix/aliases
# or newaliases
# cp .forward ?
systemctl enable postfix
systemctl start postfix
#spam assassin ?
yai  python-postfix-policyd-spf 
# only user mode :(
cp /etc/opendkim/opendkim.conf
opendkim-genkey -r -s myselector --directory=/etc/opendkim/ -d exocen.com   
# cat  /etc/opendkim/myselector.txt