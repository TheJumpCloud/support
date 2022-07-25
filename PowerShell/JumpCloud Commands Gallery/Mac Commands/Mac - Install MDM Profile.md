#### Name

Mac - Install MDM Profile | v1.2 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Force Reinstall MDM Profile (Set to: true)
reinstall=false

# Verify JumpCloud MDM
verify_jc_mdm () {
    # Check the system for the following profileIdentifier
    mdmID="com.jumpcloud.mdm"
    check=$(profiles -Lv | grep "name: $4" -4 | awk -F": " '/attribute: profileIdentifier/{print $NF}')
    if [[ $check == *$mdmID* ]] ; then
        echo "ProfileIdentifier: ${mdmID} found on system. MDM Verified"
        if [[ $reinstall = false ]]; then
            exit 0
        fi
    else
        echo "JumpCloud MDM profile not found on system."
        exit 1
    fi
}

# List profiles
list_profiles () {
    echo "The following profiles identifiers are installed on this system:"
    profiles -Lv | grep "name: $4" -4 | awk -F": " '/attribute: profileIdentifier/{print $NF}'
}

# Report if the system is already in the mdm
approveCheck=$(profiles status -type enrollment | grep "MDM enrollment:" | awk 'NF>1{print $NF}')
if [[ $approveCheck = "Yes" ]]; then
    echo "An MDM Already installed, not User Approved"
    list_profiles
    verify_jc_mdm
elif [[ $approveCheck = "Approved)" ]]; then
    echo "An MDM Already installed and is User Approved"
    list_profiles
    verify_jc_mdm
else
    MDMResult=false
fi


# install the MDM Profile
if [[ $MDMResult = false ]] || [[ $reinstall = true ]]; then
    echo "Installing JumpCloud MDM Profile"
    /usr/bin/profiles -I -F /tmp/profile_jc.mobileconfig
fi

# Verify the installation
verify_jc_mdm
```

#### Description

Installs the JumpCloud MDM enrollment profile on macOS machines. **Note** your organizations enrollment profile must be uploaded to the "Files" section of the configured JumpCloud command for this command to work.

![JC_MDM_Command](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/JC_MDM_Command.png?raw=true)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20MDM%20Profile.md"
```
