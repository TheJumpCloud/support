#### Name

Mac - Run Once Template - Remove System From Command | v1.0 JCCG

#### commandType

mac

#### Command

```
# Populate commandID variable before running the command

commandID=''

#--------------------Enter command below this line--------------------


#--------------------Do not modify below this line--------------------

# Parse the systemKey from the conf file.
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

if [[ $conf =~ $regex ]]; then
	systemKey="${BASH_REMATCH[@]}"
fi

regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
	systemID="${BASH_REMATCH[@]}"
fi

# Get the current time.
now=$(date -u "+%a, %d %h %Y %H:%M:%S GMT")

# create the string to sign from the request-line and the date
signstr="POST /api/v2/systems/${systemID}/associations?targets=command HTTP/1.1\ndate: ${now}"

# create the signature
signature=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

curl -s \
	-X 'POST' \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' \
	-H "Date: ${now}" \
	-H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
	-d '{"op": "remove","type": "command","id": "'${commandID}'"}' \
	"https://console.jumpcloud.com/api/v2/systems/${systemID}/associations?targets=command"

echo "JumpCloud system: ${systemID} removed from command target list"
```

#### Description

This template can be used to satisfy use cases where admins wish to run a command once on a number of target systems and have the system automatically removed from the commands system target list after the command is run.

*Using a system group for associating systems with JumpCloud commands? [No problem refer to this template for removing systems from a JumpCloud command from an associated JumpCloud system group](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Run%20Once%20Template%20-%20Remove%20System%20From%20Associated%20System%20Group.md).*

Before running this command the variable **commandID=''** must be populated.

![commanID example](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/commandID.png?raw=true)

To find the commandID within the JumpCloud admin console select the command to expand the command details. Within the URL of the selected command the commandID will be the 24 character string between 'commands/' and '/details'. The JumpCloud PowerShell command [Get-JCCommand](https://github.com/TheJumpCloud/support/wiki/Get-JCCommand) can also be used to find the commandID which will reveal the commandID in the '_id' field.

Enter the payload of the command under the line '#--------------------Enter command below this line--------------------'

After the command is run the system is removed from the command via the JumpCloud system context API. [Learn more about the JumpCloud system context API here](https://docs.jumpcloud.com/2.0/authentication-and-authorization/system-context). 

#### *Import This Command*

To import this command template into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/fxUDb'
```
