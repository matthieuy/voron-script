#!/usr/bin/env bash
#
# Test de la led bicolor

LED_RED=4
LED_GREEN=5
TIME=1

gpio mode ${LED_RED} out
gpio mode ${LED_GREEN} out

# Rouge
gpio write ${LED_RED} 1
gpio write ${LED_GREEN} 0
sleep ${TIME}

# Orange (rouge+vert)
gpio write ${LED_RED} 1
gpio write ${LED_GREEN} 1
sleep ${TIME}

# Vert
gpio write ${LED_RED} 0
gpio write ${LED_GREEN} 1
sleep ${TIME}