#### Name

Mac - Cache Latest MacOS Installer | v1.0 JCCG

#### commandType

mac

#### Command

```
softwareupdate --fetch-full-installer

# Change the systemGroupID to the system group
systemGroupID="5e74f14e45886d2939ff2562"

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
	-d '{"op": "add","type": "system","id": "'${systemID}'"}' \
	"https://console.jumpcloud.com/api/v2/systemgroups/${systemGroupID}/members"

echo "JumpCloud system: ${systemID} removed from system group: ${systemGroupID}"
```

#### Description

This command invokes the MacOS softwareupdate utility. The --fetch-full-installer flag downloads the latest Install MacOS installer available from the App Store. The --fetch-full-installer flag contains a sub-flag to specify which version of the latest Install MacOS installer to download. For example, `softwareupdate --fetch-full-installer --full-installer-version` 10.15.1 would download the 10.15.1 version of Catalina to the target system. The timeout on this command should be changed to accommodate slower networks. A timeout of 30 mins (or 1800 seconds) should suffice if running on a single system. Change the systemGroupID to a new group ID in your JumpCloud Organization to track systems which have run this command.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JvLiV'
```
