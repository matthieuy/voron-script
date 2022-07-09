#!/usr/bin/python

# Import
import RPi.GPIO as GPIO
from time import sleep
import subprocess

#################
### VARIABLES ###
#################

# Global
DEBUG = False
VERBOSE = True

# Pins
PIN_BTN = 27 # GPIO27 or 13 physical
PIN_LED = 17 # GPIO17 or 11 physical

# Interval
TIMER_REBOOT_RPI = 2
TIMER_HALT_RPI = 5
TIMER_NOTHING = 10
INTERVAL_CHECK = 0.2


#############
### SETUP ###
#############
GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN_BTN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(PIN_LED, GPIO.OUT)


#################
### FUNCTIONS ###
#################
def switch_led(switch_on):
    if switch_on:
        GPIO.output(PIN_LED, GPIO.HIGH)
    else:
        GPIO.output(PIN_LED, GPIO.LOW)

def button_press(channel):
    TIMER_PRESS = 0
    I_LED = 0
    while True:
        if GPIO.input(PIN_BTN) == False: # Button is press
            TIMER_PRESS += INTERVAL_CHECK
            I_LED += 1

            if TIMER_PRESS >= TIMER_NOTHING:
                switch_led(False)
            elif TIMER_PRESS > TIMER_HALT_RPI:
                switch_led((I_LED % 2 == 0))
            elif TIMER_PRESS > TIMER_REBOOT_RPI:
                switch_led((I_LED % 3) == 0)
        else: # Button was release : count timer
            switch_led(True)

            if TIMER_PRESS >= TIMER_NOTHING:
                if VERBOSE:
                    print("Action : Cancel")
            elif TIMER_PRESS > TIMER_HALT_RPI:
                if VERBOSE:
                    print("Action : Halt")
                if not DEBUG:
                    subprocess.call(['shutdown -h now "Arret du systeme par bouton GPIO" &'], shell=True)
            elif TIMER_PRESS > TIMER_REBOOT_RPI:
                if VERBOSE:
                    print("Action : Reboot")
                if not DEBUG:
                    subprocess.call(['shutdown -r now "Reboot du systeme par bouton GPIO" &'], shell=True)
            elif TIMER_PRESS != 0:
                if VERBOSE:
                    print("Press : " + str(TIMER_PRESS))

            # Reset
            TIMER_PRESS = 0
            I_LED = 0

        sleep(INTERVAL_CHECK)


###########
### RUN ###
###########
# Event
GPIO.add_event_detect(PIN_BTN, GPIO.FALLING, callback=button_press, bouncetime=200)
GPIO.output(PIN_LED, GPIO.HIGH)

# Do stuff
try:
	while True:
		sleep(2)
except KeyboardInterrupt:
	GPIO.cleanup()

# Exit
GPIO.cleanup()
