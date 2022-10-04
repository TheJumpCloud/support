#### Name

Linux - AppImage - Install JumpCloud Password Manager App | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash

DownloadURL="https://cdn.pwm.jumpcloud.com/DA/release/JumpCloud-Password-Manager-latest.AppImage"

############### Do Not Edit Below This Line ###############
regex='\JumpCloud-Password-Manager'
filename="jcPasswordApp.AppImage"


#Verify Installed APP
if find /home/$USER/Applications -type f -name "jcPasswordApp*" ; then
    echo "Already Installed"
    exit 0
else
    echo "Downloading JC Password Manager"
fi
# Create to AppImages Folder
mkdir AppImages
cd AppImages/

curl -o $filename $DownloadURL


# Verifies AppImage File
regex='\.AppImage$'
if [[ $filename =~ $regex ]]; then
    APPIMAGEFile="$(echo "$filename")"
    echo "AppImage File Found: $APPIMAGEFile"
else
    echo "File: $filename is not a AppImage"
    exit 1
fi

chmod +x $APPIMAGEFile

echo "Installing App"
ail-cli integrate $APPIMAGEFile

```

#### Description

Install umpCloud Password Manager App with the AppImage Launcher. To learn more about AppImage Launcher, visit [AppImage Launcher GitHub](https://github.com/TheAssassin/AppImageLauncher)


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Snap%20-%20Install%20Microsoft%20VS%20Code.md"
```
