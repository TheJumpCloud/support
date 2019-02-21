#### Name

Mac - Generic DMG Installer | v1.0 JCCG

#### commandType

mac

#### Command

```
# *** USAGE *** Version: 1.0

# Update the DownloadUrl="" variable with the URL of the target .DMG download file. This URL must resolve to a .DMG file directly or point to a URL which has the .DMG file in the curl header Location field.

# The command: 'curl -s --head $DownloadUrl' can be used to query a given URLs header to determine if the Location field points to a .DMG file.

# *NOTE* this template is only designed to work with DMG files and does not support .pkg or .zip files.

DownloadUrl=""

### Modify below this line at your own risk!

# Locate DMG Download Link From URL

regex='^https.*.dmg$'
if [[ $DownloadUrl =~ $regex ]]; then
    echo "URL points to direct DMG download"
    validLink="True"
else
    echo "Searching headers for download links"
    urlHead=$(curl -s --head $DownloadUrl)

    locationSearch=$(echo "$urlHead" | grep https:)

    if [ -n "$locationSearch" ]; then

        locationRaw=$(echo "$locationSearch" | cut -d' ' -f2)

        locationFormatted="$(echo "${locationRaw}" | tr -d '[:space:]')"

        regex='^https.*'
        if [[ $locationFormatted =~ $regex ]]; then
            echo "Download link found"
            DownloadUrl=$(echo "$locationFormatted")
        else
            echo "No https location download link found in headers"
            exit 1
        fi

    else

        echo "No location download link found in headers"
        exit 1
    fi

fi

#Create Temp Folder
DATE=$(date '+%Y-%m-%d-%H-%M-%S')

TempFolder="Download-$DATE"

mkdir /tmp/$TempFolder

# Navigate to Temp Folder
cd /tmp/$TempFolder

# Download File into Temp Folder
curl -s -O "$DownloadUrl"

# Capture name of Download File
DownloadFile="$(ls)"

echo "Downloaded $DownloadFile to /tmp/$TempFolder"

# Verifies DMG File
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
DMGMountPoint="$(hdiutil info | grep "$DMGVolume" | awk '{ print $1 }')"

echo "Located DMG Mount Point: $DMGMountPoint"

# Capture name of App file

cd "$DMGVolume"

AppName="$(ls | Grep .app)"

cd ~

echo "Located App: $AppName"

# Test to ensure App is not already installed

ExistingSearch=$(find "/Applications/" -name "$AppName" -depth 1)

if [ -n "$ExistingSearch" ]; then

    echo "$AppName already present in /Applications folder"
    hdiutil detach $DMGMountPoint
    echo "Used hdiutil to detach $DMGFile from $DMGMountPoint"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1

else

    echo "$AppName not present in /Applications folder"
fi

DMGAppPath=$(find "$DMGVolume" -name "*.app" -depth 1)

# Copy the contents of the DMG file to /Applications/
# Preserves all file attributes and ACLs
cp -pPR "$DMGAppPath" /Applications/

err=$?
if [ ${err} -ne 0 ]; then
    echo "Could not copy $DMGAppPath Error: ${err}"
    hdiutil detach $DMGMountPoint
    echo "Used hdiutil to detach $DMGFile from $DMGMountPoint"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

echo "Copied $DMGAppPath to /Applications"

# Unmount the DMG file
hdiutil detach $DMGMountPoint

echo "Used hdiutil to detach $DMGFile from $DMGMountPoint"

err=$?
if [ ${err} -ne 0 ]; then
    abort "Could not detach DMG: $DMGMountPoint Error: ${err}"
fi

# Remove Temp Folder and download
rm -r /tmp/$TempFolder

echo "Deleted /tmp/$TempFolder"
```

#### Description

Installs an application from the DMG file downloaded from the populated `DownloadUrl=""`

Update the `DownloadUrl=""` variable with the URL of the target .DMG download file.

This URL must resolve to a .DMG file directly or point to a URL which has the .DMG file in the curl header Location field.

The command: `'curl -s --head $DownloadUrl'` can be used to query a given URLs header to determine if the Location field points to a .DMG file.

Example usage to discovery if a link is valid:

```bash
DownloadUrl="https://slack.com/ssb/download-osx"

urlHead=$(curl -s --head $DownloadUrl)

echo "$urlHead"

HTTP/2 302
content-type: text/html
location: https://downloads.slack-edge.com/mac_releases/Slack-3.3.7.dmg
date: Tue, 12 Feb 2019 15:26:40 GMT
server: Apache
vary: Accept-Encoding
strict-transport-security: max-age=31536000; includeSubDomains; preload
referrer-policy: no-referrer
set-cookie: b=6gqj2tdhgqlzwcyej3xqf3ggr; expires=Mon, 12-Feb-2029 15:26:40 GMT; Max-Age=315619200; path=/; domain=.slack.com
set-cookie: x=6gqj2tdhgqlzwcyej3xqf3ggr.1549985200; expires=Tue, 12-Feb-2019 15:41:40 GMT; Max-Age=900; path=/; domain=.slack.com
x-frame-options: SAMEORIGIN
x-via: haproxy-www-k96c
x-cache: Miss from cloudfront
via: 1.1 7fd13f5c4b32635feca1c61001387a16.cloudfront.net (CloudFront)
x-amz-cf-id: dfJIoMiZC5NcFFwVtThZC4VuhMrIEddcS_8e6NhRkMUMhCK3S9SAZg==
```

The DownloadUrl="https://slack.com/ssb/download-osx" is valid becuase the location points to a .DMG direct download.

`location: https://downloads.slack-edge.com/mac_releases/Slack-3.3.7.dmg`

**NOTE** this template is only designed to work with DMG files and does not support .pkg or .zip files.

This command creates a temporary folder in the /tmp directory and to downloads the DMG file to this folder.

Next it mounts the DMG using `hdiutil attach` and verifies that the application in this volume does not already exist in the /Applications/ folder before coping the `.app` file to the /Applications/ folder.

Finally it cleans up the install by unmounting the DMG and deleting the temporary folder.

Each step is logged in the command result output of the JumpCloud command.

Find below example output from a successful command run:

```
Searching headers for download links
Download link found
Downloaded Slack-3.3.7.dmg to /tmp/Download-2019-01-23-10-28-49
DMG File Found: Slack-3.3.7.dmg
Used hdiutil to mount Slack-3.3.7.dmg 
Located DMG Volume: /Volumes/Slack.app
Located DMG Mount Point: /dev/disk2s1
Located App: Slack.app
Slack.app not present in /Applications folder
Copied /Volumes/Slack.app/Slack.app to /Applications
"disk2" unmounted.
"disk2" ejected.
Used hdiutil to detach Slack-3.3.7.dmg from /dev/disk2s1
Deleted /tmp/Download-2019-01-23-10-28-49
```

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/fhF4l'
```
