#!/bin/bash

# should be run as root
# Install AutoPkg
curl -L -o /tmp/autopkg-1.2.pkg "https://github.com/autopkg/autopkg/releases/download/v1.2/autopkg-1.2.pkg" >/dev/null
installer -pkg /tmp/autopkg-1.2.pkg -target /

#Get macOS version
macosv=`sw_vers -productVersion | cut -d . -f 1,2`

#Download and install xcode cli tools if needed
if [ ! -d /Library/Developer ] ; then
    echo "Xcode CLI tools needed, Downloading from SUS"
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l |
      grep "\*.*Command Line" |
      grep "$macosv" |
      head -n 1 | awk -F"*" '{print $2}' |
      sed -e 's/^ *//' |
      tr -d '\n')
    softwareupdate -i "$PROD"
    rm -rf /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi
if [ ! -d /Library/Developer ] ; then
    echo "Command Line Tools not installed"
    exit 1
fi

exit 0