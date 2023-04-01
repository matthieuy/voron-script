#!/usr/bin/env bash
#
# Installation de ADXL

source /home/pi/voron/modules/_common.sh

_log "=> ADXL : Compilation"
sudo echo "" > /dev/null
sudo apt install -y --no-install-recommends python3-numpy python3-matplotlib libatlas-base-dev
${HOME_DIR}/klippy-env/bin/pip install -v numpy 

exit 0