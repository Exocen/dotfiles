## ⚙️ Dotfiles
My configuration files, samples, and helpers

### 🪄 Automatic installation script

#### Run *install.sh* to
1. Install vim git htop iftop iotop tree zsh make wget curl sudo rsync p7zip
2. Set zsh config
3. Set vim config
4. (Optionnal Arch only) install packages from arch-package-list, and the windows manager (wayland + sway)

#### Script usage
```
install.sh [OPTIONS]:
-d     Use debug mode
-l     Set log path (default /tmp)
-n     Skip user interaction.  Implied 'No' to every actions
-h     Display this output
```

#### Example
![script_execution_sample](sample.png)

#### Tested on
* Alpine
* Arch (wm conf 🐮 available)
* Debian 12+
* Fedora 40+
* Manjaro
* Ubuntu 24+
* Linux Mint 22+

Tested with *docker_conf/install_test*

### 📝 TODO
- [x] Docker mail_server : run ipv6 blocker with docker-run
- [x] Docker fail2ban : script/txt -> run fail2ban service AFTER docker service
- [x] waybar : run iostat has a background process/user service , the plugin should only read a file, not run a new iostat every x seconds
