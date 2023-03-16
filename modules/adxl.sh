#!/usr/bin/env bash
#
# Installation de ADXL

source /home/pi/voron/modules/_common.sh

_log "=> ADXL : Compilation"
sudo echo "" > /dev/null
${HOME_DIR}/klippy-env/bin/pip install -v numpy
sudo apt install -y --no-install-recommends python-numpy python-matplotlib

exit 0