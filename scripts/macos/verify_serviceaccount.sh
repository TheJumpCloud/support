MacOSMinorVersion=$(sw_vers -productVersion | cut -d '.' -f 2)
MacOSPatchVersion=$(sw_vers -productVersion | cut -d '.' -f 3)

if [[ $MacOSMinorVersion -lt 13 ]]; then
    echo "Error:  Target system is not on macOS 10.13"
    exit 2
fi

JCSA_Username="_jumpcloudserviceaccount"
JCSA_FullName="JumpCloud Service Account"

sysadmin_name="sysadminctl"
if [[ $MacOSMinorVersion -eq 13 ]]; then
    if [[ $MacOSPatchVersion -lt 4 ]]; then
        sysadmin_name="/opt/jc/bin/sysadminkludge"
    fi
fi

result=$($sysadmin_name -secureTokenStatus $JCSA_Username 2>&1 )
unknown_user=$(echo $result | grep "Unknown user $JCSA_Username")
enabled=$(echo $result | grep "Secure token is ENABLED for user $JCSA_FullName")

if [[ ! -z $unknown_user ]]; then
    echo "Error:  jumpcloud service account not installed"
    exit 2
fi

if [[ -z $enabled ]]; then
    echo "Error:  jumpcloud service account does not have a secure token"
    exit 3
fi

exit 0
