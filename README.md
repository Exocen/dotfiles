## ⚙️ Dotfiles
My configuration files, samples, and helpers

### 🪄 Automatic installation script

To automatically install my default environment run *install.sh* (POSIX Shell)

#### Run the script to
1. Install vim git htop iftop iotop tree zsh make wget sudo rsync curl
2. Set up zsh with ohmyzsh.git and the local configuration files (zsh will be switched as default shell)
3. Set up vim configuration files with plugins
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

Install testing tool available on *docker_conf/install_test*

### 📝 TODO
- [ ] Docker jdownloader : add container sleep/pause feature
- [ ] Docker tools fail2ban : use journald correctly + check everything
