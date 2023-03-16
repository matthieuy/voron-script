#!/usr/bin/env bash
#
# Révoquer la clé SSH

#################
### VARIABLES ###
#################
IP="10.0.20.5"

# Params
if [ "$1" = "-h" ]; then
    echo "Usage : $0 [IP]"
    exit
fi
if [ -z "$1" ]; then
    read -p "IP [${IP}] :" IP_TMP
    if [ ! -z ${IP_TMP} ]; then
        IP=${IP_TMP}
    fi
else
  IP=$1
fi

echo ""
ssh-keygen -f ~/.ssh/known_hosts -R "${IP}"
