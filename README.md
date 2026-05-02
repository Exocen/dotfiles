## ⚙️ Dotfiles
My configuration files, samples, and helpers

### 🪄 Automatic installation script

#### Run *install.sh* to
1. Install vim git htop iftop iotop tree zsh make wget curl sudo rsync p7zip
2. Set zsh config
3. Set vim config
4. (Optionnal Arch only) install my dev environment (WM included)

#### Usage
```
install.sh [OPTION]

    Options:
    -d     Use debug mode
    -l     Set log path (default $XDG_RUNTIME_DIR)
    -n     Skip all user interaction.  Implied 'No' to all actions.
    -h     Display this help and exit
```

#### Sample
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
