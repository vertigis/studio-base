#!/bin/bash
set -e

mkdir -p .tmp
apt -y update
apt -y upgrade
apt -y install certbot gh nano python3 python3-aiohttp python3-ldap3 python3-cryptography python3-dnspython

if ! which docker > /dev/null; then
  curl -fsSL https://get.docker.com -o .tmp/get-docker.sh
  bash ./.tmp/get-docker.sh
fi

rm -rf .tmp
usermod -aG docker $SUDO_USER
