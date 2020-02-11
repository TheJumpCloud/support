#!/bin/bash
#
# Populate the below variables before running the command
#
# Enter your connect key within the '' of YOUR_CONNECT_KEY='' with your orgs key found on the new system aside in the admin console
YOUR_CONNECT_KEY=''

# Enter the SECURETOKEN_ADMIN_USERNAME within the '' of SECURETOKEN_ADMIN_USERNAME=''
SECURETOKEN_ADMIN_USERNAME=''

# Enter the SECURETOKEN_ADMIN_PASSWORD within the '' of SECURETOKEN_ADMIN_PASSWORD='' with the credentials of the admin with a secure token
SECURETOKEN_ADMIN_PASSWORD=''

# Flag for installing without checking SECURETOKEN_ADMIN_USERNAME or SECURETOKEN_ADMIN_PASSWORD
SILENT_INSTALL=0

# You can also specify one or more values with parameters
# -k YOUR_CONNECT_KEY -u SECURETOKEN_ADMIN_USERNAME -p SECURETOKEN_ADMIN_PASSWORD
while getopts k:u:p:sh option; do
  case "${option}" in
    k) YOUR_CONNECT_KEY=${OPTARG};;
    u) SECURETOKEN_ADMIN_USERNAME=${OPTARG};;
    p) SECURETOKEN_ADMIN_PASSWORD=${OPTARG};;
    h)
      printf "Options:
      -k        Your JumpCloud Connect Key
      -u        System Admin Username
      -p        System Admin Password\n\n"
      exit 0
      ;;
    s) SILENT_INSTALL=1;;
  esac
done

#--------------------Do not modify below this line--------------------

MacOSMinorVersion=$(sw_vers -productVersion | cut -d '.' -f 2)
MacOSPatchVersion=$(sw_vers -productVersion | cut -d '.' -f 3)

if [[ $MacOSMinorVersion -lt 13 ]]; then
    echo "Error:  Target system is not on macOS 10.13"
    exit 2
else

# This function checks whether the given user is secure token enabled:
secureTokenEnabledForUser() {
    # secure token is not supported on versions < 10.13
    if [[ "$MacOSMinorVersion" -lt 13 ]]; then
        return 1
    fi

    # on earlier versions of High Sierra, we should use dscl:
    if [[ "$MacOSMinorVersion" -eq 13 && "$MacOSPatchVersion" -lt 4 ]]; then
        if [[ $(dscl . read /Users/$1 AuthenticationAuthority | grep ";SecureToken;" -c) -gt 0 ]]; then
            return 0 # success
        fi
    else # on 10.13.4 or higher we can just use sysadminctl to get the secureToken status without admin credentials:
        if [[ $(sysadminctl -secureTokenStatus "$1" 2>&1) == *"Secure token is ENABLED for user"* ]]; then
            return 0 # success
        fi
    fi

    return 1 # SecureToken is NOT enabled
}

isAdminUser() {
    if [ $(id -Gn $1 | grep -c -w admin) -gt 0 ]; then
        return 0 # user is an admin
    fi

    return 1
}

checkAndReadInUsername(){
  printf "\nSecure Token enabled admin required\n"
  printf "Checking $SECURETOKEN_ADMIN_USERNAME for Secure Token admin access\n"
  sleep 1
  if (secureTokenEnabledForUser $SECURETOKEN_ADMIN_USERNAME) && (isAdminUser $SECURETOKEN_ADMIN_USERNAME)
    then
      echo "** ($SECURETOKEN_ADMIN_USERNAME) is verified as a Secure Token admin **"
      return 0;
  fi
  echo "--------"

  while !(secureTokenEnabledForUser $SECURETOKEN_ADMIN_USERNAME) || !(isAdminUser $SECURETOKEN_ADMIN_USERNAME); do
    printf "\nThe username ($SECURETOKEN_ADMIN_USERNAME) is not a Secure Token enabled admin.\nTo enable the JumpCloud Agent to manage FileVault users, \nplease provide the username of a Secure Token enabled \nadmin user on this system.\n"
    echo "--------"
    read -p 'Secure Token Admin Username: ' SECURETOKEN_ADMIN_USERNAME
  done

  echo "** ($SECURETOKEN_ADMIN_USERNAME) is verified as a Secure Token admin **"
  return 1;
}

readInPasswordForUser(){
  local reenter_password

  while true; do

    read -sp "Please enter the password for $SECURETOKEN_ADMIN_USERNAME:" SECURETOKEN_ADMIN_PASSWORD
    echo ''
    read -sp "Please re-enter the password for $SECURETOKEN_ADMIN_USERNAME:" reenter_password


    if [ -z "$SECURETOKEN_ADMIN_PASSWORD" ] || [ -z "$reenter_password" ]
      then
        printf '\n\nERROR: Passwords cannot be blank!\n\n'
    else
      if [ "$SECURETOKEN_ADMIN_PASSWORD" == "$reenter_password" ]
          then
            echo ''
            break
        else
          printf '\n\nERROR: Passwords did not match!\n\n'
        fi
    fi
  done
}

# require connect key
if [ -z "$YOUR_CONNECT_KEY" ]; then
  echo 'Connect key is required. Please provide one in the script or via the -k parameter'
  exit 1
fi

# check connect key length
if [ ${#YOUR_CONNECT_KEY} != 40 ]; then
  echo 'Connect key is not 40 characters. Please provide a valid connect key in the script or via the -k parameter'
  exit 1
fi


if [ "$SILENT_INSTALL" -eq "0" ]; then
  if [ -z "$SECURETOKEN_ADMIN_USERNAME" ]; then
    # if empty, set SECURETOKEN_ADMIN_USERNAME to the user running the script
    SECURETOKEN_ADMIN_USERNAME=$(stat -f '%Su' $HOME)
  fi

  # check to make sure the user is a secure token enabled admin
  checkAndReadInUsername
  name_check=$?

  if [ "$name_check" -ne "0" ] || [ -z "$SECURETOKEN_ADMIN_PASSWORD" ];  then
    readInPasswordForUser
  fi

fi

curl --silent --output /tmp/jumpcloud-agent.pkg "https://s3.amazonaws.com/jumpcloud-windows-agent/production/jumpcloud-agent.pkg" > /dev/null
mkdir -p /opt/jc
cat <<-EOF > /opt/jc/agentBootstrap.json
{
"publicKickstartUrl": "https://kickstart.jumpcloud.com:443",
"privateKickstartUrl": "https://private-kickstart.jumpcloud.com:443",
"connectKey": "$YOUR_CONNECT_KEY"
}
EOF

cat <<-EOF > /var/run/JumpCloud-SecureToken-Creds.txt
$SECURETOKEN_ADMIN_USERNAME;$SECURETOKEN_ADMIN_PASSWORD
EOF
# The file JumpCloud-SecureToken-Creds.txt IS DELETED during the agent install process
installer -pkg /tmp/jumpcloud-agent.pkg -target / &
fi
exit 0
