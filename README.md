## ⚙️ Dotfiles
My configuration files, samples, and helpers

### 🪄 Automatic installation script

#### Run *install.sh* to
1. Install vim git htop iftop iotop tree zsh make wget curl sudo rsync p7zip
2. Set zsh config
3. Set vim config
4. (Optionnal Arch only) install my full dev environment

#### Usage
```
install.sh [OPTIONS]

    Options:
    -d     Use debug mode
    -l     Set log path (default /tmp/install-dir)
    -n     Skip all user interaction.  Implied 'No' to all actions.
    -h     Print this help screen
```

#### Sample
![script_execution_sample](samples/sample.png)

#### Tested on
* Alpine
* Arch (wm conf 🐮 available)
* Debian 12+
* Fedora 40+
* Manjaro
* Ubuntu 24+
* Linux Mint 22+

Tested with *docker_conf/install_test*
