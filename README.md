## Automatic installation

Un repo utilisé pour faire une intallation automatique sur un nouveau poste

Installera de base les packets:

*vim vlc git htop iftop tree zsh*

### Configuration Emacs + Zsh

Fonctionne sur
* Ubuntu (>15 for emacs plugins)
* Fedora
* Debian

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


TODO
TODO i3 block
+thx anachron


accepted
I solved it by setting up a DNS Server on the raspberry.

For that I did:

Set up a static IP on my raspberry
Installed dnsmasq and set it up according to this article: https://www.raspberrypi.org/forums/viewtopic.php?t=46154 I've used the /etc/dnsmasq.conf file provided in this article but adjusted the following:

#the domain to be accesses from outside and inside
domain=mydomain.ddns.net

resolv-file=/etc/resolv.dnsmasq  
min-port=4096

#Google's DNS Server:
server=8.8.8.8 

# Max cache size dnsmasq can give us, and we want all of it!    
cache-size=10000    

# Below are settings for dhcp. Comment them out if you dont want    
# dnsmasq to serve up dhcpd requests.    
dhcp-range=192.168.0.101,192.168.0.149,255.255.255.0,1440m    
dhcp-option=3,192.168.0.100    
dhcp-authoritative
I've uncommented the lines about the DHCP, wich made the raspberry accessable. How DHCP and DNS are related in this context I didn't quite understand, but since it's working this way I didn't research further.
added to /etc/hosts on the raspberry the following line, so that my domain will internally be resolved towards the static IP of my raspberry.
192.168.0.100   mydomain.ddns.net 