#!/usr/bin/env bash
#
# Script pour faire un benchmark

source /home/pi/voron/modules/_common.sh
DIR_TMP=/tmp/benchmark

# Hdparm
_log "=> Hdparm"
_log "  => Lancement"
sudo hdparm -tT /dev/sda

# Sysbench
_log "=> Sysbench"
_log "  => Preparation du bench disque"
mkdir -p ${DIR_TMP}
cd ${DIR_TMP}
sysbench fileio prepare
_log "  => Lancement du bench"
sysbench fileio --file-test-mode=rndrw run
