#!/bin/bash

# count_username_entries_in_group() takes 2 parameters; first is the username, second is the groupname
# it returns the integer count.
count_username_entries_in_group() {
  local username="$1"
  local groupname="$2"
  dscl . -read "/Groups/${groupname}" GroupMembership | grep -o "${username}" | wc -l | awk '{print $1}'
}

# remove_username_from_group() takes 2 parameters; first is the username, second is the groupname
# it will remove the username from the group, even if there are multiple entries.
remove_username_from_group() {
  local username="$1"
  local groupname="$2"
  local current_username_entry_count
  current_username_entry_count="$(count_username_entries_in_group "${username}" "${groupname}")"
  while [[ "${current_username_entry_count}" -gt 0 ]]; do
    local previous_username_entry_count="${current_username_entry_count}"
    local last_output
    last_output="$(dscl . -delete "/Groups/${groupname}" GroupMembership "${username}")"
    current_username_entry_count="$(count_username_entries_in_group "${username}" "${groupname}")"
    if [[ "${current_username_entry_count}" -ge "${previous_username_entry_count}" ]]; then
      print_to_stderr "Username[${username}] not deleted from Group[${groupname}]. Delete Command Output[${last_output}]"
      return 1
    fi
  done
  return 0
}

remove_user_device_trust_db() {
  local userhome="$1"
  local keychainpath="${userhome}/Library/Keychains/jumpcloud-device-trust-keychain-db"

  # Check if the path exists
  if [[ -e "{$keychainpath}" && -f "${keychainpath}" ]]; then
    echo "Removing file ${keychainpath}"
    rm -f "${keychainpath}"
  else
      echo "Keychain ${keychainpath} does not exist."
  fi
}

if [[ $(id -u) -ne 0 ]]; then
  echo "Must run as root!"
  exit 1
fi

# Remove Remote Assist App
if [[ -d "/Applications/JumpCloud Remote Assist.app" ]];then
  rm -rf "/Applications/JumpCloud Remote Assist.app"
fi
# Remove Service Account App
if [[ -d "/Applications/JumpCloudServiceAccount.app" ]];then
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

launchctl remove com.jumpcloud.agent-updater
rm /Library/LaunchDaemons/com.jumpcloud.agent-updater.plist

launchctl remove com.jumpcloud.JumpCloudGoHelper
rm /Library/LaunchDaemons/com.jumpcloud.JumpCloudGoHelper.plist

sw_vers -productVersion | cut -d'.' -f1-2 | grep '^10.9$' &>/dev/null
# disable warning against checking return status indirectly
# shellcheck disable=SC2181
if [[ $? -ne 0 ]]; then
  security authorizationdb read system.login.console |
    sed 's#<string>jumpcloud-loginwindow:invoke</string>#<string>loginwindow:login</string>#' |
    sed 's#<string>JCLoginPlugin:LoginWindow</string>#<string>loginwindow:login</string>#' |
    sed '\#<string>JCLoginPlugin:SystemControl,privileged</string>#d' |
    sudo security authorizationdb write system.login.console
fi

# if the service account is present, delete it:
if (id -u _jumpcloudserviceaccount > /dev/null 2>&1); then
  dscl . -delete /Users/_jumpcloudserviceaccount
fi

remove_username_from_group "${SERVICE_ACCOUNT_USERNAME}" admin

# remove the device trust keychain db for all JC managed user
for userdir in /Users/*; do
  if [[ -d "${userdir}" ]] &&
    [[ "${userdir}" != "/Users/Shared" &&
    "${userdir}" != "/Users/Guest" &&
    "${userdir}" != "/Users/root" &&
    "${userdir}" != "/Users/.localized" ]]; then
      remove_user_device_trust_db "${userdir}"
  fi
done

# remove JC password policy
pwpolicy clearaccountpolicies

# uninstall the tray-app and user agent
# first unload the app for all console users (logged in on UI)
# disable suggestion to use pgrep; we need to parse 'ps' output here
# shellcheck disable=SC2009
for uid in $(ps -axo uid,args | grep -i "[l]oginwindow.app" | awk '{ print $1 }'); do
  if launchctl asuser "${uid}" launchctl list 'com.jumpcloud.jcagent-tray' &>/dev/null; then
    launchctl bootout gui/"${uid}" '/Library/LaunchAgents/com.jumpcloud.jcagent-tray.plist'
  fi

  if launchctl asuser "${uid}" launchctl list "com.jumpcloud.user-agent" &> /dev/null; then
    launchctl bootout gui/"${uid}" '/Library/LaunchAgents/com.jumpcloud.user-agent.plist'
  fi

  if launchctl asuser "${uid}" launchctl list "com.jumpcloud.JumpCloudGo" &> /dev/null; then
    launchctl bootout gui/"${uid}" '/Library/LaunchAgents/com.jumpcloud.JumpCloudGo.plist'
  fi
done

launchctl remove com.jumpcloud.user-agent

# then delete the app plists and app folder
rm /Library/LaunchAgents/com.jumpcloud.jcagent-tray.plist
rm /Library/LaunchAgents/com.jumpcloud.user-agent.plist
rm /Library/LaunchAgents/com.jumpcloud.JumpCloudGo.plist
rm -rf /Applications/Jumpcloud.app
rm -rf /Applications/JumpCloudServiceAccount.app

# this should have already been handled by the agent itself but make sure that JC PAM auth is removed
if [ -f /etc/pam.d/authorization ]; then
  sed -i '.bak' '/jcagent/d' /etc/pam.d/authorization
  rm -f /etc/pam.d/authorization.bak
fi

if [ -f /etc/pam.d/screensaver ]; then
  sed -i '.bak' '/jcagent/d' /etc/pam.d/screensaver
  rm -f /etc/pam.d/screensaver.bak
fi

if [ -f /etc/pam.d/screensaver_new ]; then
  sed -i '.bak' '/jcagent/d' /etc/pam.d/screensaver_new
  rm -f /etc/pam.d/screensaver_new.bak
fi

if [ -f /etc/pam.d/screensaver_la ]; then
  sed -i '.bak' '/jcagent/d' /etc/pam.d/screensaver_la
  rm -f /etc/pam.d/screensaver_la.bak
fi

if [ -f /etc/pam.d/screensaver_new_la ]; then
  sed -i '.bak' '/jcagent/d' /etc/pam.d/screensaver_new_la
  rm -f /etc/pam.d/screensaver_new_la.bak
fi

rm -f /usr/local/lib/security/libpam_jcagent.so

# verify no jumpcloud processes are still running. kill and straglers
# implemented in response to desk case #28825.
if (pgrep -fi "[j]umpcloud" &> /dev/null); then
  for proc in $(pgrep -fi "[j]umpcloud" 2> /dev/null); do
    kill -9 "${proc}"
  done
fi

rm -rf /Library/Security/SecurityAgentPlugins/JCLoginPlugin.bundle
rm -rf /Library/Security/SecurityAgentPlugins/jumpcloud-loginwindow.bundle
rm -rf /Library/PrivilegedHelperTools/com.jumpcloud.JumpCloudGoHelper
rm -rf /opt/jc
rm -rf /opt/jc_user_ro

exit 0
