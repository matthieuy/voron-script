#!/usr/bin/env bash
#
# Mise à jour de klipper + recompilation
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

# Récupération des sources + install
git pull
./scripts/install-octopi.sh

#  make menuconfig
make clean
if [ -e ${SHARE_DIR}/klipper-makeconfig.txt ]; then
  cp -f ${SHARE_DIR}/klipper-makeconfig.txt ${KLIPPER_DIR}/.config
elif [ -e ${SCRIPT_DIR}/conf/klipper/makeconfig.txt ]; then
  cp -f ${SCRIPT_DIR}/conf/klipper/makeconfig.txt ${KLIPPER_DIR}/.config
else
  echo "Aucun fichier makeconfig trouvé"
  exit 2
fi

# Compilation
make
cp -f ${KLIPPER_DIR}/out/klipper.bin ${SHARE_DIR}

# Exit
rm -f ${KLIPPER_PID}
echo -e "\nCompilation terminée"
