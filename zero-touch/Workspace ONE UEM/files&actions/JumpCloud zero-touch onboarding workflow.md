# General

### Name
JumpCloud zero-touch onboarding workflow

### Description 
A script that runs post DEP enrollment to install the JumpCloud agent and auto-assign users to systems in JumpCloud

### Platform 

Apple macOS

### Managed By

Your Work Space ONE UEM organization

# Files

### File

[[jc-zero-touch.sh]]

### Download path

/tmp/jc-zero-touch.sh

### Version

1.0

# Manifest

## Add Manifest

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
