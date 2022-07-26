#### Name

Mac - Set Desktop Background | v2.1 JCCG

#### commandType

mac

#### Command

```
## *** Customize ***
  # 1. Update the 'backgroundURL' to the URL of your desired desktop image. A JumpCloud image is used by default.
  backgroundURL="https://raw.githubusercontent.com/TheJumpCloud/support/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/JumpCloud_Background.png"
  # 2. Ensure the 'fileType' matches the file type of the desktop image (change to jpg if using a jpg). 'png' is set by default.
  fileType="png"
  # ------------Do not modify below this line-------------
  date_val=$(date "+%Y-%m-%d-%H%M")
  backgroundFile=/Users/Shared/desktopimage_$date_val.$fileType
  curl -s -o "$backgroundFile" "$backgroundURL"
read -r -d '' PSCRIPT<<EOF
from AppKit import NSWorkspace, NSScreen
from Foundation import NSURL
# generate a fileURL for the desktop picture
file_url = NSURL.fileURLWithPath_('$backgroundFile')
# make image options dictionary
# we just make an empty one because the defaults are fine
options = {}
# get shared workspace
ws = NSWorkspace.sharedWorkspace()
# iterate over all screens
for screen in NSScreen.screens():
    # tell the workspace to set the desktop picture
    (result, error) = ws.setDesktopImageURL_forScreen_options_error_(
                file_url, screen, options, None)
EOF
  env python -c "$PSCRIPT"
```

#### Description

The "JumpCloud_Background.png" file is downloaded to the local machine and saved in the folder "/Users/Shared"/

To modify this command to download and set a background image of your choice follow the steps under '*** Customize ***' by updating the backgroundURL and corresponding fileType variables.

This command used in tandem with the wallpaper modification Mac policy can be used to set and then prevent end users from updating their background.

This command can be built manually as a Mac command where the 'run-as' user is set to the JC managed user on that machine and can not be executed as the root user.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Set%20Desktop%20Background.md"
```

#### **Troubleshooting Tips**

Check to see if the file is downloading on the machine by navigating to /Users/Shared folder.
If the image file is not downloading to the machine it is likely that the 'fileType' has not been updated to match the file (png/jpg)
