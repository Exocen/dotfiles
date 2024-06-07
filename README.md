# Dotfiles

### 🪄 Automatic installation script

install.sh is a script written with POSIX Shell.\
It allows the installation of basic tools on linux.

#### Run the script install.sh to
1. Install vim, git, htop, iftop, iotop, tree, zsh, make, wget, sudo, rsync, curl.
2. Clone ohmyzsh.git and set the configuration files (zsh will be switched as default shell).
3. Set vim configuration files with plugins.
4. (Optionnal Arch only) install packages from arch-package-list with pikaur, and set the Windows manager (wayland + sway).

#### Script usage
```
install.sh [OPTIONS]:
-d     Use debug mode
-l     Set log path (default /tmp)
-n     Skip all user interaction.  Implied 'No' to all actions
-h     Display this help and exit
```

#### Example
![script_execution_sample](sample.png)

#### Tested on
* Alpine
* Arch (dev conf 🐮 available)
* Debian 12+
* Fedora 40+
* Manjaro
* Ubuntu 24+

Install testing tool available on docker_conf/install_test

---

### 🐳 Docker conf

Short description
what all conf are sharing:

```
local timezone
DOCKER_PATH="/docker-data/
DOCKER_PATH="/docker-data-nobackup/
```

#### Filebrowser
from filebrowser/filebrowser

#### Gitea
from gitea/gitea

#### Install_test
custom img from args
defaults args

#### Gluetun
from qmcgaw/gluetun
use mullvad vpn key arg

#### Jdownloader2
custom img from jlesage/jdownloader-2
use Gluetun network

#### Nginx_certbot
custom img from nginx:mainline-alpine
static_Files
certbot conf
supervisord

#### Plex
from linuxserver/plex

#### Mail_server
from mailserver/docker-mailserver
samples here

#### Snappymail
from kouinkouin/snappymail

#### Syncthing
custom img from syncthing/syncthing
use Gluetun network

#### Transmission
from lscr.io/linuxserver/transmission
use Gluetun network

#### Vaultwarden
from vaultwarden/server
explain 2 options (admin/normal)
recommand to use tools/backup 

#### Ydl
custom img from alpine
use Gluetun network

#### Tools

##### Backup
backup via ssh
vaultwarden backup

##### Docker_manager
Script created to manage all docker containers
auto-heal
error forwarding
healthcheck check

##### Fail2ban
conf sample
install.sh

##### Notification and Mails
msmtp and feed-update

---

### 📝 TODO
- [x] install.sh: remake all options auto-install
- [x] install.sh: add auto docker test (img = arg)
- [x] install.sh: documentation + ReadMe instructions
- [x] vim conf: remake all
- [x] docker feed update: add service notif sample
- [ ] README: add/complete docker instruction for each image + tools
- [x] feed-updater: switch bash html updater to python xml updater
- [x] docker nginx: status displayed with Js reading atom.xml
- [ ] docker nginx: fignoler le poro
- [x] docker jdownloader2: add healthcheck
- [x] docker jdownloader2: add vpn reconnection
- [x] Change install shell: bash -> sh
- [ ] README: Explain/Document user_conf ?