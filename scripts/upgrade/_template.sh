#!/usr/bin/env bash
#
# Script vierge pour les upgrades (fichier à nommer avec ${VERSION_SCRIPT})

source /home/pi/voron/modules/_common.sh

# Lancer en root ou non
RUN_AS_ROOT=0
if [ '${whoami}' == 'root' ]; then
    RUN_AS_ROOT=1
fi
