#### Name

Mac - Set Custom Desktop Background | v1.0 JCCG

#### commandType

mac

#### Command

```
# *** Usage **
#
# This command can only be run on one system at a time
# This command must be "RUN AS:" (This setting lives in the top right corner of command screen) 
# .. the user on the system whose desktop # background you wish to set
#
# *** Customize ***  

# 1. Update the 'backgroundURL' to the URL of your desired desktop image. A JumpCloud image is used by default.

backgroundURL="https://raw.githubusercontent.com/TheJumpCloud/support/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/JumpCloud_Background.png"

# 2. Ensure the 'fileType' matches the file type of the desktop image (change to jpg if using a jpg)

fileType="png"

# 3. Change the "RUN AS:" to the user whose desktop you wish to set and then 'Save Command' and 'Run'

# ------------Do not modify below this line------------- 

date_val=$(date "+%Y-%m-%d-%H%M")

curl -s -o /Users/Shared/desktopimage_$date_val.$fileType $backgroundURL

osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/desktopimage_'"$date_val"'.'"$fileType"'"'
```

#### Description

By modifying the 'backgroundURL' and matching the 'fileType' to the type of file for the background image you're downloading this command can set the desktop background on Mac workstations. 

**Important** this command can only be run on one system at a time and must be "RUN AS:" (This setting lives in the top right corner of command screen) the user on the system whose desktop background you wish to set.


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'Create and enter Git.io URL'
```

#### **Troubleshooting Tips**

Check to see if the file is downloading on the machine by navigating to /Users/Shared 
If the image file is not downloading to the machine it is likley that the 'fileType' has not been updated to match the file (png/jpg)

If the file is downloaded the issue is likley the 'RUN AS' user has not been specificed. If the command is run as 'root' the file will download but not the background will not be applied. 'RUN AS' must be set to run as the user whose desktop image you wish to set. 
