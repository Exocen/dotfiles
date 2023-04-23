config:
 user.user-data: |
    #cloud-config
    package_update: true
    packages:
      - git
    users:
    - default
    - name: tester
      lock_passwd: false
      groups: users
      shell: /bin/bash
      sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - [cd, /home/tester]
        - [git, clone, --branch, Strix, --depth, 1,  https://github.com/exocen/dotfiles]
        - [chown, -R, tester:users, dotfiles]
        - [runuser, -l, tester, -c, '~/dotfiles/auto-install -y']
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
# lxc profile create cloud-profile && cat cloud-profile1.profile | lxc profile edit cloud-profile
