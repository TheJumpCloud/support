#
# Populate the below variables before running the command
#

# Enter your connect key within the "" of YOUR_CONNECT_KEY="" with your orgs key found on the new system aside in the admin console
YOUR_CONNECT_KEY=""

# Enter the SECURETOKEN_ADMIN_USERNAME within the "" of SECURETOKEN_ADMIN_USERNAME=""  
SECURETOKEN_ADMIN_USERNAME=""

# Enter the SECURETOKEN_ADMIN_PASSWORD within the "" of SECURETOKEN_ADMIN_PASSWORD="" with the credentials of the admin with a secure token 
SECURETOKEN_ADMIN_PASSWORD=""

#--------------------Do not modify below this line--------------------

MacOSMinorVersion=$(sw_vers -productVersion | cut -d '.' -f 2)
MacOSPatchVersion=$(sw_vers -productVersion | cut -d '.' -f 3)

if [[ $MacOSMinorVersion -lt 13 ]]; then
    echo "Error:  Target system is not on macOS 10.13"
    exit 2
else

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

installer -pkg /tmp/jumpcloud-agent.pkg -target / &
fi
exit 0