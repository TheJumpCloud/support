#### Name

Mac - Install Microsoft Office 365 | v1.0 JCCG

#### commandType

mac

#### Command

```
DownloadUrl="https://go.microsoft.com/fwlink/p/?linkid=525133"

### Modify below this line at your own risk!

# Locate PKG Download Link From URL

regex='^https.*.pkg$'
if [[ $DownloadUrl =~ $regex ]]; then
    echo "URL points to direct PKG download"
else
    echo "Searching headers for download links"
    urlHead=$(curl -s --head "$DownloadUrl")

    locationSearch=$(echo "$urlHead" | grep https:)

    if [[ -n "$locationSearch" ]]; then

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

mkdir /tmp/"$TempFolder"

# Navigate to Temp Folder
cd /tmp/"$TempFolder"

# Download File into Temp Folder
curl -s -O "$DownloadUrl"

# Capture name of Download File
DownloadFile="$(ls)"

echo "Downloaded $DownloadFile to /tmp/$TempFolder"

# Verifies PKG File
regex='\.pkg$'
if [[ $DownloadFile =~ $regex ]]; then
    PKGFile="$(echo "$DownloadFile")"
    echo "PKG File Found: $PKGFile"
else
    echo "File: $DownloadFile is not a PKG"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

# Test to ensure App is not already installed
# We're hard coding the apps as they're not included in the pkg
list=("Microsoft Excel" "Microsoft OneNote" "Microsoft Outlook" "Microsoft PowerPoint" "Microsoft Word")
for n in "${list[@]}"; do
    app="/Applications/$n.app"
    if [[ -d "$app" ]]; then
        echo "$n already present in /Applications folder"
        rm -r /tmp/$TempFolder
        echo "Deleted /tmp/$TempFolder"
        exit 1

    else
        echo "$n not present in /Applications folder"
    fi
done

echo "Microsoft install starting"

# Copy the contents of the DMG file to /Applications/
# Preserves all file attributes and ACLs
installer -verbose -pkg "$DownloadFile" -target /

err=$?
if [ ${err} -ne 0 ]; then
    echo "Could not install application. Error code: ${err}"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

echo "Installed Microsoft Office"

# Remove Temp Folder and download
rm -r /tmp/$TempFolder

echo "Deleted /tmp/$TempFolder"
```

#### Description

This command pulls the latest Microsoft Office 365 installer .pkg from the URL specified in the DownloadURL variable. This is designed to install Microsoft Office for Mac for Office 365 users. Please note, at the time of this example posting, linkid: 525133 was the latest version available, this may change in the future.

It's advised to set a longer timeout window for this command, at the time of writing the Office 365 Installer was 1.5GB. Download and install time must be taken into consideration. In testing, a timeout of 800 seconds proved adequate.

This is a community written command from [joffems](https://github.com/joffems) thanks for contributing!

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JJ6Vk'
```
