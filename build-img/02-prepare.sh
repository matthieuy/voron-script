#!/usr/bin/env bash
#
# Preparer la carte SD pour le 1er boot

#################
### VARIABLES ###
#################
NEED_IMG="" # Vide pour non
source ./build-img/_build-common.sh
source ./modules/_common.sh

# Demontage des partitions si besoin
_umount_device

# Montage des partitions
mkdir -p ${BOOT_DIR}
mkdir -p ${ROOT_DIR}
if [[ ${DEVICE} == *"mmcblk"* ]]; then
    sudo mount ${DEVICE}p1 ${BOOT_DIR}
    sudo mount ${DEVICE}p2 ${ROOT_DIR}
else
    sudo mount ${DEVICE}1 ${BOOT_DIR}
    sudo mount ${DEVICE}2 ${ROOT_DIR}
fi

# Copie du fichier Wifi
if [ -f ${WIFI_CONF} ]; then
    _log "=> Copie du fichier de configuration Wifi"
    sudo cp -f ${WIFI_CONF} ${BOOT_DIR}/octopi-wpa-supplicant.txt
else
    echo -e "${RED}/!\ Pas de fichier de configuration Wifi detecte !${NC}"
fi

# Nettoyage de l'existant
_log "=> Nettoyage de la carte"
if [ -e ${ROOT_DIR}${SCRIPT_DIR} ]; then
    rm -rf ${ROOT_DIR}${SCRIPT_DIR}
fi
if [ -e ${ROOT_DIR}${SHARE_DIR} ]; then
    rm -rf ${ROOT_DIR}${SHARE_DIR}
fi

# Preparation des dossiers/sources
_log "=> Création des dossiers"
mkdir -p ${ROOT_DIR}${SCRIPT_DIR}
mkdir -p ${ROOT_DIR}${SHARE_DIR}

_log "=> Récupération des sources"
rsync -qa --progress ./ ${ROOT_DIR}${SCRIPT_DIR} --exclude out --exclude old
git -C ${ROOT_DIR}${SCRIPT_DIR} remote remove origin
git -C ${ROOT_DIR}${SCRIPT_DIR} remote add origin ${GIT_REPO}
git -C ${ROOT_DIR}${SCRIPT_DIR} checkout master
git -C ${ROOT_DIR}${SCRIPT_DIR} pull origin master
rm ${ROOT_DIR}${SCRIPT_DIR}/scripts/.env

_log "=> Applications des droits"
cp -rf ${ROOT_DIR}${SCRIPT_DIR}/scripts/* ${ROOT_DIR}${HOME_DIR}/scripts/
chmod +x ${ROOT_DIR}${HOME_DIR}/scripts/*
chmod +x ${ROOT_DIR}${SCRIPT_DIR}/modules/*
chmod +x ${ROOT_DIR}${SCRIPT_DIR}/build-img/*
rm ${ROOT_DIR}${HOME_DIR}/scripts/.env
cp ${ROOT_DIR}${HOME_DIR}/scripts/.env.dist ${HOME_DIR}/scripts/.env


# Date et heure
_log "=> Passage du RPI en Français"
_log "  => Timezone"
sudo cp -f conf/etc/timezone ${ROOT_DIR}/etc/timezone
sudo rm ${ROOT_DIR}/etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Paris ${ROOT_DIR}/etc/localtime
_log " => Clavier"
sudo cp -f conf/etc/default/keyboard ${ROOT_DIR}/etc/default/keyboard
sudo cp -f conf/etc/locale.gen ${ROOT_DIR}/etc/locale.gen

# Partition boot
_log "=> Boot config"
cp -f ${BOOT_DIR}/config.txt out/config.txt
cp -f ${BOOT_DIR}/config.txt out/config-$(date +%Y%m%d_%H%M).bak
cp -f ${BOOT_DIR}/cmdline.txt out/cmdline.txt
cp -f ${BOOT_DIR}/cmdline.txt out/cmdline-$(date +%Y%m%d_%H%M).bak
_log "  => NeoLed"
_add_to_file_if_doesnt_exist "out/config.txt" "core_freq_min=500"
sed -i "s/#dtparam=spi=on/dtparam=spi=on/" out/config.txt
_log "  => Led IDE"
_add_to_file_if_doesnt_exist "out/config.txt" "dtparam=act_led_gpio=14"
_log "  => Sondes"
_add_to_file_if_doesnt_exist "out/config.txt" "dtoverlay=w1-gpio"
_log "  => Splashscreen"
sudo sed -i "s/rootwait/rootwait logo.nologo loglevel=1 fbcon=rotate:2/" out/cmdline.txt
_add_to_file_if_doesnt_exist "out/config.txt" "disable_splash=1"
cat conf/octodash/boot-config.txt >> out/config.txt
_log "  => Octodash"
sudo sed -i "s/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/" out/config.txt
_log "  => ADXL"
sudo sed -i "s/#dtparam=spi=on/dtparam=spi=on/" out/config.txt
sudo cp -f out/config.txt ${BOOT_DIR}/config.txt
sudo cp -f out/cmdline.txt ${BOOT_DIR}/cmdline.txt


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
TMP_OUT="out/wq3"
if [ -e ${TMP_OUT} ]; then
    rm ${TMP_OUT}
fi
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION} -O ${TMP_OUT}
sudo cp ${TMP_OUT} ${ROOT_DIR}/usr/local/bin/yq3
sudo chmod +x ${ROOT_DIR}/usr/local/bin/yq3

# Klipper
_log "=> Klipper"

_log " => Nettoyage du klipper sur la carte"
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

_log "  => Copie des sources sur la carte"
cp -rf ${TMP_OUT} ${ROOT_DIR}${KLIPPER_DIR}

_log "  => Configuration"
cp -f conf/klipper/makeconfig.txt ${ROOT_DIR}${KLIPPER_DIR}/.config
cp -f conf/klipper/makeconfig.txt ${ROOT_DIR}${SHARE_DIR}/klipper-makeconfig.txt
cp -f conf/klipper/klipper-macro.txt ${ROOT_DIR}${SHARE_DIR}/klipper-macro.txt
cp -f conf/klipper/klipper-static.txt ${ROOT_DIR}${SHARE_DIR}/klipper-static.txt
cp -f conf/klipper/printer.cfg ${ROOT_DIR}${HOME_DIR}/printer.cfg
sudo cp -f conf/etc/default/klipper ${ROOT_DIR}/etc/default/klipper
touch ${ROOT_DIR}${SHARE_DIR}/variables.txt

_log "=> Scripts de MàJ"
_log " => Droits"
sudo cp -f conf/etc/sudoers.d/* ${ROOT_DIR}/etc/sudoers.d/
sudo chmod 440 ${ROOT_DIR}/etc/sudoers.d/*
_log " => Versionning"
mkdir -p $(dirname ${ROOT_DIR}${VERSION_FILE})
echo ${VERSION_SCRIPT} > ${ROOT_DIR}${VERSION_FILE}
echo ${VERSION_SCRIPT} > ${ROOT_DIR}${VERSION_FILE_ROOT}

# Fin de la préparation
_log "=> Fin de la préparation de la carte SD"
read -p "Démontage des partitions [Y/n] ?" CONFIRM
if [ "${CONFIRM}" != "n" ] && [ "${CONFIRM}" != "N" ]; then
  _log "  => Boot"
  sudo umount ${BOOT_DIR}
  rmdir ${BOOT_DIR}
  _log "  => Root"
  sudo umount ${ROOT_DIR}
  rmdir ${ROOT_DIR}
fi
_log "  => Synchro (etape un peu longue)"
sudo sync

echo ""
echo "Une fois le Raspberry démarré :"
echo " Lancez via SSH avec l'utilisateur pi :"
echo "cd ~/voron"
echo "./build-img/03-first-boot.sh"
echo ""
exit 0
