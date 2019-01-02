## Deduplicate unix_uid and unix_guid on systemusers

This tool allows you as a system administrator to deduplicate unix_uid and unix_guid on systemusers across your organization.

### Install
Follow the installation instructions for any of the other scripts in this repository.

### How it Works
Running this script will produce an output of systemusers in your organization that have duplicated unix_uid and unix_guids. It will then go through your users and set unique unix_uid and unix_guid values.

Ex:
user_id, unix_uid, unix_guid
1, 0, 0
2, 0, 0
3, 5000, 5000
4, 5000, 5000

Will become:
user_id, unix_uid, unix_guid
1, 0, 0
2, 1, 1
3, 2, 2
4, 3, 3

### Commandline options

- apiKey: *Required* your secret JumpCloud ApiKey to access and change your organizations information
- url: *Optional* Alternative JumpCloud API URL
- dryRun: *Optional* If true, print out actions. If false, update users

The `dryRun` option allows you to see what actions the script would have preformed, before they are actually run. This will allow you to verify the new values before they are saved in the JumpCloud system.
