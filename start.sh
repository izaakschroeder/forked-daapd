#!/bin/sh -e

dbus-daemon --fork --system
avahi-daemon --daemonize

forked-daapd -fc /etc/forked-daapd.conf
