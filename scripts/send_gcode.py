#!/usr/bin/python3
#
# Send a gcode to print
#
# Exit code :
#   0 : OK
#   1 : NOK
#   2 : Print isn't ready (timeou)
#

import argparse
import time
import sys
from octoprint_class import Octoprint


# Argparser
parser = argparse.ArgumentParser(description="Send gcode")
parser.add_argument("--gcode", help="The gcode to send", required=True)
parser.add_argument("--timeout", metavar="SEC", help="Number of seconds before timeout", default=30, type=int)
parser.add_argument("--reconnect", help="Try to reconnect on error", default=False, action="store_true")
parser.add_argument("--debug", help="Enable debug mode", default=False, action="store_true")
args = parser.parse_args()
if args.debug:
    print("[DEBUG] Arguments : %s" % vars(args))

# Init octoprint
octoprint  = Octoprint(debug=args.debug)

# Check print status
status = octoprint.get_status()

# After klipper restart try to disconnect/connect before continue
if args.reconnect and status != octoprint.STATUS_OPERATIONAL:
    is_reconnect = False
    
    count = 0
    while True:
        # Bug after klipper restart : disconnect/connect (only once time)
        if not is_reconnect and status == octoprint.STATUS_SERIAL:
            octoprint.connect_print(True)  # Disconnect
            is_reconnect = octoprint.connect_print()  # Connect


        # Check connexion
        status = octoprint.get_status()
        if status == octoprint.STATUS_OPERATIONAL:
            break

        # Timeout
        time.sleep(1)
        count += 1
        if count >= args.timeout:
            break

# Check print status
if status != octoprint.STATUS_OPERATIONAL:
    if args.debug:
        print("Print isn't ready : %s" % status)
    sys.exit(2)

# Send gcode
result = octoprint.send_gcode(args.gcode)
if not result:
    sys.exit(1)

# Exit
sys.exit(0)
