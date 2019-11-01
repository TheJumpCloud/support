#!/bin/bash
: '
 Script to rename the username of a user account on MacOS

 The script updates the users record name (username), and home directory

 If the user receiving the name change is signed in they will be signed out.

 Example usage: sudo sh RenameMacUserNameAndHomeDirectory.sh cat dog

 Above example would rename account cat to dog

 NOTE: SCRIPT MUST BE RUN AS ROOT
 NOTE: SYSTEM WILL RESTART AFTER SUCCESSFUL NAME UPDATE
'
# Ensures that script is run as ROOT
if [[ "${UID}" != 0 ]]; then
	(echo >&2 "Error: $0 script must be run as root")
	exit 1
fi

# Ensures that the system is not domain bound
readonly domainBoundCheck=$(dsconfigad -show)
if [[ "${domainBoundCheck}" ]]; then
	(echo >&2 "Cannot run on domain bound system. Unbind system and try again.")
	exit 1
fi

# Ensures that parameters are entered
if [[ ${#} -ne 2 ]]; then
	echo "Usage: $0 oldUserName newUserName"
	exit 1
fi

oldUser=$1
newUser=$2

# Test to ensure logged in user is not being renamed
readonly loggedInUser=$(ls -la /dev/console | cut -d " " -f 4)
if [[ "${loggedInUser}" == "${oldUser}" ]]; then
	echo "Cannot rename active GUI logged in user. Log in with another admin account and try again."
	exit 1
fi

# Verify valid username
if [[ -z "${newUser}" ]]; then
	echo "New user name must not be empty!"
	exit 1
fi

# Test to ensure account update is needed
if [[ "${oldUser}" == "${newUser}" ]]; then
	echo "No updates needed"
	exit 0
fi

# Query existing user accounts
readonly existingUsers=($(dscl . -list /Users | grep -Ev "^_|com.*|root|nobody|daemon|\/" | cut -d, -f1 | sed 's|CN=||g'))

# Ensure old user account is correct and account exists on system
if [[ ! " ${existingUsers[@]} " =~ " ${oldUser} " ]]; then
	echo "${oldUser} account not present on system to update"
	exit 1
fi

# Ensure new user account is not already in use
if [[ " ${existingUsers[@]} " =~ " ${newUser} " ]]; then
	echo "${newUser} account already present on system. Cannot add duplicate"
	exit 1
fi

# Query existing home folders
readonly existingHomeFolders=($(ls /Users))

# Ensure existing home folder is not in use
if [[ " ${existingHomeFolders[@]} " =~ " ${newUser} " ]]; then
	echo "${newUser} home folder already in use on system. Cannot add duplicate"
	exit 1
fi

# Checks if user is logged in
loginCheck=$(ps -Ajc | grep ${oldUser} | grep loginwindow | awk '{print $2}')

# Logs out user if they are logged in
timeoutCounter='0'
while [[ "${loginCheck}" ]]; do
	echo "${oldUser} account logged in. Logging user off to complete username update."
	sudo launchctl bootout gui/$(id -u ${oldUser})
	Sleep 5
	loginCheck=$(ps -Ajc | grep ${oldUser} | grep loginwindow | awk '{print $2}')
	timeoutCounter=$((${timeoutCounter} + 1))
	if [[ ${timeoutCounter} -eq 4 ]]; then
		echo "Timeout unable to log out ${oldUser} account."
		exit 1
	fi
done

# Captures current NFS home directory
readonly origHomeDir=$(dscl . -read "/Users/${oldUser}" NFSHomeDirectory | awk '{print $2}' -)

if [[ -z "${origHomeDir}" ]]; then
	echo "Cannot obtain the original home directory name, is the oldUserName correct?"
	exit 1
fi

# Updates NFS home directory
sudo dscl . -change "/Users/${oldUser}" NFSHomeDirectory "${origHomeDir}" "/Users/${newUser}"

if [[ $? -ne 0 ]]; then
	echo "Could not rename the user's home directory pointer, aborting further changes! - err=$?"
	echo "Reverting Home Directory changes"
	sudo dscl . -change "/Users/${oldUser}" NFSHomeDirectory "/Users/${newUser}" "${origHomeDir}"
	exit 1
fi

# Updates name of home directory to new username
mv "${origHomeDir}" "/Users/${newUser}"

if [[ $? -ne 0 ]]; then
	echo "Could not rename the user's home directory in /Users"
	echo "Reverting Home Directory changes"
	mv "/Users/${newUser}" "${origHomeDir}"
	sudo dscl . -change "/Users/${oldUser}" NFSHomeDirectory "/Users/${newUser}" "${origHomeDir}"
	exit 1
fi

# Actual username change
sudo dscl . -change "/Users/${oldUser}" RecordName "${oldUser}" "${newUser}"

if [[ $? -ne 0 ]]; then
	echo "Could not rename the user's RecordName in dscl - the user should still be able to login, but with user name ${oldUser}"
	echo "Reverting username change"
	sudo dscl . -change "/Users/${oldUser}" RecordName "${newUser}" "${oldUser}"
	echo "Reverting Home Directory changes"
	mv "/Users/${newUser}" "${origHomeDir}"
	sudo dscl . -change "/Users/${oldUser}" NFSHomeDirectory "/Users/${newUser}" "${origHomeDir}"
	exit 1
fi

# Links old home directory to new. Fixes dock mapping issue
ln -s "/Users/${newUser}" "${origHomeDir}"

# Success message
read -r -d '' successOutput <<EOM
Success ${oldUser} username has been updated to ${newUser}
Folder "${origHomeDir}" has been renamed to "/Users/${newUser}"
RecordName: ${newUser}
NFSHomeDirectory: "/Users/${newUser}"

SYSTEM RESTARTING in 5 seconds to complete username update.
EOM

echo "${successOutput}"

# System restart
Sleep 5
osascript -e 'tell application "System Events" to restart'
exit 0
