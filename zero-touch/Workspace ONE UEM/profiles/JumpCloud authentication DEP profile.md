# Add Profile

## Authentication

### Authentication

On

### Device Ownership

Corporate - Dedicated

### Device Organization Group

Your Work Space ONE UEM organization

### Custom Prompt

On

### Message Template

[DEP JumpCloud authentication prompt](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/message%20templates/DEP%20JumpCloud%20authentication%20prompt.md)

## MDM Features

Fill out the required fields with your organization specific information and leave the other settings at their defaults.

## Setup Assistant

### Account Setup

DON'T SKIP

### Account Type

Specify the type of account "STANDARD / ADMINISTRATOR" for local system accounts. "STANDARD" is recommended.

If selecting "ADMINISTRATOR" set `Create New Admin Account` to **YES**

## Admin Account Creation

The credentials configured here are passed in as command line arguments in the [JumpCloud zero-touch onboarding workflow]() file/action.

Be sure that the information entered for the below fields align with the command line arguments entered in this file/action.

This is required by the JumpCloud agent in order to grant JumpCloud managed users Securetokens and allow them to unlock FileVault encrypted disks.

### User name

Enter the username for your organizations universal local admin account

### Full name

Enter the full name for your organizations universal local admin account. This can be the same as the user name.

### Password

Enter the password for your organizations universal local admin account

### Hidden

Disabled