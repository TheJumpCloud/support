#### Name

Mac - Install Homebrew Apps | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Homebrew installation location
brew="/usr/local/bin/brew"

# Install Install CLI Tools
$brew install tree
$brew install wget
$brew install htop

# Brew Install macOS Applications
$brew cask install google-chrome
$brew cask install firefox
$brew cask install vlc

exit 0
```

#### Description

Installs list of Homebrew Apps - customize this script to fit your needs. If this command fails with error 124, it may have reached it's max runtime to report back to JumpCloud, the script itself may not have failed. Do not run this command as root - homebrew will error out. Run this command as the same user noted in the [Install Homebrew Package Manager](./Mac&#32;-&#32;Install&#32;Homebrew&#32;Package&#32;Manager.md) command.

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Je8u6'
```
