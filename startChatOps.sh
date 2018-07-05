#!/bin/bash
# Comments: This script is prepared for OpenSuse Linux.
#
#
# startsbot.sh
# Start startsbot processes
#   first param is one of
#    - login
#    - chatbot
#    - config

# exit on errors
set -e

export sbot_MODE=$1

echo "Start sbot run mode: $sbot_MODE"


case "$sbot_MODE" in

  login)
    /opt/sbot/sbot-login/run.sh
  ;;

  chatbot)
    /opt/sbot/sbot-chatbot/run.sh
  ;;

  config)
    /opt/sbot/sbot-config/run.sh
  ;;

  *)
    echo "$sbot_MODE is not supported."
  ;;

esac
