yai nginx-mainline certbot-nginx
extract html2.tar.gz
/bin/cp -f html2 /usr/share/nginx/html2
mkdir -p /etc/nginx/sites-enabled/
/bin/cp -f nginx.conf /etc/nginx/
/bin/cp -f default /etc/nginx/sites-enabled/
systemctl enable nginx
systemctl start nginx
certbot --nginx -n --agree-tos --rsa-key-size 4096 --register-unsafely-without-email -d exocen.com -d www.exocen.com
# auto certbot
/bin/cp -f default_https /etc/nginx/sites-enabled/
openssl dhparam -out /etc/nginx/dhparam.pem 4096 
systemctl restart nginx
