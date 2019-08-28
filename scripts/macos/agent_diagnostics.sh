#!/bin/bash

# agent_diagnostics.sh collects all artifacts required for troubleshooting,
# including logs, configuration files, and application files. Those artifacts
# are compressed into a zip file, along with an output file of relevant information
# about the system for quick referrence and an inventory of the files included
# in the zip file.

if [[ "${UID}" != 0 ]]; then
  (>&2 echo "Error:  $0 must be run as root")
  exit 1
fi

# Some global variables
JCPATH="/opt/jc"
JCLOG="/var/log/"
STAMP=$( date +"%Y%m%d%H%M%S" )
ZIPFILE="./jc${STAMP}.zip"
TARFILE="./jc${STAMP}.tar"
declare -a INVENTORY

# Is jcagent installed? if not, exit.
if [[ ! -d "${JCPATH}" ]]; then
  echo "JCAGENT IS NOT INSTALLED ON THIS MACHINE."
  exit 1
fi

# Is zip installed?
if ! which zip 1> /dev/null; then
  ZPATH="false"
else
  ZPATH=$(which zip)
fi

function indent() {
	sed 's/^/'$'\t'$'\t/g'
}

function zipjc() {
  # Take inventory of files to be zipped.
  for i in "${JCPATH}"/*; do
    if [[ "${i}" != *.crt* ]] && [[ "${i}" != *.key* ]]; then
      INVENTORY+=("${i}")
    fi
  done

  # check to see if zip exists.
  if [[ "${ZPATH}" = "false" ]]; then
    if [[ -f "${TARFILE}" ]]; then
      mv "${TARFILE}" ./jc"${STAMP}".bak.tar
      tar -rf "${TARFILE}" "${INVENTORY[@]}" 1> /dev/null
    else
      ZIPIT="${TARFILE} has been created containing the following files:"
      tar -rf "${TARFILE}" "${INVENTORY[@]}" 1> /dev/null
    fi
  else
    if [[ -f "${ZIPFILE}" ]]; then
      mv "${ZIPFILE}" ./jc"${STAMP}".bak.zip
      zip -r "${ZIPFILE}" "${INVENTORY[@]}" 1> /dev/null
    else
      ZIPIT="${ZIPFILE} has been created containing the following files:"
      zip -r "${ZIPFILE}" "${INVENTORY[@]}" 1> /dev/null
    fi
  fi
}

function ziplog() {
  # Zip the log files. 
  LOGFILES=("jcagent.log" "jcUpdate.log" "jclocalclient.log" "jctray.log" "jumpcloud-loginwindow")
  if [[ "${ZPATH}" = "false" ]]; then
    for i in "${LOGFILES[@]}"; do
      if [[ -f "${JCLOG}""${i}" ]] || [[ -d "${JCLOG}""${i}" ]]; then
        tar -rf "${TARFILE}" "${JCLOG}""${i}" 1> /dev/null
        LOGIT+=("${JCLOG}${i} has been added to ${TARFILE}.")
      fi
    done
  else
    for i in "${LOGFILES[@]}"; do
      if [[ -f "${JCLOG}""${i}" ]] || [[ -d "${JCLOG}""${i}" ]]; then
        zip -r "${ZIPFILE}" "${JCLOG}""${i}" 1> /dev/null 
        LOGIT+=("${JCLOG}${i} has been added to ${ZIPFILE}.")
      fi
    done
  fi
}

function users() {
  # Get a list of users.
  USERLIST=( $(dscl . list /Users | grep -v '_') )
  for i in "${USERLIST[@]}"; do
    if ! [[ ${i} == "root" ]] && ! [[ ${i} == "daemon" ]] && ! [[ ${i} == "nobody" ]]; then
      USERS+=("${i}")
    fi
  done
}

function sudoers() {
  # Get a list of the sudoers directory.
  SUDODIR="/etc/sudoers.d"
  SUDOLIST=( $(ls ${SUDODIR}) )
  for i in "${SUDOLIST[@]}"; do
    SUDOERS+=("${i}")
  done
}

function jconf() {
  # Grab the contents of jconf for quick display in the output.log file.
  JCAGENTCONFIG=( $(sed 's/[{}]//g' "${JCPATH}"/jcagent.conf | tr ',' '\n') )
  for i in "${JCAGENTCONFIG[@]}"; do
    JCONF+=("${i}")
  done
}

function info_out() {
  # Write the output.log file.
  SERVICEVERSION=$( cat /opt/jc/version.txt )
  SYSINFO=$( sw_vers )
  STATUS=$( launchctl list | grep jumpcloud | cut -d'	' -f 1 )
  TZONE=$( date +"%Z %z" )

  if [[ -f ./output.log ]]; then
    mv output.log output."${STAMP}".log
  fi
  {
  printf "OS/BUILD INFO:\n"
  printf "%s\n" "${SYSINFO}" | indent
  printf "JCAGENT VERSION:\n"
  printf "%s\n" "${SERVICEVERSION}" | indent
  printf "JCAGENT STATUS:\n"
  printf "PID = %s" " ${STATUS}" | indent
  printf "TIMEZONE:\n"
  printf "%s\n" "${TZONE}" | indent
  printf "SYSTEM USERS:\n"
  printf "%s\n" "${USERS[@]}" | indent
  printf "SUDOERS:\n"
  printf "%s\n" "${SUDOERS[@]}" | indent
  printf "JCAGENT CONFIGURATION:\n"
  printf "%s\n" "${JCONF[@]}" | indent
  printf "FILES INCLUDED:\n"
  printf "%s\n" "${ZIPIT}" | indent
  printf "%s\n" "${INVENTORY[@]}" | indent
  printf "LOGS INCLUDED FROM %s:\n" "${JCLOG}"
  printf "%s\n" "${LOGIT[@]}" | indent
  } > output.log
  if [[ "${ZPATH}" = "false" ]]; then
    tar -rf "${TARFILE}" ./output.log 1> /dev/null
  else
    zip "${ZIPFILE}" ./output.log 1> /dev/null
  fi
}

function main() {
  # Launch it all.
  zipjc
  ziplog
  users
  sudoers
  jconf
  info_out
  cat ./output.log
}

main
