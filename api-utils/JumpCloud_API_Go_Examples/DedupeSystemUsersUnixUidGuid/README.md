## Deduplicate unix_uid and unix_guid on systemusers

This tool allows you as a system administrator to deduplicate unix_uid and unix_guid on systemusers across your organization.

### Install
- First you will need to have the go programming language and toolchain installed on your machine. If you do _not_ have go installed on your machine, follow the instructions [here](https://golang.org/doc/install)
- Second, you will need to install the jcapi library into your go installation. Go makes this very easy for us. You just need to run: `go get -v github.com/TheJumpCloud/jcapi` This should take a few seconds. If no errors are reported, the library has installed successfully.
- Third, you will need to download `dedupeSystemUsersUnixUidGuid.go` onto your machine.

### How it Works
Running this script will produce an output of systemusers in your organization that have duplicated unix_uid and unix_guids. It will then go through your users and set unique unix_uid and unix_guid values.

Ex:

| user_id | unix_uid | unix_guid |
| --- | --- | --- |
| 1 | 0 | 0 |
| 2 | 0 | 0 |
| 3 | 5000 | 5000 |
| 4 | 5000 | 5000 |

Will become:

| user_id | unix_uid | unix_guid |
| --- | --- | --- |
| 1 | 0 | 0 |
| 2 | 1 | 1 |
| 3 | 2 | 2 |
| 4 | 3 | 3 |

### Commandline options

- apiKey: *Required* your secret JumpCloud ApiKey to access and change your organizations information
- url: *Optional* Alternative JumpCloud API URL
- dryRun: *Optional* If true, print out actions. If false, update users

The `dryRun` option allows you to see what actions the script would have preformed, before they are actually run. This will allow you to verify the new values before they are saved in the JumpCloud system.

### Examples
- go run dedupeSystemUsersUnixUidGuid.go --key <api key>
	- This will scan your organization and report any users that have duplicate unix_uid or unix_guid values. It will NOT update the values in the database. It will provide you with output that will show you what _would_ happen if it were to write to the database.
- go run dedupeSystemUsersUnixUidGuid.go --key <api key> --dryRun=false
	- This WILL WRITE TO THE DATABASE.  	