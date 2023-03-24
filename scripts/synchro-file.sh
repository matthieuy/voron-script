#!/usr/bin/env bash
#
# Synchro du dossier share
# /!\ Lancé via cron en user pi sans sudo

source /home/pi/voron/modules/_common.sh


mkdir -p ${SHARE_DIR}

# Klipper
_synchroFile ${KLIPPER_DIR}/out/klipper.bin ${SHARE_DIR}/klipper.bin
_synchroFile ${SHARE_DIR}/klipper-makeconfig.txt ${KLIPPER_DIR}/.config
_synchroFile ${SHARE_DIR}/octodash-theme.txt ${DASH_DIR}/custom-style.css
if [ ! -e ${SHARE_DIR}/klipper-macro.txt ]; then
  cp -f ${SCRIPT_DIR}/conf/klipper/klipper-macro.txt ${SHARE_DIR}/klipper-macro.txt
else
  _synchroFile ${SCRIPT_DIR}/conf/klipper/klipper-macro.txt ${SHARE_DIR}/klipper-macro.txt
fi

# Splashscreen
if [ ! -e ${SHARE_DIR}/splashscreen.png ]; then
  cp -f ${SCRIPT_DIR}/conf/splashscreen/splashscreen.png ${SHARE_DIR}/splashscreen.png
else
  _synchroFile ${SCRIPT_DIR}/conf/splashscreen/splashscreen.png ${SHARE_DIR}/splashscreen.png
fi

# Scripts
cp ${SCRIPT_DIR}/scripts/* /home/pi/scripts/
chmod +x /home/pi/scripts/*

# Suppression du PID de MàJ Klipper
if [ -e ${SHARE_DIR}/klipper-encours.txt ]; then
  rm -f ${SHARE_DIR}/klipper-encours.txt
fi