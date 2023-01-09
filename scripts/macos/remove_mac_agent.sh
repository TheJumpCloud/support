#!/bin/bash
if [[ $(id -u) -ne 0 ]]; then
  echo "Must run as root!"
  exit 1
fi

# Remove Remote Assist App
if [[ -d "/Applications/JumpCloud Remote Assist.app" ]];then
  echo "Removing JumpCloud Remote Assist Application"
  rm -rf "/Applications/JumpCloud Remote Assist.app"
fi
# Remove Service Account App
if [[ -d "/Applications/JumpCloudServiceAccount.app" ]];then
  echo "Removing JumpCloud Service Account Application"
  rm -rf "/Applications/JumpCloudServiceAccount.app"
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

# Remove opt/jc_user_ro directory and contents
if [[ -d "/opt/jc_user_ro" ]];then
  echo "Removing jc_user_ro directory"
  rm -rf "/opt/jc_user_ro"
fi

# get jumpcloud daemons and agents
jcDaemons=$(find /Library/LaunchDaemons -type f -iname "*jumpcloud*")
jcAgents=$(find /Library/LaunchAgents -type f -iname "*jumpcloud*")

# remove each matching daemon file
for daemon in $jcDaemons
do
  echo "Removing $daemon"
  rm -rf $daemon
done
# remove each matching agent file
for agent in $jcAgents
do
  echo "Removing $agent"
  rm -rf $agent
done
# verify no jumpcloud processes are still running. kill and straglers
# implemented in response to desk case #28825.
if (pgrep -fi "[j]umpcloud" &> /dev/null); then
  for proc in $(pgrep -fi "[j]umpcloud" 2> /dev/null); do
    kill -9 "${proc}"
  done
fi
