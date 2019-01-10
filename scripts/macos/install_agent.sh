#!/usr/bin/env bash

# Replace YOUR_CONNECT_KEY with your actual key found on the new system aside in the admin console

curl -o /tmp/jumpcloud-agent.pkg "https://s3.amazonaws.com/jumpcloud-windows-agent/production/jumpcloud-agent.pkg"
mkdir -p /opt/jc
cat <<-EOF > /opt/jc/agentBootstrap.json
{
"publicKickstartUrl": "https://kickstart.jumpcloud.com:443",
"privateKickstartUrl": "https://private-kickstart.jumpcloud.com:443",
"connectKey": "YOUR_CONNECT_KEY"
}
EOF
installer -pkg /tmp/jumpcloud-agent.pkg -target /
