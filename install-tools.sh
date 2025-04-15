#!/bin/bash
set -e

mkdir -p .temp
apt -y update
apt -y upgrade
apt -y install gh nano

if ! which az > /dev/null; then
  curl -fsSL https://aka.ms/InstallAzureCLIDeb -o .temp/get-az.sh
  bash ./.temp/get-az.sh
fi

if ! which docker > /dev/null; then
  curl -fsSL https://get-docker.com -o .temp/get-docker.sh
  bash ./.temp/get-docker.sh
fi

rm -rf .temp
usermod -aG docker $SUDO_USER
