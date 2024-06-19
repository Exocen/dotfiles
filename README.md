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

## 🐳 Docker confs

Docker configuration samples, with helper tools

| Docker container | Base image pull (*custom) | Arguments | Comments |
| --- |  --- |  --- |  --- |
| Filebrowser | **filebrowser/filebrowser** | **$FILEBROWSER_PATH** | |
| Gitea | **gitea/gitea** |  | Behind nginx_certbot proxy |
| Gluetun | **qmcgaw/gluetun** | **$VPN_KEY** | |
| Jdownloader2 | **jlesage/jdownloader-2*** | **$JDOWNLOADER_DL_PATH** | Behind gluetun network |
| Nginx_certbot | **nginx:mainline-alpine*** | **$DOMAIN** | Allows redirection for gitea, vaultwarden, and snappymail containers<br>Creates and renews certifications with certbot automatically |
| Install_test | * | **$IMAGES** | Debian, Ubuntu, Fedora, Alpine, Archlinux, and Manjarolinux/base are used by default |
| Plex | **linuxserver/plex** | **$PLEX_PATH** | |
| Mail_server | **mailserver/docker-mailserver** | **$MAIL_DOMAIN** | Add/Del mail accounts with *setup-mail.sh*<br>Creates opendkim conf with *setup-opendkim.sh*<br>*smtp_sample* available |
| Snappymail | **kouinkouin/snappymail** | | For the first time configuration use *mail.domain.com/?admin*.<br>Accepts user *admin* and password from */docker-data/snappymail/_data_/_default_/admin_password.txt*<br>Behind nginx_certbot proxy |
| Syncthing | **syncthing/syncthing*** | **$SYNCTHING_PATH** | Behind gluetun network |
| Transmission | **lscr.io/linuxserver/transmission** | **$TRANSMISSION_DL_PATH** | Behind gluetun network |
| Vaultwarden | **vaultwarden/server** | **$VW_ADMIN_PASS_ENABLED** |  **$VW_ADMIN_PASS_ENABLED** allows https://VW-DOMAIN/admin access<br>Behind nginx_certbot proxy |
| Ydl | **alpine*** | **$YDL_MUSIC_PATH** | Behind gluetun network |
| Firefox | **jlesage/firefox*** | | Behind gluetun network |

<br>All the containers by default
* use a docker-run.sh script to build and run the container
* are detached and volatiles (-d --rm)
* use */docker-data* and */docker-data-nobackup* folder for data storage
* share localtime and timezone with the host
* can work without docker-compose
* log to journald
* could be started independently with args or with */tools/manager*
* use *docker_user:docker_group 1000:1000* for user permission (data access)
* could use external and custom images

### Docker Tools

#### Backup
*ssh-backup* script is used to backup the */docker-data* dir from a host or locally.\
./*ssh-backup* $host $output_dir\
*vaultwarden-db-backup* script create a backup from the local */docker-data/vaultwarden/sqlite.db*.

#### Docker_manager
Script created to manage all docker containers *(one to rule them all)*.\
Can start containers, allows auto-heal, forwards errors with msmtp, and could be started with systemd.\
./docker_manager $start||stop||reload $conf_file (*tun_conf* or *vps_conf* samples)

#### Fail2ban
Fail2ban configuration sample for every containers. The script installs every jails and filters.

#### Notification and Mails
*msmtp_sample* and *feed-update.sh* script (allow *atom.xml* update) availables.


## 📝 TODO
- [ ] README: add screenshots samples?
- [ ] docker nginx: fignoler le poro
- [ ] Docker xvnc : try with web-browser behind gluetun + start on session only
