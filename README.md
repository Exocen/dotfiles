# ⚙️ Dotfiles
My configuration files, samples, and helpers.

## 🪄 Automatic installation script

*install.sh* is a script written with POSIX Shell.\
It allows the installation of basic tools on linux.

### Run the script install.sh to
1. Install vim, git, htop, iftop, iotop, tree, zsh, make, wget, sudo, rsync, curl.
2. Clone ohmyzsh.git and set the configuration files (zsh will be switched as default shell).
3. Set vim configuration files with plugins.
4. (Optionnal Arch only) install packages from arch-package-list with pikaur, and set the Windows manager (wayland + sway).

### Script usage
```
install.sh [OPTIONS]:
-d     Use debug mode
-l     Set log path (default /tmp)
-n     Skip all user interaction.  Implied 'No' to all actions
-h     Display this help and exit
```

### Example
![script_execution_sample](sample.png)

### Tested on
* Alpine
* Arch (wm conf 🐮 available)
* Debian 12+
* Fedora 40+
* Manjaro
* Ubuntu 24+

Install testing tool available on *docker_conf/install_test*

## 🐳 Docker conf

Docker configuration samples, with helper tools

All the containers by default
* use a docker-run.sh script to build the image and create the container
* are detached and volatiles (-d --rm)
* use */docker-data* and */docker-data-nobackup* folder for data storage
* share the local time and timezone with the host
* can work without docker-compose
* log to journald
* could be started independently with args or with */tools/manager*
* use *user:group 1000:1000* for user permission (data access)
* could use external images and build local ones

### Filebrowser
From **filebrowser/filebrowser**\
Needs **FILEBROWSER_PATH** argument

### Gitea
From **gitea/gitea**\
Behind nginx_certbot proxy

### Install_test
Used to test the install.sh script \
Accept custom images string list as arguments\
Debian, Ubuntu, Fedora, Alpine, Archlinux, and Manjarolinux/base are used by default

### Gluetun
From **qmcgaw/gluetun**\
Needs **VPN_KEY** argument

### Jdownloader2
Custom img from **jlesage/jdownloader-2**\
Behing gluetun network\
Needs **JDOWNLOADER_DL_PATH** argument

### Nginx_certbot
Custom img from **nginx:mainline-alpine**\
Needs **DOMAIN** argument\
Allows redirection for gitea, vaultwarden, and snappymail containers\
Creates and renews certifications with certbot automatically

### Plex
From **linuxserver/plex**\
Needs **PLEX_PATH** argument

### Mail_server
From **mailserver/docker-mailserver**\
Needs **MAIL_DOMAIN** argument\
Add/Del mail accounts with *setup-mail.sh*\
Creates opendkim conf with *setup-opendkim.sh*\
*smtp_sample* available

### Snappymail
From **kouinkouin/snappymail**\
For the first time configuration use *mail.domain.com/?admin*. Accepts user *admin* and password from */docker-data/snappymail/_data_/_default_/admin_password.txt*\
Behind nginx_certbot proxy

### Syncthing
Custom img from **syncthing/syncthing**\
Needs **SYNCTHING_PATH** argument\
Behind gluetun network

### Transmission
From **lscr.io/linuxserver/transmission**\
Behind gluetun network

### Vaultwarden
From **vaultwarden/server**\
Needs **VW_ADMIN_PASS_ENABLED** argument (allows https://VW-DOMAIN/admin access)\
Behind nginx_certbot proxy

### Ydl
Custom img from **alpine**\
Behind gluetun network

### Tools

#### Backup
*ssh-backup* script is used to backup the */docker-data* dir from a host or locally\
Usage :$1=Host $2=output_dir\
*vaultwarden-db-backup* script create a backup from the local */docker-data/vaultwarden/sqlite.db*

#### Docker_manager
Script created to manage all docker containers\
Usage: $1:start|stop|reload $2:conf_file (*tun_conf* or *vps_conf* samples)\
It can auto-heal containers, forward errors with msmtp, and could be started with systemd

#### Fail2ban
Fail2ban configuration sample for every containers. The script *install.sh* installs every jails and filters

#### Notification and Mails
msmtp_sample and *feed-update.sh* script (allow *atom.xml* update) available


## 📝 TODO
- [x] install.sh: remake all auto-install options
- [x] install.sh: add auto docker test (img = argument)
- [x] install.sh: documentation + ReadMe instructions
- [x] vim conf: remake all
- [x] docker feed update: add service notif sample
- [x] README: add/complete docker instruction for each image + tools
- [x] feed-updater: switch bash html updater to python xml updater
- [x] docker nginx: status displayed with Js reading atom.xml
- [ ] docker nginx: fignoler le poro
- [x] docker jdownloader2: add healthcheck
- [x] docker jdownloader2: add vpn reconnection
- [x] Change install shell: bash -> sh
