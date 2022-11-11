#!/bin/bash

# Script exit handler
trap EXIT_RUNTIME 1 2 3 6 15

# Relevant directories
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/log-output-resources.sh

# Script stopped function
EXIT_RUNTIME () {
  if [ $IS_USING_XSERV = 1 ]; then
    XKEY_TIMINGS -WcFs
  fi    
  LOG_OUT "$EXIT_SCRIPT"
  LOG_OUT "$CLOSE_LOG_OUT"
  exit 1
}

XKEY_TIMINGS () {
  case $1 in
    -WcFS)
      if xset r rate 100 8; then
        LOG_OUT "$NEW_XKEY_TIMINGS_SUCCESS"
      else
        LOG_OUT "$NEW_XKEY_TIMINGS_FAIL"
        EXIT_RUNTIME
      fi
      ;;
    -WcFs)
      if [ $INITIAL_XKEY_TIMINGS_STORED = 1 ]; then
        if xset r rate $(sed -n '1p' $SCRIPT_DIR/xkey-timings-storage) $(sed -n '2p' $SCRIPT_DIR/xkey-timings-storage); then
          LOG_OUT "$INITIAL_XKEY_TIMINGS_RESTORE_SUCCESS"
        else
          LOG_OUT "$INITIAL_XKEY_TIMINGS_RESTORE_FAIL"
        fi
      else
        LOG_OUT "$INITIAL_XKEY_TIMINGS_RESTORE_FAIL"
      fi
      ;;
    -WsFc)
      if echo -e "$(xset q | grep 'repeat delay:' | awk '{print $4}')\n$(xset q | grep 'repeat delay:' | awk '{print $7}')" > $SCRIPT_DIR/xkey-timings-storage; then
        LOG_OUT "$XKEY_TIMINGS_BACKUP_SUCCESS"
        INITIAL_XKEY_TIMINGS_STORED=1
      else
        LOG_OUT "$XKEY_TIMINGS_BACKUP_FAIL"
        INITIAL_XKEY_TIMINGS_STORED=0
        EXIT_RUNTIME
      fi
      ;;
    -c1)
      echo "$(xset q | grep 'repeat delay:' | awk '{print $4}')"
      ;;
    -c2)
      echo "$(xset q | grep 'repeat delay:' | awk '{print $7}')"
      ;;
    -s1)
      echo "$(sed -n '1p' $SCRIPT_DIR/xkey-timings-storage)"
      ;;
    -s2)
      echo "$(sed -n '2p' $SCRIPT_DIR/xkey-timings-storage)"
  esac
}

# Log output function
LOG_OUT () {
  echo "$1" >> $SCRIPT_DIR/log-output.log
}

# Initial setup
if xset q 2>&1 >/dev/null | grep "unable to open display" >/dev/null; then
  IS_USING_XSERV=0
  LOG_OUT "$NO_XSERV_DETECTED"
  LOG_OUT "$WAYLAND_WARN"
else
  IS_USING_XSERV=1
  LOG_OUT "$XSERV_DETECTED"
  LOG_OUT "$BACKING_UP_XKEY_TIMING_OPTIONS"
  XKEY_TIMINGS -WsFc
  LOG_OUT "$SETTING_NEW_XKEY_TIMINGS"
  XKEY_TIMINGS -WcFS
fi

# Main loop
while sleep 0.1; do
  if [ $IS_USING_XSERV = 1 ]; then
    if [ $(xwininfo -id $WINDOWID | grep "xwininfo: Window id:" | awk '{print $4}') = $(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}') ]; then
      if [ $(XKEY_TIMINGS -c1) = $(XKEY_TIMINGS -s1) ] && [ $(XKEY_TIMINGS -c2) = $(XKEY_TIMINGS -s2) ]; then
        XKEY_TIMINGS -WcFS 
        echo -e "$(XKEY_TIMINGS -c1) $(XKEY_TIMINGS -s1)\n$(XKEY_TIMINGS -c2)   $(XKEY_TIMINGS -s2)"
      fi
    else   
      if [ $(XKEY_TIMINGS -c1) != $(XKEY_TIMINGS -s1) ] && [ $(XKEY_TIMINGS -c2) != $(XKEY_TIMINGS -s2) ]; then
        XKEY_TIMINGS -WcFs
        echo -e "$(XKEY_TIMINGS -c1) $(XKEY_TIMINGS -s1)\n$(XKEY_TIMINGS -c2)  $(XKEY_TIMINGS -s2)"
      fi
    fi
  fi
done
