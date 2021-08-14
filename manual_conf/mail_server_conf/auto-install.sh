#debian 9+
#todo hostname= [DOMAIN]
# pssserv = randomize
sudo apt-get install postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql opendkim opendkim-tools mariadb-server certbot sendmail

sudo certbot certonly --standalone --register-unsafely-without-email --agree-tos -d [DOMAIN]

#todo can no interaction ?
sudo mysql_secure_installation 

#todo bash me
sudo mysql -u root -p

CREATE DATABASE mailserver;
CREATE USER 'mailuser'@'127.0.0.1' IDENTIFIED BY '[PASSSERV]';
GRANT SELECT ON mailserver.* TO 'mailuser'@'127.0.0.1';
FLUSH PRIVILEGES;
USE mailserver;
CREATE TABLE `virtual_users` (
  `id` int(11) NOT NULL auto_increment,
  `domain_id` int(11) NOT NULL,
  `password` varchar(106) NOT NULL,
  `email` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_aliases` (
  `id` int(11) NOT NULL auto_increment,
  `domain_id` int(11) NOT NULL,
  `source` varchar(100) NOT NULL,
  `destination` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO mailserver.virtual_domains (name) VALUES ('[DOMAIN]');

# new email
sudo mysql -u root -p
INSERT INTO mailserver.virtual_users (domain_id, password , email) VALUES ('1', TO_BASE64(UNHEX(SHA2('password', 512))), 'user@example.com');
#new alias 
INSERT INTO mailserver.virtual_aliases (domain_id, source, destination) VALUES ('1', 'alias@example.com', 'user@example.com');


