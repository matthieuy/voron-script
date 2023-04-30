#!/usr/bin/env bash
#
# 2023043000 : Ajout du fichier /etc/sudoers.d/reboot qui permet le reboot/halt sans mdp

source /home/pi/voron/modules/_common.sh

###################
# Upgrade en root #
###################
if [ '${whoami}' == 'root' ]; then
    # MàJ Crontab
    #_logUpgrade "Màj Crontab"
    #cp -f ${SCRIPT_DIR}/conf/etc/cron.d/voron-cron /etc/cron.d/voron-cron
    #chmod +x /etc/cron.d/voron-cron

    # Màj Sudoers
    _logUpgrade "Màj sudoers (ajout du reboot)"
    cp -f ${SCRIPT_DIR}/conf/etc/sudoers.d/* /etc/sudoers.d/
    chmod +x /etc/sudoers.d/*

    #_logUpgrade "Fin de l'upgrade (en root)"
    #_logUpgrade "Aucune action root pour cette mise à jour"

    # Necessite un reboot
    #echo "1" > ${NEED_REBOOT_UPGRADE}
else 
###################
# Upgrade en "pi" #
###################

    # Necessite un reboot
    echo "1" > ${NEED_REBOOT_UPGRADE}

    #_logUpgrade "Fin de l'upgrade (utilisateur standard)"
fi
