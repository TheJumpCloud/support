# Add Files/Actions

Apple macOS

## Add Files/Actions > General

### Name
JumpCloud zero-touch onboarding workflow

### Description

A script that runs post DEP enrollment to install the JumpCloud agent and auto-assign users to systems in JumpCloud

### Platform

Apple macOS

### Managed By

Your Work Space ONE UEM organization

## Add Files/Actions > Files

ADD FILES

### File

[jc-zero-touch.sh](https://raw.githubusercontent.com/TheJumpCloud/support/master/zero-touch/Workspace%20ONE%20UEM/files%26actions/jc-zero-touch.sh)

Download the above file by following the link and right clicking on the page and selecting "Save As.." or copy and save the contents of the script locally in a file named `jc-zero-touch.sh` using a text editor.

After downloading the script locally upload it using the ADD FILES button on the `Files` tab.

### Download path

/tmp/jc-zero-touch.sh

### Version

1.0

## Add Files/Actions >  Manifest > Install Manifest

ADD ACTION

### Action(s) To Perform

Run

### Command Line and Arguments to run

```
. /tmp/jc-zero-touch.sh "Your_JumpCloud_Connect_Key" "Admin_Username" "Admin_Password" "Your_JumpCloud_API_Key"
```

Ensure that "Admin_username" and "Admin_Password" match the credentials entered in the "Admin Account Creation" settings for your Workspace One UEM DEP profile.

 - Need to configure this? Find steps for how to configure this on **Page 18** within [this document](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.4/vmware-airwatch-guide-for-apple-device-enrollment-program.pdf).

"Your_JumpCloud_Connect_Key" and "Your_JumpCloud_API_Key" can be found within the JumpCloud admin console.

These parameters are passed to the `/tmp/jc-zero-touch.sh` script and mapped to the following variables:

`$1` = "Your_JumpCloud_Connect_Key"

`$2` = "Admin_Username"

`$3` = "Admin_Password"

`$4` = "Your_JumpCloud_API_Key"

### TimeOut (-1 for infinite)

120
