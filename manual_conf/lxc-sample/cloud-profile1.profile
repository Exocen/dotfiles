config:
 user.user-data: |
    #cloud-config
    package_update: true
    packages:
      - git
    users:
    - default
    - name: exo
      lock_passwd: false
      groups: users
      shell: /bin/bash
      sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - [cd, /home/exo]
        - [git, clone, --branch, Strix, --depth, 1,  https://github.com/exocen/dotfiles]
        - [chown, -R, exo, dotfiles]
        - [chgrp, -R, users, dotfiles]
        - [runuser, -l, exo, -c, '~/dotfiles/auto-install']
description: Cloud LXD profile
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
name: default
used_by: []
