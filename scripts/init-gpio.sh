#!/usr/bin/env bash
#
# Initialiser les GPIO (lors du boot)

# Pins
EXTRACTEUR=8
EXTRACTEUR_LED=21
BUZZER=9
TX=15
POWER=1
BTN_LED=0
BTN_SIGNAL=2
BTN_STOP=3
LED_RED=4
LED_GREEN=5
P6=22
P19=24

# Mode
gpio mode ${EXTRACTEUR} out
gpio mode ${BUZZER} out
gpio mode ${TX} out
gpio mode ${POWER} out
gpio mode ${BTN_LED} out
gpio mode ${BTN_SIGNAL} in
gpio mode ${BTN_STOP} in
gpio mode ${LED_RED} out
gpio mode ${LED_GREEN} out
gpio mode ${EXTRACTEUR_LED} out
gpio mode ${P6} in
gpio mode ${P19} in

# Allumage lors du lancement : non
gpio write ${POWER} 0
