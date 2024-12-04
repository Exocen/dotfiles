# ⚙️ Dotfiles
My configuration files, samples, and helpers

## 🪄 Automatic installation script

*install.sh* is a script written with POSIX Shell created to\
install automnatically basic tools and set the user configuration

### Run the script install.sh to
1. Install vim git htop iftop iotop tree zsh make wget sudo rsync curl
2. Clone ohmyzsh.git and set the configuration files (zsh will be switched as default shell)
3. Set vim configuration files with plugins
4. (Optionnal Arch only) install packages from arch-package-list, and set the Windows manager (wayland + sway)

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
* Linux Mint 22+

Install testing tool available on *docker_conf/install_test*

## 📝 TODO
- [ ] docker nginx: fignoler le poro
- [X] Install script : differentiate aur packages
- [ ] Waybar : remake css
