# Changelog

## 2.1

### RELEASE DATE

December 3, 2019

#### RELEASE NOTES

Slight change to the logic at the end of the script for deleting the enrollment and decrypt users. Switch to using sysadminctl instead of dscl to delete enrollment and decrypt users. The sysadminctl command was introduced in 10.13 macOS High Sierra. Thus, High Sierra is the minimum required version of macOS required to run this workflow.

The user deletion step now occurs in the last stage. Deletion should only occur when either a different user other than the enrollment user is logged in or at the login window. This solves the potential issue where remnant files of the enrollment user and decrypt user account remain after deletion. Running the sysadminctl command to delete users absolves the need to run rm -rf /User/EnrollmentUser to clean up the user files.

## 2.0

### RELEASE DATE

October 9, 2019

#### RELEASE NOTES

Change the jumpcloud_bootstrap_template.sh script to run though a LaunchDaemon. Moved jumpcloud_bootstrap_template.sh to /var/tmp. Files left in /private/var are deleted on system restart - we want this script to be resilient on restart.

Added stages to the jumpcloud_bootstrap_template.sh script, should any stage fail the daemon could relaunch the script and it would attempt to execute that block of code again. The script must complete in order for the daemon to unload and remove itself from the system. If a system is restarted during parts of the process, the daemon should relaunch the enrollment script upon next login.

/bin/bash tcc profile changed for the osa password prompt. Since the jumpcloud_bootstrap_template.sh is being called through a daemon, the previous tcc profile is no longer needed. the bash binary needs to be approved for calling osa systemevents in order to suppress the dialogue box during the password prompt.

Updated DEPNotify to 1.1.5.

## 1.1

### RELEASE DATE

September 19, 2019

#### RELEASE NOTES

The jumpcloud_bootstrap_template.sh has been updated with logic to delete the `DECRYPT_USER` and the `ENROLLMENT_USER` accounts from the macOS system. This logic has been added to the end of the jumpcloud_bootstrap_template.sh.Removing the `ENROLLMENT_USER` is an important step as this user has a valid Secure Token and while they are disabled via the JumpCloud agent (In Version 1.0) their account will be present at the macOS FileVault decryption screen. By removing this account from the system the Secure Token is invalided and the account does not display at the FileVault decrypt screen.
