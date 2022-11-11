#!/bin/bash

# Formatted date string
LDATE=$(date +%T-%d-%m-%Y)

# Formatted log output headers
LMESS="[$LDATE]: Message:"
LDISP="[$LDATE]: Display:"
LWARN="[$LDATE]: WARNING:"
LERRO="[$LDATE]: ERROR:  "

# Log output type: 'message'
EXIT_SCRIPT="$LMESS Exiting script..."
CLOSE_LOG_OUT="$LMESS Closing log output..."
BACKING_UP_XKEY_TIMING_OPTIONS="$LMESS Backing up existing X key timing options..."
XKEY_TIMINGS_BACKUP_SUCCESS="$LMESS Existing X key timing options backed up successfully!"
SETTING_NEW_XKEY_TIMINGS="$LMESS Setting new X key timings..."
NEW_XKEY_TIMINGS_SUCCESS="$LMESS Successfully configured new X key timings!"
INITIAL_XKEY_TIMINGS_RESTORE_SUCCESS="$LMESS Successfully restored old X key timings!"

# Log output type: 'display'
NO_XSERV_DETECTED="$LDISP No X server detected, assuming TTY."
XSERV_DETECTED="$LDISP X server detected, running xset configuration..."

# Log output type: 'warning'
WAYLAND_WARN="$LWARN Wayland is currently not supported. If you'd like to play this on Wayland, please (if it's even possible) set your key held delay to 100ms and key repeat rate to 8 per second."

# Log output type: 'error'
XKEY_TIMINGS_BACKUP_FAIL="$LERRO Failed to backup existing X key timing configuration, exiting."
NEW_XKEY_TIMINGS_FAIL="$LERRO Failed to configure new X key timings, exiting."
INITIAL_XKEY_TIMINGS_RESTORE_FAIL="$LERRO Failed to restore old X key timings, exiting."
