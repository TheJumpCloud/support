#### Name

Mac - Bind Logged in User to System | Prompt = Choice, Permissions = Existing, Force Logout = True, Association Removal = systemGroup | JCCG v1.0

#### commandType

mac

#### Command

```
## Populate below variables before running command
JCAPIKey=''
systemGroupID=''

## ------ MODIFY BELOW THIS LINE AT YOUR OWN RISK --------------
## Get the logged in user's username
username="$(/usr/bin/stat -f%Su /dev/console)"
echo "Currently logged in user is "$username

## Get JumpCloud SystemID
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

if [[ $conf =~ $regex ]]; then
	systemKey="${BASH_REMATCH[@]}"
fi

regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
	systemID="${BASH_REMATCH[@]}"
	echo "JumpCloud systemID found SystemID: "$systemID
else
	echo "No systemID found"
	exit 1
fi

## Get JumpCloud UserID
userSearch=$(
	curl -s \
		-X 'POST' \
		-d '{"filter":[{"username":"'${username}'"}],"fields" : "username activated email"}' \
		-H 'Accept: application/json' \
		-H 'Content-Type: application/json' \
		-H 'x-api-key: '${JCAPIKey}'' \
		"https://console.jumpcloud.com/api/search/systemusers"
)

regex='[a-zA-Z0-9]{24}'
if [[ $userSearch =~ $regex ]]; then
	userID="${BASH_REMATCH[@]}"
	echo "JumpCloud userID for user "$username "found userID: "$userID
else
	echo "No JumpCloud user with username" "$username" "found."
	echo "Create a JumpCloud user with username:" "$username" "and try again."
	exit 1
fi

## Check users current permissions

if groups ${username} | grep -q -w admin; then
	echo "User is an an admin. User will be bound with admin permissions."
	admin='true'
else
	echo "User is not an admin. User will be bound with standard permissions"
	admin='false'
fi

## Checks if user is activated

regex='"activated":true'
if [[ $userSearch =~ $regex ]]; then
	activated="true"
	echo "JumpCloud account in active state for user: $username"

else
	activated="false"
	echo "JumpCloud account in pending state for user: $username"

fi

# Check and ensure user not already bound to system
userBindCheck=$(
	curl -s \
		-X 'GET' \
		-H 'Accept: application/json' \
		-H 'Content-Type: application/json' \
		-H 'x-api-key: '${JCAPIKey}'' \
		"https://console.jumpcloud.com/api/v2/systems/${systemID}/associations?targets=user"
)

regex=''${userID}''

if [[ $userBindCheck =~ $regex ]]; then
	userID="${BASH_REMATCH[@]}"
	echo "JumpCloud user $username already bound to systemID: $systemID"

	associationRemove=$(
		curl -s \
			-X 'POST' \
			-H 'Content-Type: application/json' \
			-H 'Accept: application/json' \
			-H 'x-api-key: '${JCAPIKey}'' \
			-d '{"op": "remove","type": "system","id": "'${systemID}'"}' \
			"https://console.jumpcloud.com/api/v2/systemgroups/${systemGroupID}/members"
	)

	echo "Removed ${systemID} from system group ${systemGroupID}"
	exit 0

else

	echo "JumpCloud user not bound to system."
fi

# Prompt user for logout

if [[ $activated == "true" ]]; then
	userPrompt=$(sudo -u $username osascript -e 'display dialog "JumpCloud account takeover for account: '$username'\n\nAfter clicking Ok the JumpCloud agent will update the system password for account: '$username' to the current JumpCloud password.\n\nAfter the password update you will be logged out and taken to login window to complete the account takeover.\n\nAt the login window enter your current computer password in the PREVIOUS PASSWORD box.\n\n In the PASSWORD box below this enter your JumpCloud password." buttons {"Ok"}default button "Ok" giving up after 120' 2>/dev/null)

	if [ "$userPrompt" = "button returned:Ok, gave up:false" ]; then
		echo "User said Ok to prompt"

		## Capture current logFile
		logLinesRaw=$(wc -l /var/log/jcagent.log)
		logLines=$(echo $logLinesRaw | head -n1 | awk '{print $1;}')

		## Bind JumpCloud user to JumpCloud system
		userBind=$(
			curl -s \
				-X 'POST' \
				-H 'Accept: application/json' \
				-H 'Content-Type: application/json' \
				-H 'x-api-key: '${JCAPIKey}'' \
				-d '{ "attributes": { "sudo": { "enabled": '${admin}',"withoutPassword": false}}, "op": "add", "type": "user","id": "'${userID}'"}' \
				"https://console.jumpcloud.com/api/v2/systems/${systemID}/associations"
		)

		#Check and ensure user bound to system
		userBindCheck=$(
			curl -s \
				-X 'GET' \
				-H 'Accept: application/json' \
				-H 'Content-Type: application/json' \
				-H 'x-api-key: '${JCAPIKey}'' \
				"https://console.jumpcloud.com/api/v2/systems/${systemID}/associations?targets=user"
		)

		regex=''${userID}''

		if [[ $userBindCheck =~ $regex ]]; then
			userID="${BASH_REMATCH[@]}"
			echo "JumpCloud user "$username "bound to systemID: "$systemID
		else
			echo "error JumpCloud user not bound to system"
			exit 1
		fi

		#Wait to see local account takeover

		updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)

		accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")

		logoutTimeoutCounter='0'

		while [[ -z "${accountTakeOverCheck}" ]]; do
			Sleep 6
			updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)
			accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")
			logoutTimeoutCounter=$((${logoutTimeoutCounter} + 1))
			if [[ ${logoutTimeoutCounter} -eq 10 ]]; then
				echo "Error during account takeover"
				echo "JCAgent.log: ${updateLog}"
				exit 1
			fi
		done
		echo "Account takeover occured at" $(date +"%Y %m %d %H:%M")

		echo "Logging out user"
		# Gets logged in user login window
		loginCheck=$(ps -Ajc | grep ${username} | grep loginwindow | awk '{print $2}')
		timeoutCounter='0'
		while [[ "${loginCheck}" ]]; do
			# Logs out user if they are logged in
			sudo launchctl bootout gui/$(id -u ${username})
			Sleep 5
			loginCheck=$(ps -Ajc | grep ${username} | grep loginwindow | awk '{print $2}')
			timeoutCounter=$((${timeoutCounter} + 1))
			if [[ ${timeoutCounter} -eq 4 ]]; then
				echo "Timeout unable to log out ${username} account."
				exit 1
			fi
		done
		echo "${username} logged out"

		associationRemove=$(
			curl -s \
				-X 'POST' \
				-H 'Content-Type: application/json' \
				-H 'Accept: application/json' \
				-H 'x-api-key: '${JCAPIKey}'' \
				-d '{"op": "remove","type": "system","id": "'${systemID}'"}' \
				"https://console.jumpcloud.com/api/v2/systemgroups/${systemGroupID}/members"
		)

		echo "Removed ${systemID} from system group ${systemGroupID}"
		exit 0

	else
		echo "User input: $userPrompt"
		exit 1
	fi

else

	echo "Account not activated. Have user set a JumpCloud password to activate account and try again."

	exit 1
fi
```

#### Description

After importing this command the variables `JCAPIKey=''` and `systemGroupID=''` must populated before the command can be run.

`JCAPIKey=''` should be populated with a JumpCloud API key. This command makes API calls to the JumpCloud admin console. The JumpCloud API key can only be seen by JumpCloud administrators and is not exposed or stored on target systems when this command is run.

![systemGroupID example](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/systemGroupID.png?raw=true)

To find the `systemGroupID` for a JumpCloud system group navigate to the "GROUPS" section of the JumpCloud admin portal and select the system group to bring up the system group details. Within the URL of the selected command the systemGroupID will be the 24 character string between 'system/' and '/details'. The JumpCloud PowerShell command [Get-JCGroup](https://github.com/TheJumpCloud/support/wiki/Get-JCGroup) can also be used to find the systemGroupID. The systemGroupID is the 'id' value which will be displayed for each JumpCloud group when Get-JCGroup is called.

This command will query the current logged in user on the system and determine if the logged in user is an active JumpCloud user. If the logged is user is an active JumpCloud user the command will query the system and determine if the user has already been bound to the system. If the user has not been bound to the system the command will prompt the user and inform them that the JumpCloud agent will takeover their local account. If users say **Ok** at the prompt the agent will bind the user to the system with their existing system permissions (admin or standard) and then log the user out and take them to the login window to ensure account takeover occurs. If the prompt times out after 120 seconds, the command will return an exitCode of 1 and return this information to log section of the command result.

If the command exits with an exitCode of 0 the target system will be removed from the JumpCloud system group using the `systemGroupID''` variable.


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL ''
```
