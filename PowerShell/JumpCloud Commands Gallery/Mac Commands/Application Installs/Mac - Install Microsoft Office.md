# *** USAGE *** Version: 1.1

# *NOTE* This is designed to install Microsoft Office for Mac for Office 365 users. 

DownloadUrl="https://go.microsoft.com/fwlink/p/?linkid=525133"

### Modify below this line at your own risk!

# Locate PKG Download Link From URL

regex='^https.*.pkg$'
if [[ $DownloadUrl =~ $regex ]]; then
    echo "URL points to direct PKG download"
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
ExistingSearch=$(find "/Applications/" -name "Microsoft\ Word.app" -depth 1)

if [ -n "$ExistingSearch" ]; then

    echo "Microsoft Word already present in /Applications folder"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1

else

    echo "Microsoft Word not present in /Applications folder"
fi

ExistingSearch=$(find "/Applications/" -name "Microsoft\ Outlook.app" -depth 1)

if [ -n "$ExistingSearch" ]; then

    echo "Microsoft Outlook already present in /Applications folder"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1

else

    echo "Microsoft Outlook not present in /Applications folder"
fi


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
