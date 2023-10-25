#!/bin/bash
ping 1.1.1.1 -c 10 -q || exit 1
ping youtube.com -c 10 -q || exit 1
