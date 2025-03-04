#!/bin/bash



automate=false   # set to true if running via a JumpCloud command (recommended)
days=2           # number of days of OS logs to gather



#######
# do not edit below
#######

version=1.2

## verify script is running as root.
if [ $(/usr/bin/id -u) -ne 0 ]
then
    echo "This script must be run as root."
    exit
fi

### Get Consent to collect information

if [[ ! $automate =~ "true" ]]
then
    read -p "This log collection script gathers:
- All JumpCloud agent, service, and installation logs
- JumpCloud logging recorded in the macOS system logs for the past ${days} days
- Currently installed configuration profiles
- MDM triggered software installations for the past ${days} days (Appstore, VPP and Custom Software)
- Filevault and secure token information (no passwords or secrets are collected)
- Usernames of JumpCloud managed users
If you agree to this, enter 'Y', or any other key to cancel." -n 1 -r
    echo    # move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo "Exiting script."
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1
    fi
fi

datestamp=$(date "+%Y%m%d")
hostDir="/private/var/tmp/"
baseDir="${hostDir}JumpCloudLogCollect"
sysId=$(grep -o '"systemKey": *"[^"]*"' /opt/jc/jcagent.conf | grep -o '"[^"]*"$' | sed 's/\"//g')

## Change directory to save log archive depending on active user state

if [[ $(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }') ]]; then
    localuser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
    archiveTargetDir="/Users/${localuser}/Documents/"
else
    archiveTargetDir="/private/var/tmp/"
fi

## verify system is enrolled in JumpCloud

if [ ! -e /opt/jc/jcagent.conf ]
then
    echo "System does not appear to be currently managed by JumpCloud - exiting."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1
fi

## verify bash has full disk access
if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null ; then
    echo "Full Disk Access required for bash operations. Please add '/bin/bash' to Full Disk Access or apply the bash_fda configuration profile."
    exit 1
fi


## Create directories for log collection
mkdir -p {$baseDir/jumpcloud_logs,$baseDir/systemLogs,$baseDir/systemInfo,$baseDir/userLogs}

echo "Gathering all JumpCloud agent and process Logs..."

## gather JumpCloud system logs (agent, install, patch management)
for f in /var/log/jc*.log*
do
    cp $f $baseDir/jumpcloud_logs/
done

if [ -d /var/log/jumpcloud ]
then
    cp -r /var/log/jumpcloud $baseDir/jumpcloud_logs/
fi

if [ -d /var/log/jumpcloud-loginwindow ]
then
    cp -r /var/log/jumpcloud-loginwindow $baseDir/jumpcloud_logs/
fi

## Set permissions for gathered logs
chmod -R 777 $baseDir

## pull jumpcloud log entries from the system logs
echo "Gathering jumpcloud logs from macOS system logs"
log show --last ${days}d --predicate="eventMessage CONTAINS[c] 'jumpcloud'" > $baseDir/systemLogs/jumpcloud_syslog.log
log show --last ${days}d --debug --info --style compact --predicate 'senderImagePath CONTAINS[c] "JCLoginPlugin"' > $baseDir/systemLogs/SSAP_LoginWindow_events.log
log show --last ${days}d --predicate="process CONTAINS[c] 'DurtService' || process CONTAINS[c] 'JumpCloudGo'" > $baseDir/systemLogs/JumpCloudGo_events.log

## pull patch management logs
echo "Gathering profiles & OS Patch Management settings"
profiles show -o stdout > $baseDir/installedProfiles.txt

softwareupdate --list > $baseDir/systemInfo/SoftwareUpdateList.txt 2>&1

defaults read /Library/Preferences/com.apple.SoftwareUpdate > $baseDir/com.apple.SoftwareUpdate.plist 2>&1

if [ -e /Library/Preferences/com.jumpcloud.Nudge.json ]; then
    cp /Library/Preferences/com.jumpcloud.Nudge.json $baseDir/systemInfo/com.jumpcloud.Nudge.json
fi

## Only run if a user is actually logged in
if [[ $localuser ]]; then

    ## pull additional patch management information
    sudo -u $localuser defaults read com.github.macadmins.Nudge.plist > $baseDir/com.github.macadmins.Nudge.plist 2>&1

    ## list jumpcloud services currently running on the system
    sudo -u $localuser launchctl print system | grep -i 'jumpcloud' > $baseDir/systemInfo/activeJumpCloudServices.txt

    ## list JumpCloud Device Certificate
    if sudo -u "$localuser" security find-certificate -c "JumpCloud Device Trust Certificate" -p > /dev/null 2>&1; then
        sudo -u $localuser security find-certificate -c "JumpCloud Device Trust Certificate" -p | openssl x509  -text > $baseDir/systemInfo/deviceCert.txt
        echo "JumpCloud Device Trust Certificate found and processed."
    else
    # Certificate not found
        echo "JumpCloud Device Trust Certificate not found." > $baseDir/systemInfo/deviceCert.txt
    fi

fi

## gather relevent system logs for software installs
echo "Gathering software installation logs"
log show --last ${days}d --predicate="process CONTAINS[c] 'appstored'" > $baseDir/systemLogs/appstored.log
cp /var/log/install.log* $baseDir/systemLogs/

## list secure tokens and filesystem information
echo "Gathering filesystem and secure token information"
fdesetup list > $baseDir/systemInfo/secureTokenList.txt
diskutil apfs list > $baseDir/systemInfo/diskReport.txt

## list managed usernames
echo "finding managed users"
grep -o '\"username\":\"[^\"]*\"' /opt/jc/managedUsers.json | cut -d '"' -f 4 > $baseDir/systemInfo/managedUsers.txt

## descend into managed user's homedirs (requires full disk access) and gather JumpCloud logs
for u in $(cat $baseDir/SystemInfo/managedUsers.txt); do
    echo "pulling logs from user $u"
    mkdir $baseDir/userLogs/$u

    if [ -d /Users/$u/Library/Logs/JumpCloud\ Password\ Manager ]; then
        cp -r /Users/$u/Library/Logs/JumpCloud\ Password\ Manager $baseDir/userLogs/$u/
    fi

    if [ -d /Users/$u/Library/Application\ Support/JumpCloud\ Password\ Manager/data/daemon/log ]; then
        cp -r /Users/$u/Library/Application\ Support/JumpCloud\ Password\ Manager/data/daemon/log $baseDir/userLogs/$u/PWM_daemon_logs
    fi

    if [ -d /Users/$u/Library/Logs/JumpCloud-Remote-Assist ]; then
        cp -r /Users/$u/Library/Logs/JumpCloud-Remote-Assist $baseDir/userLogs/$u/
    fi

    if [ -d /Users/$u/Library/Logs/JumpCloud ]; then
        cp -r /Users/$u/Library/Logs/JumpCloud $baseDir/userLogs/$u/
    fi

    # report on any user scope configuration profiles
    sudo -u $u profiles -L -o stdout > $baseDir/userLogs/$u/installedProfiles.txt

done

# check for and gather remote assist logs from root homedir

if [ -d /var/root/Library/Logs/JumpCloud-Remote-Assist ]; then
    mkdir $baseDir/userLogs/root
    cp -r /var/root/Library/Logs/JumpCloud-Remote-Assist $baseDir/userLogs/root/
fi

echo "Resetting gathered logs permissions"
chmod -R 777 $baseDir

## compress everything
echo "Compressing logs"
tar -czf "${archiveTargetDir}jc-logArchive-${sysId}-$datestamp.tar.gz" -C $baseDir .
chmod 777 ${archiveTargetDir}jc-logArchive-${sysId}-$datestamp.tar.gz

echo "cleaning up."
rm -R $baseDir

if [[ $localuser ]]; then
    sudo -u $localuser open $archiveTargetDir
    echo "Log archive has been saved to the current user's Documents folder."
else
    echo "Please log in locally on the device and open /var/tmp to locate the log archive.
You may run the command 'open /var/tmp' in the macOS Terminal to do this."
fi