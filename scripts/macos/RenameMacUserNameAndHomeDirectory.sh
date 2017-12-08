#!/bin/bash

#
# Script to rename the user name of a user on OS X
#
# The script updates the users record name and home directory
# name from an old name to a new one.
#
# NOTE: MUST BE RUN AS ROOT!
#
abort() {
	errString=${*}
	echo "$errString"
	exit 1
}

if [[ ${#} -ne 2 ]]
then
	echo "Usage: $0 oldUserName newUserName"
	exit 1
fi

oldUser=$1
newUser=$2

if [[ -z "${newUser}" ]]
then
	abort "New user name must not be empty!"
fi

origHomeDir=`dscl . -read /Users/${oldUser} NFSHomeDirectory | awk '{print $2}' -`

if [[ -z "${origHomeDir}" ]]
then
	abort "Cannot obtain the original home directory name, is the oldUserName correct?"
fi

dscl . -change /Users/${oldUser} NFSHomeDirectory /Users/${oldUser} /Users/${newUser}
err=$?
if [ ${err} -ne 0 ]
then
	abort "Could not rename the user's home directory pointer, aborting further changes! - err=${err}"
fi

mv /Users/${oldUser} /Users/${newUser}
err=$?
if [[ ${err} -ne 0 ]]
then
	abort "Could not rename the user's home directory in /Users - the user may not be able to login unless you correct dscl to point back to /Users/${oldUser}"
fi

dscl . -change /Users/${oldUser} RecordName ${oldUser} ${newUser}
err=$?
if [[ ${err} -ne 0 ]]
then
	abort "Could not rename the user's RecordName in dscl - the user should still be able to login, but with user name ${oldUser}, however, their home directory will be pointed to /Users/${newUser}"
fi

echo "SUCCESS: ${oldUser} --> ${newUser}"

exit 0
