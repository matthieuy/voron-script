#!/usr/bin/env bash
#
# Installation des outils de dev
source /home/pi/voron/modules/_common.sh

# Install NPM
_log "=> Install NPM"
sudo apt update -q -y
sudo apt install -y --no-install-recommends nodejs npm

# TODO : Install assets
# TODO : Install forever