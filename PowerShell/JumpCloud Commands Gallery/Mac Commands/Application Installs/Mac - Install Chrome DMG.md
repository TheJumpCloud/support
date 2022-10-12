#### Name

Mac - Install Chrome DMG | v1.0 JCCG

#### commandType

mac

#### Command

```
# DMG Download URL
DownloadUrl="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"

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

Installs Google Chrome from the DMG file available for download from the link: `https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg`.

This command creates a temporary folder in the /tmp directory and to downloads the DMG file to this folder.

Next it mounts the DMG using `hdiutil attach` and verifies that the application in this volume does not already exist in the /Applications/ folder before coping the `.app` file to the /Applications/ folder.

Finally it cleans up the install by unmounting the DMG and deleting the temporary folder.

Each step is logged in the command result output of the JumpCloud command.

Find below example output from a successful command run:

```
URL points to direct DMG download
Downloaded googlechrome.dmg to /tmp/Download-2019-01-23-10-26-09
DMG File Found: googlechrome.dmg
Used hdiutil to mount googlechrome.dmg
Located DMG Volume: /Volumes/Google Chrome
Located DMG Mount Point: /dev/disk2s2
Located App: Google Chrome.app
Google Chrome.app not present in /Applications folder
Copied /Volumes/Google Chrome/Google Chrome.app to /Applications
"disk2" unmounted.
"disk2" ejected.
Used hdiutil to detach googlechrome.dmg from /dev/disk2s2
Deleted /tmp/Download-2019-01-23-10-26-09
```


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -url 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Application%20Installs/Mac%20-%20Install%20Chrome%20DMG.md'
```
