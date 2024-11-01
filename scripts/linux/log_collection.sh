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

version=1.0

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
If you agree to this, enter 'Y', or any other key to cancel." -n 1 -r
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


## Collect logs and information

# system information and logs
echo "Gathering system information."
hostnamectl 2>&1 > $baseDir/systemInfo/sysInfo.txt
/opt/jc/bin/jcosqueri --line "select * from users;" > $baseDir/systemInfo/osq_usersList.txt
last > $baseDir/systemInfo/last.txt

LOGS=(
    "syslog"
    "auth.log"
    "dmsg"
    "messages"
    "secure"
)

echo "Collecting system logs"
for LOG in "${LOGS[@]}"; do
    if [ -f /var/log/${LOG} ]; then
        cp /var/log/$LOG $baseDir/systemLogs/
        echo "Collected /var/log/$LOG"
    fi
done

iptables -L > $baseDir/systemInfo/firewall_rules.txt

# JC Information and Logs
echo "Collecting managed usernames"
grep -o '\"username\":\"\w*' /opt/jc/managedUsers.json | cut -d '"' -f 4 > $baseDir/jumpcloudInfo/managedUsers.txt

cat /opt/jc/policyConf.json | json_pp > $baseDir/jumpcloudInfo/policyConf.json

echo "Collecting JumpCloud Logs"
cp /var/log/jc* $baseDir/jumpcloudLogs/
cp -R /var/log/jumpcloud $baseDir/jumpcloudLogs/
cp /opt/jc/jcagentInstall.log $baseDir/jumpcloudLogs/
cp /opt/jc/version.txt $baseDir/jumpcloudInfo/
cp -R /opt/jc/policies $baseDir/jumpcloudInfo/

# Password Manager logs
for USER in $(ls /home/); do
    mkdir $baseDir/userLogs/$USER
    if [ -d /home/$USER/.config/JumpCloud\ Password\ Manager/logs ]; then
        cp -R /home/$USER/.config/JumpCloud\ Password\ Manager/logs $baseDir/userLogs/$USER/PWM
    fi

    if [ -d /home/$USER/.config/JumpCloud\ Password\ Manager/data/daemon/log ]; then
        cp -R /home/$USER/.config/JumpCloud\ Password\ Manager/data/daemon/log $baseDir/userLogs/$USER/PWM_Daemon
    fi
done

## Package up the archive

echo "Resetting gathered logs permissions"
chmod -R 444 $baseDir

## compress everything

echo "Compressing logs"
tar -czf "${hostDir}jc-logArchive-${sysId}-$datestamp.tar.gz" -C $baseDir .
chmod 444 ${hostDir}jc-logArchive-${sysId}-$datestamp.tar.gz

## Clean up uncompressed collection

echo "cleaning up."
rm -R $baseDir

echo "Please browse to /var/tmp to locate the log archive."