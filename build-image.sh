#!/usr/bin/env bash
#
# Créer une image neuve d'octoprint sur la SD

#################
### VARIABLES ###
#################
source ./modules/_common.sh

# Check utilisateur
if [ '${whoami}' == 'root' ]; then
  echo "Ne lancez pas ce script en super-admin"
  exit
fi

# Flash de la SD
./build-image/01-flash-sd.sh


# Remontage
echo -e "${RED}Débranchez et rebranchez la carte SD${NC}"
read -p "Appuyer sur entrée une fois OK" 

# Preparation de la SD
./build-image/02-prepare.sh
