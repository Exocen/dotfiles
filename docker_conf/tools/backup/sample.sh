#!/bin/bash

tar cvzf - /mail_server-data /ng-data /vw-data | gpg -c --passphrase test --pinentry-mode loopback > backdown
ls -l
gpg -d --pinentry-mode loopback --passphrase test backdown | tar -xvzf -
ls -l


ssh HOST sudo tar czf - /mail_server-data /vw-data /ng-data > test.tgz
