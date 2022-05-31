#!/usr/bin/env bash
#
# Preparer la carte SD pour le 1er boot

#################
### VARIABLES ###
#################
source ./modules/_common.sh


# Check utilisateur
if [ '${whoami}' == 'root' ]; then
  echo "Ne lancez pas ce script en super-admin"
  exit
fi



# Demande du device
if [ -z "$2" ]; then
    read -p "Device [${DEVICE}] :" DEVICE_TMP
    if [ ! -z ${DEVICE_TMP} ]; then
        DEVICE=${DEVICE_TMP}
    fi
fi
if [ ! -e ${DEVICE} ]; then
    echo "Périphérique introuvable"
    exit 2
fi

 
# Démontage si besoin
NB_MOUNT=$(mount | grep ^${DEVICE} | wc -l)
if [ ${NB_MOUNT} -ne 0 ]; then
	echo -e "=> Démontage des ${CYAN}${NB_MOUNT}${NC} partitions"
	mount | grep ^${DEVICE} | awk '{ print $1 }'|xargs umount
fi



# Montage
_log "=> Montage des partitions"
mkdir -p ${BOOT_DIR}
mkdir -p ${ROOT_DIR}
sudo mount ${DEVICE}1 ${BOOT_DIR}
sudo mount ${DEVICE}2 ${ROOT_DIR}



# Préparation des dossiers
_log "=> Création des dossiers"
mkdir -p ${ROOT_DIR}${SHARE_DIR}
mkdir -p ${ROOT_DIR}${SCRIPT_DIR}

_log "=> Récupération des sources"
rsync -av --progress ./ ${ROOT_DIR}${SCRIPT_DIR} --exclude out --exclude old
git -C ${ROOT_DIR}${SCRIPT_DIR} remote remove origin
git -C ${ROOT_DIR}${SCRIPT_DIR} remote add origin ${GIT_REPO}
git -C ${ROOT_DIR}${SCRIPT_DIR} branch --set-upstream-to=origin/main main
git -C ${ROOT_DIR}${SCRIPT_DIR} pull origin main

_log "  => Application des droits"
chmod +x ${ROOT_DIR}${HOME_DIR}/scripts/*
chmod +x ${ROOT_DIR}${SCRIPT_DIR}/modules/*
chmod +x ${ROOT_DIR}${SCRIPT_DIR}/build-image/*


# Date et heure
_log "=> Passage du RPI en Français"
_log "  => Timezone"
sudo cp -f conf/etc/timezone ${ROOT_DIR}/etc/timezone
sudo rm ${ROOT_DIR}/etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Paris ${ROOT_DIR}/etc/localtime
_log "  => Clavier"
sudo cp -f conf/etc/default/keyboard ${ROOT_DIR}/etc/default/keyboard
sudo cp -f conf/etc/locale.gen ${ROOT_DIR}/etc/locale.gen



# Boot config
_log "=> Boot config"
cp -f ${BOOT_DIR}/config.txt out/config.txt
cp -f ${BOOT_DIR}/cmdline.txt out/cmdline.txt
_log "  => NeoLed"
echo "core_freq_min=500" >> out/config.txt
sed -i "s/#dtparam=spi=on/dtparam=spi=on/" out/config.txt
_log "  => Led IDE"
echo "dtparam=act_led_gpio=14" >> out/config.txt
_log "  => Sondes"
echo "dtoverlay=w1-gpio" >> out/config.txt
_log "  => Splashscreen"
sudo sed -i "s/rootwait/rootwait logo.nologo loglevel=1 quiet/" ${BOOT_DIR}/cmdline.txt
echo "disable_splash=1" >> out/config.txt
_log "  => Octodash"
sudo sed -i "s/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/" out/config.txt
_log "  => ADXL"
sudo sed -i "s/#dtparam=spi=on/dtparam=spi=on/" out/config.txt
sudo cp -f out/config.txt ${BOOT_DIR}/config.txt

# Wifi
WIFI_CONF="conf/octopi-wpa-supplicant.txt"
if [ -f ${WIFI_CONF} ]; then
    _log "  => Copie du fichier de configuration Wifi"
    sudo cp -f ${WIFI_CONF} ${BOOT_DIR}/octopi-wpa-supplicant.txt
else
	_log "${RED}/!\ Pas de fichier de configuration Wifi détecter${NC}"
fi


# Script d'update
_log "=> Scripts"
_log "  => Script pour les mises à jour"
sudo cp -f conf/etc/sudoers.d/* ${ROOT_DIR}/etc/sudoers.d/
sudo chmod 440 ${ROOT_DIR}/etc/sudoers.d/*


# Oh my ZSH
_log "=> Oh My ZSH (récupération des sources)"
if [ -e ${ROOT_DIR}${HOME_DIR}/.oh-my-zsh ]; then
	_log "  => Suppression de la version existante"
	rm -rf ${ROOT_DIR}${HOME_DIR}/.oh-my-zsh
fi
TMP_OUT="out/oh-my-zsh"
if [ -e ${TMP_OUT} ]; then
	_log "  => Mise à jour des sources"
	git -C ${TMP_OUT} pull
else
	_log "  => Récupération des sources"
	git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ${TMP_OUT}
fi
_log "  => Copie des sources"
cp -rf ${TMP_OUT} ${ROOT_DIR}${HOME_DIR}/.oh-my-zsh
cp ${TMP_OUT}/templates/zshrc.zsh-template ${ROOT_DIR}${HOME_DIR}/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ${ROOT_DIR}${HOME_DIR}/.zshrc
sed -i 's/# ENABLE_CORRECTION/ENABLE_CORRECTION/' ${ROOT_DIR}${HOME_DIR}/.zshrc
sed -i 's/plugins=(/plugins=(autojump command-not-found sudo common-aliases debian /' ${ROOT_DIR}${HOME_DIR}/.zshrc


# YQ
_log "  => Yaml parser"
TMP_OUT="out/wq${YQ_VERSION}"
if [ ! -e ${TMP_OUT} ]; then
	wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_arm -O ${TMP_OUT}
fi
sudo cp ${TMP_OUT} ${ROOT_DIR}/usr/local/bin/yq3
sudo chmod +x ${ROOT_DIR}/usr/local/bin/yq3



# Klipper
_log "=> Klipper"

if [ -e ${ROOT_DIR}${KLIPPER_DIR} ]; then
	rm -rf ${ROOT_DIR}${KLIPPER_DIR}
fi
if [ -e ${ROOT_DIR}${KLIPPER_DIR}-env ]; then
	rm -rf ${ROOT_DIR}${KLIPPER_DIR}-env
fi
TMP_OUT="out/klipper"
if [ -e ${TMP_OUT} ]; then
	_log "  => Màj des sources"
	git -C ${TMP_OUT} pull
else
	_log "  => Récupération des sources"
	git clone https://github.com/KevinOConnor/klipper ${TMP_OUT}
fi
_log "  => Copie des sources"
cp -rf ${TMP_OUT} ${ROOT_DIR}${KLIPPER_DIR}
_log "  => Configuration"
cp -f conf/klipper/makeconfig.txt ${ROOT_DIR}${KLIPPER_DIR}/.config
cp -f conf/klipper/makeconfig.txt ${ROOT_DIR}${SHARE_DIR}/klipper-makeconfig.txt
cp -f conf/klipper/klipper-macro.txt ${ROOT_DIR}${SHARE_DIR}/klipper-macro.txt
cp -f conf/klipper/${KLIPPER_CONF_VERSION}.txt ${ROOT_DIR}${HOME_DIR}/printer.cfg
cp -f conf/klipper/klipper-static_${KLIPPER_CONF_VERSION}.txt ${ROOT_DIR}${SHARE_DIR}/klipper-static.txt

if [ 0 -ge 1 ]; then
# Configuration octoprint de base
_log "=> Configuration de l'API"
API_KEY=$(head -c16 </dev/urandom|xxd -p -u)
echo -e "${CYAN}  => Génération d'une clé : ${RED}${API_KEY}${NC}"
_preconfig api.enabled true "Activation"
_preconfig api.allowCrossOrigin true
_preconfig api.key ${API_KEY}
_preconfig accessControl.salt $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
_preconfig server.secretKey $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
mkdir -p ${ROOT_DIR}${HOME_DIR}/.octoprint/printerProfiles
cp -f conf/voron.profile ${ROOT_DIR}${HOME_DIR}/.octoprint/printerProfiles/_default.profile

#/oprint/bin/octoprint config effective
_log "=> Configuration octoprint"
_preconfig appearance.name ${HOSTNAME}
_preconfig feature.sdSupport false "Désactivation de la carte SD"
_preconfig plugins.tracking.enabled true "Tracking"
_preconfig server.firstRun false "Désactivation de l'assistance"
_preconfig server.pluginBlacklist.enabled true "Blacklist"
_preconfig appearance.components.disabled.usersettings[0] plugin_appkeys
_preconfig appearance.components.disabled.navbar[0] login
_log "  => Online check"
_preconfig server.onlineCheck.enabled true
_preconfig server.onlineCheck.host "185.121.177.177"
_log "  => Désactivation des plugins inutiles"
_preconfig plugins._disabled[0] errortracking "ErrorTracking"
_preconfig plugins._disabled[1] cura "Cura"
fi


# Fin de la préparation
_log "=> Fin de la préparation de la carte SD"
mkdir -p $(dirname ${ROOT_DIR}${VERSION_FILE})
echo ${VERSION_SCRIPT} > ${ROOT_DIR}${VERSION_FILE}
read -p "Démontage des partitions [Y/n] ?" CONFIRM
if [ "${CONFIRM}" != "n" ] && [ "${CONFIRM}" != "N" ]; then
  echo "Etapes un peu longues..."
  _log "  => Boot"
  sudo umount ${BOOT_DIR}
  _log "  => Root"
  sudo umount ${ROOT_DIR}
  _log "  => Synchro"
  sudo sync
fi

exit 0
