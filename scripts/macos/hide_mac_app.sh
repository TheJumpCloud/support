#!/usr/bin/env bash
if [[ "$UID" -ne 0 ]]; then
  (>&2 echo "Error: $0 must be run with root permissions.")
  exit 1
fi
defaults write /Library/LaunchAgents/com.jumpcloud.jcagent-tray Disabled -bool true
mkdir -p /opt/jc_user_ro
touch /opt/jc_user_ro/dont_show_tray_app
