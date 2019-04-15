#!/bin/bash
if [[ $(id -u) -ne 0 ]]; then
    echo "Must run as root!"
    exit 1
fi

AGENT_UNINSTALL_SCRIPT="/opt/jc/bin/removeAgent"

if [[ -f $AGENT_UNINSTALL_SCRIPT ]]; then
    chmod 0700 $AGENT_UNINSTALL_SCRIPT
    $AGENT_UNINSTALL_SCRIPT
    exit $?
fi

launchctl remove com.jumpcloud.darwin-agent
rm /Library/LaunchDaemons/com.jumpcloud.darwin-agent.plist

sw_vers -productVersion | cut -d'.' -f1-2  | grep '^10.9$' &> /dev/null
if [[ $? -ne 0 ]]; then
    security authorizationdb read system.login.console | \
        sed 's#<string>jumpcloud-loginwindow:invoke</string>#<string>loginwindow:login</string>#' | \
        security authorizationdb write system.login.console
fi

rm -rf /Library/Security/SecurityAgentPlugins/jumpcloud-loginwindow.bundle
rm -rf /opt/jc

# if the service account is present, delete it:
if (id -u _jumpcloudserviceaccount > /dev/null 2>&1); then
    dscl . -delete /Users/_jumpcloudserviceaccount
fi

# uninstall the tray-app
# first unload the app for all console users (logged in on UI)
for uid in $(ps -axo uid,args | grep -i "[l]oginwindow.app" | awk '{ print $1 }')
do
	if launchctl asuser "$uid" launchctl list 'com.jumpcloud.jcagent-tray' &> /dev/null; then
		launchctl bootout gui/"$uid" '/Library/LaunchAgents/com.jumpcloud.jcagent-tray.plist'
	fi
done
# then delete the app plist and app folder
rm /Library/LaunchAgents/com.jumpcloud.jcagent-tray.plist
rm -rf /Applications/Jumpcloud.app
