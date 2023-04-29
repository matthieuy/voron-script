#!/usr/bin/python3
#
# Wait octoprint is ready
#
# Exit code :
#   0 : Ready
#   1 : Disconnect (but ready)
#   10 : Timeout
#

import argparse
import time
import sys
from octoprint_class import Octoprint


# Argparser
parser = argparse.ArgumentParser(description="Wait the octoprint is ready")
parser.add_argument("--timeout", metavar="SEC", help="Number of seconds before timeout", default=30, type=int)
parser.add_argument("--interval", metavar="SEC", help="Number of seconds between check", default=1, type=int)
parser.add_argument("--debug", help="Enable debug mode", default=False, action="store_true")
args = parser.parse_args()
if args.debug:
    print("[DEBUG] Arguments : %s" % vars(args))

# Init octoprint
octoprint  = Octoprint(debug=args.debug)

# Start while
count = 0
exit_code = 0
while True:
    if args.debug:
        print("[DEBUG] Check status (%d / %d sec)" % (count, args.timeout))
    status = octoprint.get_status()

    # Print is ready
    if status == octoprint.STATUS_OPERATIONAL:
        exit_code = 0
        break
    elif status == octoprint.STATUS_CLOSED:
        exit_code = 1
        break

    # Sleep
    time.sleep(args.interval)
    count += args.interval

    # Timeout
    if count >= args.timeout:
        if args.debug:
            print("[DEBUG] Timeout")
        exit_code = 10
        break


if exit_code == 0:
    print("[DEBUG] Print is ready : %s" % status)
sys.exit(exit_code)

