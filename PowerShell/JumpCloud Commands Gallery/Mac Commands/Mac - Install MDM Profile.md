#### Name

Mac - Install MDM Profile | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# report if the system is already in the mdm
approveCheck=$(profiles status -type enrollment | grep "MDM enrollment:" | awk 'NF>1{print $NF}')
if [[ $approveCheck = "Yes" ]]; then
    echo "MDM Already installed, not User Approved"
    exit 1
elif [[ $approveCheck = "Approved)" ]]; then
    echo "MDM Already installed and is User Approved"
    exit 1
else
    MDMResult=false
fi

if [[ $MDMResult = false ]]; then
    # install the MDM Profile
    echo "installing.."
    /usr/bin/profiles -I -F /tmp/profile_jc.mobileconfig
fi

# Verify the installation
check=$(profiles -Lv | grep "name: $4" -4 | awk -F": " '/attribute: profileIdentifier/{print $NF}')
mdmID="com.jumpcloud.mdm"
if [[ $check == *$mdmID* ]] ; then
    echo "profileIdentifier: ${mdmID} found on system. MDM Verified"
fi
exit 0
```

#### Description

Installs the JumpCloud MDM enrollment profile on macOS machines. **Note** your organizations enrollment profile must be uploaded to the "Files" section of the configured JumpCloud command for this command to work.

![JC_MDM_Command](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/JC_MDM_Command.png?raw=true)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Jfv5e'
```
