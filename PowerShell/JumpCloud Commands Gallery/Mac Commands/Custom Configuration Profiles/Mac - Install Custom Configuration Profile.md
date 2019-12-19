#### Name

Mac - Install Custom Configuration Profile | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Name of the .mobileconfig file
profile=""

# Installs a profile to the selected system
/usr/bin/profiles -I -F "/tmp/${profile}"

# get UUID
```

#### Description

This command will install a .mobileconfig file to a given system. A valid .mobilecongif file is required for this command to install anything. By default the /tmp/ location is used to store the .mobileconfig file. Insert the name of the .mobileconfig file in the profile variable field.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Je5DS''
```
