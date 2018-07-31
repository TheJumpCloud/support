#### Name

Mac - Set Desktop Background | v2.0 JCCG

#### commandType

mac

#### Command

```
# *** Customize ***  

# 1. Update the 'backgroundURL' to the URL of your desired desktop image. A JumpCloud image is used by default.

backgroundURL="https://raw.githubusercontent.com/TheJumpCloud/support/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/JumpCloud_Background.png"

# 2. Ensure the 'fileType' matches the file type of the desktop image (change to jpg if using a jpg). 'png' is set by default.

fileType="png"

# ------------Do not modify below this line------------- 

user=`ls -la /dev/console | cut -d " " -f 4`

date_val=$(date "+%Y-%m-%d-%H%M")

curl -s -o /Users/Shared/desktopimage_$date_val.$fileType $backgroundURL

sudo -u $user osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/desktopimage_'"$date_val"'.'"$fileType"'"'
```

#### Description

This command will set the desktop background for the current logged in user. 

By modifying the 'backgroundURL' variable and matching the 'fileType' variable to the type of file for the background image you're downloading this command will set the desktop background on Mac workstations. 


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-Mac-SetDesktopBackground'
```

#### **Troubleshooting Tips**

Check to see if the file is downloading on the machine by navigating to /Users/Shared folder.
If the image file is not downloading to the machine it is likley that the 'fileType' has not been updated to match the file (png/jpg)
