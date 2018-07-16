# Replace YOUR_CONNECT_KEY with your actual key found on the new system aside in the admin console

if [[ $MacOSMinorVersion -lt 13 ]]; then
    echo "Error:  Target system is not on macOS 10.13"
    exit 2
else

curl -o /tmp/jumpcloud-agent.pkg "https://s3.amazonaws.com/jumpcloud-windows-agent/production/jumpcloud-agent.pkg"
mkdir -p /opt/jc
cat <<-EOF > /opt/jc/agentBootstrap.json
{
"publicKickstartUrl": "https://kickstart.jumpcloud.com:443",
"privateKickstartUrl": "https://private-kickstart.jumpcloud.com:443",
"connectKey": "YOUR_CONNECT_KEY"
}
EOF

# Replace SECURETOKEN_ADMIN_USERNAME SECURETOKEN_ADMIN_PASSWORD with a credentials of an admin with a secure token 

cat <<-EOF > /var/run/JumpCloud-SecureToken-Creds.txt
SECURETOKEN_ADMIN_USERNAME;SECURETOKEN_ADMIN_PASSWORD
EOF
installer -pkg /tmp/jumpcloud-agent.pkg -target / &
fi
