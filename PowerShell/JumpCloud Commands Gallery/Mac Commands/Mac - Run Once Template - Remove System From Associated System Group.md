#### Name

Mac - Run Once Template - Remove System From Associated System Group | v1.0 JCCG

#### commandType

mac

#### Command

```
# Populate systemGroupID variable before running the command

systemGroupID=''

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
signstr="POST /api/v2/systemgroups/${systemGroupID}/members HTTP/1.1\ndate: ${now}"

# create the signature
signature=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

curl -s \
	-X 'POST' \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' \
	-H "Date: ${now}" \
	-H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
	-d '{"op": "remove","type": "system","id": "'${systemID}'"}' \
	"https://console.jumpcloud.com/api/v2/systemgroups/${systemGroupID}/members"

echo "JumpCloud system: ${systemID} removed from system group: ${systemGroupID}"
```

#### Description

This template can be modified to satisfy use cases where admins wish to run a command once on a number of target systems and have the system automatically removed from the system group which associates the system with the command.

*Directly associating JumpCloud systems to JumpCloud commands? [No problem refer to this template for removing systems from a JumpCloud command](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Run%20Once%20Template%20-%20Remove%20System%20From%20Command.md)*

Before running this command the variable **systemGroupID=''** must be populated.

To find the systemGroupID for a JumpCloud system group navigate to the "GROUPS" section of the JumpCloud admin portal and select the system group to bring up the system group details. Within the URL of the selected command the systemGroupID will be the 24 character string between 'system/' and '/details'. The JumpCloud PowerShell command [Get-JCGroup](https://github.com/TheJumpCloud/support/wiki/Get-JCGroup) can also be used to find the systemGroupID. The systemGroupID is the 'id' value which will be displayed for each JumpCloud group when Get-JCGroup is called.

![systemGroupID example](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/systemGroupID.png?raw=true)

Enter the payload of the command under the line '#--------------------Enter command below this line--------------------'

After the command is run the system is removed from the system group specified via the JumpCloud system context API. [Learn more about the JumpCloud system context API here](https://docs.jumpcloud.com/2.0/authentication-and-authorization/system-context). 


#### *Import This Command*

To import this command template into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Run%20Once%20Template%20-%20Remove%20System%20From%20Associated%20System%20Group.md"
```
