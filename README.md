## Automatic installation

Un repo utilisé pour faire une intallation automatique sur un nouveau poste

Installera de base les packets:

*vim vlc git htop iftop tree zsh*

### Configuration Emacs + Zsh

Fonctionne sur
* Ubuntu (>15 for emacs plugins)
* Fedora
* Debian
* Arch

Use oh-my-zsh repos [oh-my-zsh](https://github.com/exocen/oh-my-zsh.git)

La configuration se trouve dans les fichiers .zshrc et .emacs

### I3

Works on
* Fedora
* Ubuntu
* Arch Linux (on arch_linux branch)

###### Arch linux hercules dual pix webcam :
```shell
echo 'options uvcvideo quirks=0x100' | sudo tee -a /etc/modprobe.d/uvcvideo.conf
```

---

### TODO

* dovecot

* spamassassin

* crontab auto
````
MAILTO=

@monthly certbot --nginx renew
@weekly yaourt -Sya  > /dev/null 2>&1 && yaourt -Qu 2>/dev/null
````
* cv => gpg -do cv.tgz cv.tgz.gpg && extract cv.tgz

* ln -s /etc/ca-certificates/extracted/ca-bundle.trust.crt /etc/ssl/certs/ca-certificates.crt
