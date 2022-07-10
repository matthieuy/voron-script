#!/usr/bin/env bash
#
# Script vierge pour les upgrades (fichier à nommer avec ${VERSION_SCRIPT})

source /home/pi/voron/modules/_common.sh

# Upgrade en root
if [ '${whoami}' == 'root' ]; then
    break
else 
# Upgrade en user "pi"
    break
fi

_logUpgrade "Fin de l'upgrade"