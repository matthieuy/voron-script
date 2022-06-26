#!/usr/bin/env bash
#
# 

source /home/pi/voron/modules/_common.sh

# Upgrade en root
if [ '${whoami}' == 'root' ]; then
    _logUpgrade "Modification du fichier de boot"
    cp -f /boot/config.txt /boot/config.txt_backup2022062601
    cp -f ${SCRIPT_DIR}/conf/boot-config.txt /boot/config.txt
    _logUpgrade "Nouveau splashcreen"
    cp -f ${SCRIPT_DIR}/share/splashscreen ${SHARE_DIR}/splashscreen.png
else 
    # Upgrade en user "pi"
    _logUpgrade "Rotation HDMI-2"
    DISPLAY=:0 xrandr --output HDMI-2 --rotate inverted
    cat ${SCRIPT_DIR}/conf/octodash/dot.xinitrc > ${HOME_DIR}/.xinitrc
fi

_logUpgrade "Fin de l'upgrade"