## General - DISPLAY NAME

jc_install_jcagent

## Script - SCRIPT CONTENTS

```bash

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

JCAgentConfPath='/opt/jc/jcagent.conf'

while [ ! -f "$JCAgentConfPath" ]; do
    echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for JC Agent to install"
    sleep 2
done


conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'
if [[ $conf =~ $regex ]]; then
    systemKey="${BASH_REMATCH[@]}"
fi

while [ -z "$systemKey" ]; do
    echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for systemKey to register"
    sleep 1
    conf="$(cat /opt/jc/jcagent.conf)"
    if [[ $conf =~ $regex ]]; then
        systemKey="${BASH_REMATCH[@]}"
    fi
done

echo "$(date "+%Y-%m-%dT%H:%M:%S"): JumpCloud agent installed!"
```

## Options

N/A

## Limitations

N/A