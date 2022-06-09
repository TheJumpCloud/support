#!/bin/bash

# Install script for Tenable agent for Mac. Assumes the .dmg file is publicly shared in a Gdrive folder. Set vars for the unique FILEID below.
# Tested with NessusAgent-10.1.3.dmg
# *NOTE* this template is only designed to work with DMG files and does not support .pkg, .zip files or DMGs that contain .pkg installers.
# Run as root in JumpCloud

#################################################
# VARS - Edit as necessary
###
export FILEID=xxxxxxx
export FILENAME=tenable.dmg

export TENABLE_LINKING_KEY=xxxxxx
export DOMAIN=acme.com
export DEVICE_GROUP=mac_hosts
###
#################################################

# Create Temp Folder
#
DATE=$(date '+%Y-%m-%d-%H-%M-%S')
TempFolder="Download-$DATE"
mkdir /tmp/$TempFolder

# Navigate to Temp Folder
#
cd /tmp/$TempFolder


# Download tenable binary from Gdrive folder. Must use a publicly shared link, and you need the fieldid from it.
# See this URL for how to get the fileid value:  https://bytesbin.com/how-to-download-a-large-file-from-google-drive-quickly
#
curl -L -c cookies.txt 'https://docs.google.com/uc?export=download&id='$FILEID | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt
curl -L -b cookies.txt -o $FILENAME 'https://docs.google.com/uc?export=download&id='$FILEID'&confirm='$(<confirm.txt)
rm -f confirm.txt cookies.txt

# Capture name of Download File
#
DownloadFile="$(ls)"
echo "Downloaded $DownloadFile to /tmp/$TempFolder"

# Verifies DMG File
#
regex='\.dmg$'
if [[ $DownloadFile =~ $regex ]]; then
    DMGFile="$(echo "$DownloadFile")"
    echo "DMG File Found: $DMGFile"
else
    echo "File: $DownloadFile is not a DMG"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

# Mount DMG File -nobrowse prevents the volume from popping up in Finder
#
hdiutilAttach=$(hdiutil attach /tmp/$TempFolder/$DMGFile -nobrowse)
echo "Used hdiutil to mount $DMGFile "

err=$?
if [ ${err} -ne 0 ]; then
    echo "Could not mount $DMGFile Error: ${err}"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

regex='\/Volumes\/.*'
if [[ $hdiutilAttach =~ $regex ]]; then
    DMGVolume="${BASH_REMATCH[@]}"
    echo "Located DMG Volume: $DMGVolume"
else
    echo "DMG Volume not found"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

# Identify the mount point for the DMG file
#
DMGMountPoint="$(hdiutil info | grep "$DMGVolume" | awk '{ print $1 }')"
echo "Located DMG Mount Point: $DMGMountPoint"

# cd to directory where .pkg file is mounted to from the .dmg (which has spaces, so need to escape and hardcode)
#
cd /Volumes/Nessus\ Agent\ Install

# Now install the agent
#
installer -pkg /Volumes/Nessus\ Agent\ Install/Install\ Nessus\ Agent.pkg -target /Applications

# Create user name var for enrolling nessus agent in Tenable IO
#
HOSTID=$(hostname | sed 's/ /_/g' | sed 's/\.local//g')
echo "Host ID is: $HOSTID"

# Enroll agent to Tenable.IO
# Assumes you have a device group (e.g. mac_hosts), a host value (e.g. acme.com), and a tenable linking key.
#
/Library/NessusAgent/run/sbin/nessuscli agent link --key=$TENABLE_LINKING_KEY --host=$DOMAIN --groups=$DEVICE_GROUP --name=$HOSTID --cloud

# Unmount the DMG file
#
hdiutil detach $DMGMountPoint

# Remove Temp Folder and download
#
rm -r /tmp/$TempFolder
echo "Deleted /tmp/$TempFolder"
