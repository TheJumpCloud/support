## Options - General - DISPLAY NAME

Zero-Touch Step 1 - JumpCloud Agent Install

## Options - General - Trigger

Custom

## Options - General - Trigger - Custom - CUSTOM EVENT

01_jc_agent_install

## Options - General - EXECUTION FREQUENCY

Ongoing

## Scope - Targets - TARGET COMPUTERS

All Computers

## User Interaction - START MESSAGE

Installing the JumpCloud Agent

## User Interaction - COMPLETE MESSAGE

JumpCloud Agent Installed!

## Options - Script - Configure

For Mac versions 10.13.x and above, where JumpCloud will manage Filevault users and APFS is in use:[jc_install_jcagent_and_service_account](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent.md)

- Ensure that the credentials specified for the Jamf management account configured under "Settings" >  "Global Management" > "User-Initiated Enrollment" > "Platforms" > "macOS" align with the credentials specified for the `SECURETOKEN_ADMIN_USERNAME=''` and `SECURETOKEN_ADMIN_PASSWORD=''` in the configured Jamf script.
- To update and secure the credentials for this user you can use the JumpCloud agent to takeover this account and update the credentials post DEP enrollment.

For Mac versions < 10.13.x or all versions where JumpCloud will not be managing Filevault users use:[jc_install_jcagent](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent.md)