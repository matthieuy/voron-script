#!/bin/sh

xset s off
xset s noblank
xset -dpms

# Rotation de l'écran
# HDMI-1 (côté alim) : écran vever
# HDMI-2 (côté USB) : écran obi
DISPLAY=:0 xrandr --output HDMI-1 --rotate inverted
DISPLAY=:0 xrandr --output HDMI-2 --rotate inverted

DISPLAY=:0 xsetroot -solid black &
ratpoison&
LANG=fr_FR.UTF-8 octodash
#octodash
