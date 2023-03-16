#!/usr/bin/env bash
#
# Mise à jour du RPI
# /!\ Lancé en user pi sans sudo (voir le sudoers)

source /home/pi/voron/modules/_common.sh

# PID
APT_PID=${SHARE_DIR}/update-encours.txt
if [ -e ${APT_PID} ]; then
  echo "Update en cours (${APT_PID})"
  exit 2
fi
touch APT_PID

# Update RPI
echo -e "Démarrer upgrade\n" | tee -a ${APT_PID}
sudo apt update -q  | tee -a ${APT_PID}
sudo apt full-upgrade -y  | tee -a ${APT_PID}
sudo apt autoremove -y | tee -a ${APT_PID}
echo -e "\nUpgrade terminé" | tee -a ${APT_PID}

# TODO : Mettre à jour le code git

# Exit
rm ${APT_PID}
exit 0