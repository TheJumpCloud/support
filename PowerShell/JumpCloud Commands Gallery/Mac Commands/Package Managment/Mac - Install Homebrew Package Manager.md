#### Name

Mac - Install Homebrew Package Manager | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Good Conversation here
# https://www.jamf.com/jamf-nation/discussions/20938/installing-brew-and-then-hopefully-gcc-using-brew
# Brew deploy
# Tested on Homebrew 1.0.8

#v1.0 Daniel Shane 28/10/2016 - First Version
#v1.1 16/11/2016 - Typeo and fixed missing group folders
#v1.2 12/01/2017 - Opt out of brew analytics, thanks Geo for finding this

# Set the Default Admin account used to manage Homebrew
useris="defaultadmin"

# Default Admin user needs to exist for this script to function
if [[ ! -d /Users/$useris ]]; then
  exit 1
fi

# Check to make sure we are root
if [ `id -u` != "0" ]
then
   echo "`basename "$0"` MUST run as root..."
   exit 1
fi

#Get macOS version
macosv=`sw_vers -productVersion | cut -d . -f 1,2`

#Set varaiables
HOMEBREW_PREFIX="/usr/local"
HOMEBREW_REPOSITORY="/usr/local/Homebrew"
HOMEBREW_CACHE="/Users/$useris/Library/Caches/Homebrew"
BREW_REPO="https://github.com/Homebrew/brew"
CORE_TAP_REPO="https://github.com/Homebrew/homebrew-core"

# Exit if Xcode CLI is not installed
if [ ! -d /Library/Developer ] ; then
    echo "Command Line Tools not installed"
    exit 1
fi

#Make Brew Folders
/bin/mkdir -p /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/man /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var

#Set Permissions
/bin/chmod g+rwx /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/man /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
/bin/chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions

#Set owner on folders
/usr/sbin/chown $useris /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/man /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
/usr/bin/chgrp admin /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/man /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
/bin/mkdir -p /Users/$useris/Library/Caches/Homebrew
/bin/chmod g+rwx /Users/$useris/Library/Caches/Homebrew
/usr/sbin/chown $useris /Users/$useris/Library/Caches/Homebrew

#Group Folder Permissions
/usr/sbin/chown $useris /usr/local/bin /usr/local/etc /usr/local/Frameworks /usr/local/include /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/etc/bash_completion.d /usr/local/lib/pkgconfig /usr/local/var/log /usr/local/share/aclocal /usr/local/share/doc /usr/local/share/info /usr/local/share/locale /usr/local/share/man /usr/local/share/man/man1 /usr/local/share/man/man2 /usr/local/share/man/man3 /usr/local/share/man/man4 /usr/local/share/man/man5 /usr/local/share/man/man6 /usr/local/share/man/man7 /usr/local/share/man/man8 &> /dev/null
/usr/bin/chgrp admin /usr/local/bin /usr/local/etc /usr/local/Frameworks /usr/local/include /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/etc/bash_completion.d /usr/local/lib/pkgconfig /usr/local/var/log /usr/local/share/aclocal /usr/local/share/doc /usr/local/share/info /usr/local/share/locale /usr/local/share/man /usr/local/share/man/man1 /usr/local/share/man/man2 /usr/local/share/man/man3 /usr/local/share/man/man4 /usr/local/share/man/man5 /usr/local/share/man/man6 /usr/local/share/man/man7 /usr/local/share/man/man8 &> /dev/null

#Download and install Homebrew
# we do it in four steps to avoid merge errors when reinstalling
# We also do it as the consol user to make sure perms are correct for the repo
cd $HOMEBREW_REPOSITORY
sudo -u "$useris" /usr/bin/git init -q
# "git remote add" will fail if the remote is defined in the global config
sudo -u "$useris" /usr/bin/git config remote.origin.url $BREW_REPO
sudo -u "$useris" /usr/bin/git config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
# ensure we don't munge line endings on checkout
sudo -u "$useris" /usr/bin/git config core.autocrlf false
sudo -u "$useris" /usr/bin/git fetch origin master:refs/remotes/origin/master --tags --force --depth=1
sudo -u "$useris" /usr/bin/git reset --hard origin/master
sudo -u "$useris" /bin/ln -sf $HOMEBREW_REPOSITORY/bin/brew $HOMEBREW_PREFIX/bin/brew

#Update brew as user
sudo -u "$useris" $HOMEBREW_PREFIX/bin/brew update --force

#Opt out of brew analytics
sudo -u "$useris" $HOMEBREW_PREFIX/bin/brew analytics off

exit 0
```

#### Description

Installs Homebrew to a mac system without user input. Note: change the defaultadmin user account to match a default admin account in your environment.

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JelTB'
```