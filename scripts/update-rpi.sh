#!/usr/bin/env bash
#
# Mise à jour du RPI
# /!\ Lancé en user pi sans sudo

source /home/pi/voron/modules/_common.sh

# PID
APT_PID=${SHARE_DIR}/update-encours.txt
if [ -e ${APT_PID} ]; then
  echo "Update en cours"
  exit 2
fi
touch APT_PID


# Update RPI
echo -e "Démarrer upgrade\n"
sudo apt update -q
sudo apt full-upgrade -y
sudo apt autoremove -y
echo -e "\nUpgrade terminé"


# Exit
rm ${APT_PID}
exit 0
