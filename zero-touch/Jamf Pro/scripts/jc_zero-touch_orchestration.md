## General - DISPLAY NAME

jc_zero-touch_orchestration

## Script - SCRIPT CONTENTS

```bash
# Installs the JumpCloud agent
jamf policy -trigger jc_install_agent

# Waits for the JumpCloud agent to register
jamf policy -trigger jc_register_agent

# Associates the logged in user to their new system in JumpCloud
jamf policy -trigger jc_account_association

# Informs user of upcoming log out
jamf policy -trigger jc_logout_info1

# Informs user to log back in
jamf policy -trigger jc_logout_info2

# Logs the user out to complete JumpCloud account takeover
jamf policy -trigger jc_account_logout

exit 0
```

## Options

N/A

## Limitations

N/A