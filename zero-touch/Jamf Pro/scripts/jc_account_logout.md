## General - DISPLAY NAME

jc_account_logout

## Script - SCRIPT CONTENTS

```bash
user=$(ls -la /dev/console | cut -d " " -f 4)

echo "Logging out user $user"

# Gets logged in user login window
loginCheck=$(ps -Ajc | grep ${user} | grep loginwindow | awk '{print $2}')
timeoutCounter='0'
while [[ "${loginCheck}" ]]; do
    # Logs out user if they are logged in
    sudo launchctl bootout gui/$(id -u ${user})
    Sleep 5
    loginCheck=$(ps -Ajc | grep ${user} | grep loginwindow | awk '{print $2}')
    timeoutCounter=$((${timeoutCounter} + 1))
    if [[ ${timeoutCounter} -eq 4 ]]; then
        echo "Timeout unable to log out ${user} account."
        exit 1
    fi
done
echo "${user} logged out"
exit 0
```

## Options

N/A

## Limitations

N/A