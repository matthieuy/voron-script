#!/usr/bin/env bash
#
# Script pour faire un benchmark

source /home/pi/voron/modules/_common.sh
DIR_TMP=/tmp/benchmark

# Hdparm
_log "=> Hdparm"
_log "  => Lancement"
sudo hdparm -tT /dev/mmcblk0

# Sysbench
_log "=> Sysbench"
_log "  => Preparation du bench disque"
mkdir -p ${DIR_TMP}
cd ${DIR_TMP}
sysbench --file-test-mode=rndrw --test=fileio prepare
_log "  => Lancement du bench"
sysbench --file-test-mode=rndrw --test=fileio run
_log "  => Nettoyage"
cd ~
rm -rf ${DIR_TMP}