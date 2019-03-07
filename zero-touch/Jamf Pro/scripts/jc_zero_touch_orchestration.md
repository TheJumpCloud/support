## General - DISPLAY NAME

jc_zero_touch_orchestration

## Script - SCRIPT CONTENTS

```bash
# Installs the JumpCloud agent
jamf policy -trigger 01_install_jcagent

# Waits for the JumpCloud agent to register
jamf policy -trigger 02_jc_agent_register

# Associates the logged in user to their new system in JumpCloud
jamf policy -trigger 03_jc_account_association

# Informs user of upcoming log out
jamf policy -trigger 04_jc_logout_info1

# Informs user to log back in
jamf policy -trigger 05_jc_logout_info2

# Logs the user out to complete JumpCloud account takeover
jamf policy -trigger 06_jc_account_logout

exit 0
```

## Options

N/A

## Limitations

N/A