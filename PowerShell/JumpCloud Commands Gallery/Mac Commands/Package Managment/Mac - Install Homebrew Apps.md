#### Name

Mac - Install Homebrew Apps | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Assuming homebrew is installed, Install standard set of applications
brew="/usr/local/bin/brew"

# Brew List
$brew install tree
$brew install wget
$brew install htop

# in console text editor
$brew install micro
```

#### Description

Installs list of Homebrew Apps - customize this script to fit your needs. If this command fails with error 124, it may have reached it's max runtime to report back to JumpCloud, the script itself may not have failed.

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JelTB'
```
