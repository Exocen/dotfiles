# Dotfiles

### 🪄 Automatic installation

install.sh is a script written with POSIX Shell.
It allows to install basic tools in a new linux installation

#### Run the script install.sh to install
1. packages "vim git htop iftop iotop tree zsh make wget sudo rsync"
2. zsh configuration files (zsh as default shell)
3. vim configuration files with plugins
4. (Optionnal Arch only) arch-package-list with pikaur and sway configuration

#### Script usage
```
install.sh [OPTION]:
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

---

### 📝 TODO
- [x] install.sh: remake all options auto-install
- [x] install.sh: add auto docker test (img = arg)
- [x] install.sh: documentation + ReadMe instructions
- [x] vim conf: remake all
- [x] docker feed update: add service notif sample
- [ ] README: add docker instruction for each image + tools
- [ ] plex + filebrowser: try to find another solution with ps4 comptability
- [x] feed-updater: switch bash html updater to python xml updater
- [x] docker nginx: status displayed with Js reading atom.xml
- [ ] docker nginx: fignoler le poro
- [x] docker jdownloader2: add healthcheck
- [x] docker jdownloader2: add vpn reconnection
- [x] Change install shell: bash -> sh
- [ ] Zsh: add a way to use template samples/services/sample.service with "create_new_service" alias + timer
