#!/bin/bash

###############
# This log collection script gathers:
# - All JumpCloud agent, service, policy, and installation logs.
# - System logs, including syslog or messages, auth.log or secure, and dmsg log files.
# - Usernames of JumpCloud managed users.
# - General system information (distribution, hostname, hardware architecture, kernel version)
###############


automate=false   # set to true if running via a JumpCloud command (recommended)


#######
# do not edit below
#######

version=1.0.2

## verify script is running as root.
if [ $(/usr/bin/id -u) -ne 0 ]
then
    echo "This script must be run as root."
    exit
fi

## verify system is enrolled in JumpCloud

if [ ! -e /opt/jc/jcagent.conf ]
then
    echo "System does not appear to be currently managed by JumpCloud - exiting."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1
fi

## Get Consent to collect information

if [[ ! $automate =~ "true" ]]
then
    read -p "This log collection script gathers:
- All JumpCloud agent, service, and installation logs.
- System logs, including syslog or messages, auth.log or secure, and dmsg log files.
- Usernames of JumpCloud managed users.
- General system information (distribution, hostname, hardware architecture, kernel version)
If you agree to this, enter 'Y', or any other key to cancel: " -n 1 -r
    echo    # move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo "Exiting script."
        [[ "$0" = "${BASH_SOURCE}" ]] && exit 1
    fi
fi

## Create the target directories for storing collected logs and archive and set up final archive name vars.

datestamp=$(date "+%Y%m%d")
hostDir="/var/tmp/"
baseDir="${hostDir}JumpCloudLogCollect"
mkdir -p {$baseDir/jumpcloudLogs,$baseDir/jumpcloudInfo,$baseDir/systemLogs,$baseDir/systemInfo,$baseDir/userLogs}
sysId=$(grep -o '"systemKey": *"[^"]*"' /opt/jc/jcagent.conf | grep -o '"[^"]*"$' | sed 's/\"//g')

# Setup Log output for Log Collection Script
collectionLogFile="${baseDir}/collection.log"
collectionLog() {
    echo "$1" | tee -a "$collectionLogFile"
}

# Also redirect standard errors to the collectionLog file
exec 2> >(tee -a "$collectionLogFile" >&2)


## Collect logs and information

# system information and logs
collectionLog "Gathering system information."
hostnamectl 2>&1 > $baseDir/systemInfo/sysInfo.txt
/opt/jc/bin/jcosqueryi --line "select * from users" > $baseDir/systemInfo/osq_usersList.txt
last > $baseDir/systemInfo/last.txt

LOGS=(
    "syslog"
    "auth.log"
    "dmsg"
    "messages"
    "secure"
    "apt/term.log"
    "apt/history.log"
    "dpkg.log"
)

collectionLog "Collecting system logs"
for LOG in "${LOGS[@]}"; do
    if [ -f /var/log/${LOG} ]; then
        cp /var/log/$LOG $baseDir/systemLogs/
        collectionLog "Collected /var/log/$LOG"
    fi
done

iptables -L > $baseDir/systemInfo/firewall_rules.txt

# List JumpCloud services currently running using systemd
collectionLog "Checking running JumpCloud services"
jumpcloudServices="$baseDir/jumpcloudInfo/activeJumpCloudServices.txt"
echo -e "Listing running JumpCloud services:\n" > $jumpcloudServices
systemctl list-units --type=service --all | grep -i 'jumpcloud' >> $jumpcloudServices

# In case JumpCloud services are running but not systemd services, listing running processes
echo -e "\n\nNow checking & listing running JumpCloud proccesses: \n" >> $jumpcloudServices
ps -aufx | grep -i 'jumpcloud' | grep -v grep >> $jumpcloudServices


# JC Information and Logs
collectionLog "Collecting managed usernames"
grep -o '\"username\":\"[^\"]*' /opt/jc/managedUsers.json | cut -d '"' -f 4 > $baseDir/jumpcloudInfo/managedUsers.txt

cat /opt/jc/policyConf.json | json_pp > $baseDir/jumpcloudInfo/policyConf.json

collectionLog "Collecting JumpCloud Logs"
cp /var/log/jc* $baseDir/jumpcloudLogs/
cp -R /var/log/jumpcloud $baseDir/jumpcloudLogs/
cp /opt/jc/jcagentInstall.log $baseDir/jumpcloudLogs/
cp /opt/jc/version.txt $baseDir/jumpcloudInfo/
cp -R /opt/jc/policies $baseDir/jumpcloudInfo/

# Password Manager logs
for USER in $(ls /home/); do
    homeDir="/home/$USER"
    mkdir $baseDir/userLogs/$USER

    # Password Manager logs
    if [ -d /home/$USER/.config/JumpCloud\ Password\ Manager/logs ]; then
        cp -R /home/$USER/.config/JumpCloud\ Password\ Manager/logs $baseDir/userLogs/$USER/PWM
    fi

    if [ -d /home/$USER/.config/JumpCloud\ Password\ Manager/data/daemon/log ]; then
        cp -R /home/$USER/.config/JumpCloud\ Password\ Manager/data/daemon/log $baseDir/userLogs/$USER/PWM_Daemon
    fi

    # Remote Assist logs
    if [ -d $homeDir/.config/JumpCloud-Remote-Assist/logs ]; then 
        cp -R $homeDir/.config/JumpCloud-Remote-Assist/logs/* $baseDir/jumpcloudLogs/RemoteAssist
    fi

    # list JumpCloud Device Certificate
    if command -v certutil &> /dev/null; then
        jcDeviceCert=$(certutil -d "sql:$homeDir/.pki/nssdb" -L 2>/dev/null | grep "JumpCloud Device Trust Certificate" | sed 's/ \+u,u,u$//' | sed 's/ \+CTu,CTu,CTu$//')
        if [ -n "$jcDeviceCert" ]; then
            certutil -d "sql:$homeDir/.pki/nssdb" -L -n "$jcDeviceCert" > "$baseDir/userLogs/$USER/deviceCert.txt"
            collectionLog "JumpCloud Device Trust Certificate found and processed for $USER"
        else
            # Certificate not found
            echo "A JumpCloud Device Trust Certificate was not found for the user: \"$USER\" - If expected, check and confirm Device Certificates is enabled for the organisation." > "$baseDir/userLogs/$USER/deviceCert.txt"
        fi
    else
        collectionLog "certutil not installed, device certificate check skipped for: \"$USER\""
    fi

done

## Package up the archive - execute bit for owner appears to be required for readability on macOS

collectionLog "Resetting gathered logs permissions"
chmod -R 766 $baseDir

## compress everything

collectionLog "Compressing logs"
tar -czf "${hostDir}jc-logArchive-${sysId}-$datestamp.tar.gz" -C $baseDir .
chmod 666 ${hostDir}jc-logArchive-${sysId}-$datestamp.tar.gz

## Clean up uncompressed collection

collectionLog "cleaning up."
rm -R $baseDir

echo "Please browse to /var/tmp to locate the log archive."