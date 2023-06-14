#!/bin/bash
unzip -o /tmp/$($user.userName)-client-signed.zip -d /tmp
chmod 755 /tmp/$($user.userName)-client-signed.pfx
currentUser=$(/usr/bin/stat -f%Su /dev/console)
currentUserUID=$(id -u "$currentUser")
currentCertSN="$($certHash.serial)"
networkSsid="$($NETWORKSSID)"
if [[ $currentUser == "$($user.userName)" ]]; then
    certs=$(security find-certificate -a -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.userName)/Library/Keychains/login.keychain)
    regexSHA='SHA-1 hash: ([0-9A-F]{5,40})'
    regexSN='"snbr"<blob>=0x([0-9A-F]{5,40})'
    global_rematch() {
        # Set local variables
        local s=$1 regex=$2
        # While string matches regex expression
        while [[ $s =~ $regex ]]; do
            # Echo out the match
            echo "${BASH_REMATCH[1]}"
            # Remove the string
            s=${s#*"${BASH_REMATCH[1]}"}
        done
    }
    # Save results
    # Get Text Results
    textSHA=$(global_rematch "$certs" "$regexSHA")
    # Set as array for SHA results
    arraySHA=($textSHA)
    # Get Text Results
    textSN=$(global_rematch "$certs" "$regexSN")
    # Set as array for SN results
    arraySN=($textSN)
    # set import var
    import=true
    if [[ ${#arraySN[@]} == ${#arraySHA[@]} ]]; then
        len=${#arraySN[@]}
        for (( i=0; i<$len; i++ )); do
            if [[ $currentCertSN == ${arraySN[$i]} ]]; then
                echo "Found Cert: SN: ${arraySN[$i]} SHA: ${arraySHA[$i]}"
                installedCertSN=${arraySN[$i]}
                installedCertSHA=${arraySHA[$i]}
                # if cert is installed, no need to update
                import=false
            else
                echo "Removing previously installed radius cert:"
                echo "SN: ${arraySN[$i]} SHA: ${arraySHA[$i]}"
                security delete-certificate -Z "${arraySHA[$i]}" /Users/$($user.userName)/Library/Keychains/login.keychain
            fi
        done

    else
        echo "array length mismatch, will not delete old certs"
    fi

    if [[ $import == true ]]; then
        /bin/launchctl asuser "$currentUserUID" sudo -iu "$currentUser" /usr/bin/security import /tmp/$($user.userName)-client-signed.pfx -k /Users/$($user.userName)/Library/Keychains/login.keychain -P $JCUSERCERTPASS -T "/System/Library/SystemConfiguration/EAPOLController.bundle/Contents/Resources/eapolclient"
        if [[ $? -eq 0 ]]; then
            echo "Import Success"
            # get the SHA hash of the newly imported cert
            installedCertSN=$(/bin/launchctl asuser "$currentUserUID" sudo -iu "$currentUser" /usr/bin/security find-certificate -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.userName)/Library/Keychains/login.keychain | grep snbr | awk '{print $1}' | sed 's/"snbr"<blob>=0x//g')
            if [[ $installedCertSN == $currentCertSN ]]; then
                installedCertSHA=$(/bin/launchctl asuser "$currentUserUID" sudo -iu "$currentUser" /usr/bin/security find-certificate -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.userName)/Library/Keychains/login.keychain | grep SHA-1 | awk '{print $3}')
            fi

        else
            echo "import failed"
            exit 4
        fi
    else
        echo "cert already imported"
    fi

    # check if the cert secruity preference is set:
    for i in ${networkSsid[@]}; do
        echo "begin sertting network SSID: $i security certificate"
        if /bin/launchctl asuser "$currentUserUID" sudo -iu "$currentUser" /usr/bin/security get-identity-preference -s "com.apple.network.eap.user.identity.wlan.ssid.$i" -Z "$installedCertSHA"; then
            echo "it was already set"
        else
            echo "certificate not linked from SSID: $i to certSN: $currentCertSN, setting now"
            /bin/launchctl asuser "$currentUserUID" sudo -iu "$currentUser" /usr/bin/security set-identity-preference -s "com.apple.network.eap.user.identity.wlan.ssid.$i" -Z "$installedCertSHA"
            if [[ $? -eq 0 ]]; then
            echo "SSID: $i and certificate linked"
            else
                echo "Could not associate SSID: $i and certifiacte"
            fi
        fi
    done


    # print results
    echo "################## Cert Install Results ##################"
    echo "Installed Cert SN: $installedCertSN"
    echo "Installed Cert SHA1: $installedCertSHA"
    echo "##########################################################"

    # Finally clean up files
    if [[ -f "/tmp/$($user.userName)-client-signed.zip" ]]; then
        echo "Removing Temp Zip"
        rm "/tmp/$($user.userName)-client-signed.zip"
    fi
    if [[ -f "/tmp/$($user.userName)-client-signed.pfx" ]]; then
        echo "Removing Temp Pfx"
        rm "/tmp/$($user.userName)-client-signed.pfx"
    fi
else
    echo "Current logged in user, $currentUser, does not match expected certificate user. Please ensure $($user.userName) is signed in and retry"
    # Finally clean up files
    if [[ -f "/tmp/$($user.userName)-client-signed.zip" ]]; then
        echo "Removing Temp Zip"
        rm "/tmp/$($user.userName)-client-signed.zip"
    fi
    if [[ -f "/tmp/$($user.userName)-client-signed.pfx" ]]; then
        echo "Removing Temp Pfx"
        rm "/tmp/$($user.userName)-client-signed.pfx"
    fi
    exit 4
fi