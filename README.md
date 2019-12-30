## Automatic installation

Dotfiles + auto install for servers
([Openvpn](https://github.com/Exocen/OpenVPN-install) + [Https](https://github.com/exocen/Web-Mail-Server) + [Postfix](https://github.com/exocen/Web-Mail-Server))

### Emacs + Zsh config

Tested on
* Ubuntu 15+
* Fedora 29+
* Debian 8+
* Arch (+ i3 conf)
* Raspbian

Zsh config [oh-my-zsh](https://github.com/exocen/oh-my-zsh.git)

---

### TODO
* crontab -> systemctl timers
````
sudo EDITOR=vim crontab -e
````
````
MAILTO=""

@monthly certbot --nginx renew
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

* ln -s /etc/ca-certificates/extracted/ca-bundle.trust.crt /etc/ssl/certs/ca-certificates.crt

