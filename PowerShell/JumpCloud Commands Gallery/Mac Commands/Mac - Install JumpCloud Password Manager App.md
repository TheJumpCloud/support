#### Name

Mac - Install and Update JumpCloud Password Manager App | v2.0.1 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
# This script will install password manager in Users/$user/Applications for all user accounts based on their architecture (x64 or arm64)
# Set LaunchAfterInstall to true ON LINE 4 if you wish to launch the password manager after installation
LaunchAfterInstall=true

# Set UpdateToLatest to true if you want to update to the latest version of JumpCloud Password Manager
# Set UpdateToLatest to false if you want to re-install the JumpCloud Password Manager no matter your current version.
# ********** DISCLAIMER: Setting UpdateToLatest to $false will NOT affect any user data **********
UpdateToLatest=true


DownloadUrl="https://cdn.pwm.jumpcloud.com/DA/release/JumpCloud-Password-Manager-latest.dmg"
DownloadYamlFileUrl="https://cdn.pwm.jumpcloud.com/DA/release/latest-mac.yml"

# Detect device architecture
DeviceArchitecture=$(uname -m)


if [ "$DeviceArchitecture" = "arm64" ]; then
    DownloadUrl="https://cdn.pwm.jumpcloud.com/DA/release/arm64/JumpCloud-Password-Manager-latest.dmg"
    DownloadYamlFileUrl="https://cdn.pwm.jumpcloud.com/DA/release/arm64/latest-mac.yml"
fi

# Kill any existing JumpCloud Password Manager processes
killall "JumpCloud Password Manager"

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

if [ -d /Applications/JumpCloud\ Password\ Manager.app ]; then
    # If JumpCloud Password Manager exists within this directory, force re-install as it is in the wrong directory
    # the script will continue and re-install it in the correct directory
    UpdateToLatest=false
fi

LatestAppVersion=$(curl -s "$DownloadYamlFileUrl" | \
                grep '^version:' | \
                sed -E 's/version:\s*//g' | \
                tr -d '\r' | \
                xargs)

# Array to track users who need update/reinstall
users_need_update=()
if [ "$UpdateToLatest" = true ]; then
    for user in $(dscl . list /Users | grep -vE 'root|daemon|nobody|^_')
    do
        APP_PATH="/Users/$user/Applications/JumpCloud Password Manager.app"
        InstalledAppVersion=$(mdls -name kMDItemVersion "$APP_PATH" 2>/dev/null | awk -F '"' '{print $2}')
        if [ -z "$InstalledAppVersion" ]; then
            echo "Could not determine installed app version from '$APP_PATH' for $user."
            echo "User $user will be treated as a re-install."
            users_need_update+=("$user")
            # Skipping over the current user will prevent unnecessary logic handling.
            continue
        fi

        if [[ "$(printf '%s\n%s\n' "$InstalledAppVersion" "$LatestAppVersion" | sort -V | head -n1)" = "$InstalledAppVersion" && "$InstalledAppVersion" != "$LatestAppVersion" ]]; then
            echo "Installed app ($InstalledAppVersion) is OLDER than the latest available ($LatestAppVersion)."
            users_need_update+=("$user")
        elif [[ "$(printf '%s\n%s\n' "$InstalledAppVersion" "$LatestAppVersion" | sort -V | tail -n1)" = "$InstalledAppVersion" && "$InstalledAppVersion" != "$LatestAppVersion" ]]; then
            echo "Installed app ($InstalledAppVersion) is NEWER than the latest available ($LatestAppVersion)."
            echo "This might indicate a beta version."
            continue
        else
            echo "Installed app is already the LATEST version ($InstalledAppVersion) for $user."
            continue
        fi
    done
fi

if [ "$UpdateToLatest" = true ] && [ ${#users_need_update[@]} -eq 0 ]; then
    echo "All users are up to date, exiting."
    exit 0
fi

echo "Downloading JumpCloud Password Manager from $DownloadUrl"
# Download File into Temp Folder
curl -s -O "$DownloadUrl"

echo "Download complete."
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


DMGAppPath=$(find "$DMGVolume" -name "*.app" -depth 1)

userInstall=false

for user in $(dscl . list /Users | grep -vE 'root|daemon|nobody|^_')
do
    APP_PATH="/Users/$user/Applications/JumpCloud Password Manager.app"
    if [[ -d /Users/$user ]]; then
        # Create ~/Applications folder
        if [[ ! -d /Users/$user/Applications ]]; then
            mkdir /Users/$user/Applications
        fi
        if [[ -d $APP_PATH ]]; then
            # remove if exists
            rm -rf $APP_PATH
        fi

        # Copy the contents of the DMG file to /Users/$user/Applications/
        # Preserves all file attributes and ACLs
        cp -pPR "$DMGAppPath" /Users/$user/Applications/

        # Change ownership of the file and Applications folder to the user of this loop iteration
        chown -v "$user" /Users/$user/Applications
        chown -R -v "$user" "$APP_PATH" >/dev/null 2>&1 || true
        echo "Changed ownership of $APP_PATH and /Users/$user/Applications to $user"

        if [[ -d /Users/$user/Desktop/JumpCloud\ Password\ Manager.app ]]; then
            # remove alias on desktop if exists
            rm -rf /Users/$user/Desktop/JumpCloud\ Password\ Manager.app
        fi

        err=$?
        if [ ${err} -ne 0 ]; then
            echo "Could not copy $DMGAppPath Error: ${err}"
            hdiutil detach $DMGMountPoint
            echo "Used hdiutil to detach $DMGFile from $DMGMountPoint"
            rm -r /tmp/$TempFolder
            echo "Deleted /tmp/$TempFolder"
            exit 1
        fi

        userInstall=true
        echo "Copied $DMGAppPath to /Users/$user/Applications"
        if [ "$LaunchAfterInstall" = true ]; then
            sudo -u "$user" open "$APP_PATH" >/dev/null 2>&1 || true
        fi
        # Create an alias on desktop
        ln -s "$APP_PATH" "/Users/$user/Desktop/JumpCloud Password Manager.app"
    fi
done


# Check if password manager is installed in /Applications; remove if we installed in user directory
if [ -d /Applications/JumpCloud\ Password\ Manager.app ] && [ $userInstall = true ]; then
    # remove if exists
    rm -rf /Applications/JumpCloud\ Password\ Manager.app
fi

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


exit
```

#### Description

This command will download and install the JumpCloud Password Manager to the device if it isn't already installed. On slower networks, timeouts with exit code 127 can occur. Manually setting the default timeout limit to 600 seconds may be advisable.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
$command = Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20JumpCloud%20Password%20Manager%20App.md"
Set-JCCommand -CommandID $command.id -timeout 600
```
