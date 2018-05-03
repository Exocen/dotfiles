## Automatic installation

Dotfiles + auto install for servers
([Openvpn](https://github.com/Exocen/OpenVPN-install) + [Https](https://github.com/exocen/Web-Mail-Server/) + [Postfix](https://github.com/exocen/Web-Mail-Server) + [Hangoutbot](https://github.com/exocen/hangoutsbot))

### Emacs + Zsh config

Tested on
* Ubuntu (14+)
* Fedora
* Debian
* Arch
* Raspbian

Use oh-my-zsh repos [oh-my-zsh](https://github.com/exocen/oh-my-zsh.git)

### I3 config

Tested on
* Fedora
* Ubuntu (14+)
* Arch Linux

###### Arch linux hercules dual pix webcam :
```shell
echo 'options uvcvideo quirks=0x100' | sudo tee -a /etc/modprobe.d/uvcvideo.conf
```

---

### TODO

* crontab auto
````
sudo EDITOR=vim crontab -e
````
````
MAILTO=""

@monthly certbot --nginx renew
#@weekly yaourt -Sya  > /dev/null 2>&1 && yaourt -Qu 2>/dev/null #NOT SECURE
````

* DNS Sample
````
$TTL 3600
@	IN SOA stuff. stuff. (2017122200 86400 3600 3600000 300)
                             IN NS     ns200.anycast.me.
                             IN NS     dns200.anycast.me.
                             IN MX 1   HOSTNAME.
                             IN A      ipHost
                         600 IN TXT    "v=spf1 mx -all"
_dmarc                       IN TXT    "v=DMARC1; p=none"
mail                         IN A      ipHost
myselector._domainkey        IN TXT    ( "v=DKIM1; k=rsa; s=email; p=value" )
www                          IN CNAME  HOSTNAME.
````

* cv => gpg -do cv.tgz cv.tgz.gpg && extract cv.tgz

* ln -s /etc/ca-certificates/extracted/ca-bundle.trust.crt /etc/ssl/certs/ca-certificates.crt
