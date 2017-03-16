#!/bin/bash

# This script will enable filevault if not enabled, and add the users specified in fvusers.plist to filevault
# It is meant to be used by system admins and should be run as root
# fvusers.plist is a sample plist file. All passwords mentioned in the plist should be cleartext.
# For security purpose, make sure the plist file is deleted and users change their password post filevault configuration.

set -e

STATUS_STR="FileVault is On."
ENABLED_MSG="Please reboot to complete the process"
USERADD_MSG="User added to filevault"
enabled=1
fvStatus=`fdesetup status`

if [[ $STATUS_STR != $fvStatus ]]; then
	fdesetup enable -inputplist < fvusers.plist
	enabled=0
else
	fdesetup add -inputplist < fvusers.plist
fi
retcode=$?
echo "status: "$retcode
if [[ $retcode -eq 0 ]]; then
	msg=$([ "$enabled" == 0 ] && echo "$ENABLED_MSG" || echo "$USERADD_MSG")
	echo $msg
else
	echo "Error occurred"
fi