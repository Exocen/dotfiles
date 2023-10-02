#!/bin/bash
certbot certificates | grep -P "\(VALID\:" || exit 1
service nginx status || exit 1
