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
PIN_LED_BTN = 17 # GPIO17 or 11 physical
PIN_LED_RED = 23 # GPIO23 or 16 physical
PIN_LED_GREEN = 24 # GPIO24 or 18 physical

# Interval
TIMER_REBOOT_RPI = 2
TIMER_HALT_RPI = 5
TIMER_NOTHING = 10
INTERVAL_CHECK = 0.2

# Status
STATUS_LED_RED = False
STATUS_LED_GREEN = False

#############
### SETUP ###
#############
GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN_BTN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(PIN_LED_BTN, GPIO.OUT)
GPIO.setup(PIN_LED_GREEN, GPIO.OUT)
GPIO.setup(PIN_LED_RED, GPIO.OUT)


#################
### FUNCTIONS ###
#################
def switch_led(switch_on):
    '''
    Switch the led button
    :param bool switch_on: on or off
    '''
    if switch_on:
        GPIO.output(PIN_LED_BTN, GPIO.HIGH)
    else:
        GPIO.output(PIN_LED_BTN, GPIO.LOW)

def button_press(channel):
    TIMER_PRESS = 0
    I_LED = 0
    STATUS_LED_RED = GPIO.input(PIN_LED_RED)
    STATUS_LED_GREEN = GPIO.input(PIN_LED_GREEN)

    while True:
        if GPIO.input(PIN_BTN) == False: # Button is press
            TIMER_PRESS += INTERVAL_CHECK
            I_LED += 1

            if TIMER_PRESS >= TIMER_NOTHING:
                switch_led(False)
                GPIO.output(PIN_LED_RED, GPIO.LOW)
                GPIO.output(PIN_LED_GREEN, GPIO.HIGH)
            elif TIMER_PRESS > TIMER_HALT_RPI:
                switch_led((I_LED % 2 == 0))
                GPIO.output(PIN_LED_RED, GPIO.HIGH)
                GPIO.output(PIN_LED_GREEN, GPIO.LOW)
            elif TIMER_PRESS > TIMER_REBOOT_RPI:
                switch_led((I_LED % 3) == 0)
                GPIO.output(PIN_LED_RED, GPIO.HIGH)
                GPIO.output(PIN_LED_GREEN, GPIO.HIGH)
        else: # Button was release : count timer
            # Restore front LED
            GPIO.output(PIN_LED_RED, STATUS_LED_RED)
            GPIO.output(PIN_LED_GREEN, STATUS_LED_GREEN)

            # Turn on led button
            switch_led(True)

            # Counter time
            if TIMER_PRESS >= TIMER_NOTHING:
                if VERBOSE:
                    print("Action : Cancel")
            elif TIMER_PRESS > TIMER_HALT_RPI:
                if VERBOSE:
                    print("Action : Halt")
                if not DEBUG:
                    subprocess.call(['sudo shutdown -h now "Arret du systeme par bouton GPIO" &'], shell=True)
            elif TIMER_PRESS > TIMER_REBOOT_RPI:
                if VERBOSE:
                    print("Action : Reboot")
                if not DEBUG:
                    subprocess.call(['sudo shutdown -r now "Reboot du systeme par bouton GPIO" &'], shell=True)
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
GPIO.output(PIN_LED_BTN, GPIO.HIGH)
GPIO.output(PIN_LED_GREEN, GPIO.LOW)
GPIO.output(PIN_LED_RED, GPIO.LOW)

# Do stuff
try:
	while True:
		sleep(2)
except KeyboardInterrupt:
	GPIO.cleanup()

# Exit
GPIO.cleanup()
