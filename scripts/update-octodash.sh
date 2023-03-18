#!/bin/bash

if [ -f /tmp/octodash.deb ]; then
    dpkg -i /tmp/octodash.deb
    rm /tmp/octodash.deb
fi
