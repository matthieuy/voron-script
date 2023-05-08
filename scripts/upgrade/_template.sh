#!/usr/bin/env bash
#
# Script vierge pour les upgrades (fichier à nommer avec ${VERSION_SCRIPT})

source /home/pi/voron/modules/_common.sh
UPGRADE_NAME=`basename $0`

###################
# Upgrade en root #
###################
if [ '${whoami}' == 'root' ]; then
    # MàJ Crontab
    #_logUpgrade "[root] Màj Crontab"
    #cp -f ${SCRIPT_DIR}/conf/etc/cron.d/voron-cron /etc/cron.d/voron-cron
    #chmod +x /etc/cron.d/voron-cron

    # Màj Sudoers
    #_logUpgrade "[root] Màj sudoers"
    #cp -f ${SCRIPT_DIR}/conf/etc/sudoers.d/* /etc/sudoers.d/
    #chmod +x /etc/sudoers.d/*

    #_logUpgrade "[root] Fin de l'upgrade (v${UPGRADE_NAME})"
    #_logUpgrade "[root] Aucune action root pour cette mise à jour (v${UPGRADE_NAME})"

    # Necessite un reboot
    #echo "1" > ${NEED_REBOOT_UPGRADE}
else 
###################
# Upgrade en "pi" #
###################

    # Necessite un reboot
    #echo "1" > ${NEED_REBOOT_UPGRADE}

    #_logUpgrade "[user] Fin de l'upgrade (v${UPGRADE_NAME})"
fi
