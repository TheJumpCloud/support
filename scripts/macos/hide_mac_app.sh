defaults write /Library/LaunchAgents/com.jumpcloud.jcagent-tray Disabled -bool true
mkdir -p /opt/jc_user_ro
touch /opt/jc_user_ro/dont_show_tray_app
PERMISSIONS="$(ls -l /opt/jc_user_ro/dont_show_tray_app | cut -c -10)"
if [ "$PERMISSIONS" != "-rw-r--r--" ]; then
        echo "Permissions not right for file:  $PERMISSIONS"
        exit 1
fi
