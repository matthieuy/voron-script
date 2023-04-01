#!/usr/bin/env bash
#
# Mise à jour de klipper
# /!\ Lancé en user pi sans sudo

source /home/pi/voron/modules/_common.sh
cd ${KLIPPER_DIR}

# PID
KLIPPER_PID=${SHARE_DIR}/klipper-encours.txt
if [ -e ${KLIPPER_PID} ]; then
  echo "Compilation Klipper déjà en cours..."
  exit 2
fi
echo "Compilation en cours" > ${KLIPPER_PID}

# Pull
git pull

# Install
./scripts/install-octopi.sh

# Make menuconfig
make clean
if [ -e ${SHARE_DIR}/klipper-makeconfig.txt ]; then
  cp -f ${SHARE_DIR}/klipper-makeconfig.txt ${KLIPPER_DIR}/.config
elif [ -e ${SCRIPT_DIR}/conf/klipper/makeconfig.txt ]; then
  cp -f ${SCRIPT_DIR}/conf/klipper/makeconfig.txt ${KLIPPER_DIR}/.config
fi

# Compile
make
cp -f ${KLIPPER_DIR}/out/klipper.bin ${SHARE_DIR}/firmware.bin

# Exit
rm ${KLIPPER_PID}
echo -e "\nCompilation terminée"
