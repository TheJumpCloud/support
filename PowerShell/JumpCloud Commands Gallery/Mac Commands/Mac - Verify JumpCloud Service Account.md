#### Name

Mac - Verify JumpCloud Service Account | v1.1 JCCG 

#### commandType

mac

#### Command

```
#!/bin/bash

MacOSMajorVersion=$(sw_vers -productVersion | cut -d '.' -f 1)
MacOSMinorVersion=$(sw_vers -productVersion | cut -d '.' -f 2)
MacOSPatchVersion=$(sw_vers -productVersion | cut -d '.' -f 3)

if [[ $MacOSMajorVersion -eq 10 && $MacOSMinorVersion -lt 13 ]]; then
    echo "Error:  System must be running 10.13+ to install Service Account."
    exit 2
fi

# Gather the local accounts on the system
localAccounts=$(dscl . list /Users UniqueID | awk '$2>500{print $1}' | grep -v super.admin | grep -v _jumpcloudserviceaccount)
# For each local account, test secure token status
for usr in ${localAccounts};
do
    testST=$(sysadminctl -secureTokenStatus "$usr" 2>&1)
    # echo $testST
    if [[ $testST == *ENABLED* ]]
    then
        echo "$usr has secure token"
    fi
done

JCSA_Username="_jumpcloudserviceaccount"
JCSA_FullName="JumpCloud Service Account"
JCSA_FullName2="JumpCloud"

sysadmin_name="sysadminctl"
if [[ $MacOSMinorVersion -eq 13 ]]; then
    if [[ $MacOSPatchVersion -lt 4 ]]; then
        sysadmin_name="/opt/jc/bin/sysadminkludge"
    fi
fi

result=$($sysadmin_name -secureTokenStatus $JCSA_Username 2>&1 )
unknown_user=$(echo $result | grep "Unknown user $JCSA_Username")
newEnabled=$(echo $result | grep "Secure token is ENABLED for user $JCSA_FullName2")

if [[ ! -z $unknown_user ]]; then
    echo "Error:  JumpCloud Service Account not installed"
    exit 2
fi

if [[ -z $newEnabled ]]; then
    oldEnabled=$(echo $result | grep "Secure token is ENABLED for user $JCSA_FullName")
        if [[ -z $oldEnabled ]]; then
                echo "Error:  JumpCloud Service Account does not have a secure token"
                exit 3
        fi
fi

echo "Success: JumpCloud Service Account has been properly created"
exit 0
```

#### Description

The above command will verify the presence of the JumpCloud service account needed to manage users on MacOS systems on 10.13 where APFS drives are used and FileVault is enabled. 

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-mac-verifyjumpcloudserviceaccount'
```
