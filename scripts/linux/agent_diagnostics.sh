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
declare -a INVENTORY

# Is jcagent installed? If not, exit.
if [[ ! -d "${JCPATH}" ]]; then
  echo "JCAGENT IS NOT INSTALLED ON THIS MACHINE."
  exit 1
fi

# Is zip installed?
if [[ -z "$(which zip)" ]]; then
  ZPATH="false"
else
  ZPATH=$(which zip)
fi

function indent() {
  # Formatting for output.log
  sed 's/^/\t\t/g'
}

function zipjc() {
  # Take inventory of files to be zipped
  for i in *; do
    INVENTORY+=("${i}")
  done

  # check to see if zip exists.
  if [[ "$ZPATH" = "false" ]]; then
    ZIPIT="zip is not installed. please send the following files with your support request:\n${INVENTORY[@]}"
  else
    if [[ -f "${ZIPFILE}" ]]; then
      mv "${ZIPFILE}" ./jc"${STAMP}".bak.zip
      zip -r "*.crt" -r "${ZIPFILE}" "${JCPATH}" > /dev/null 1
    else
      ZIPIT="${ZIPFILE} has been created, containing the following files:"
      zip -x "*.crt" -r "${ZIPFILE}" "${JCPATH}" > /dev/null 1
    fi
  fi
}

function ziplog() {
  # Zip the log files. 
  LOGFILES=("jcagent.log" "jcUpdate.log")
  for i in "${LOGFILES[@]}"; do
    if [ -f "${JCLOG}""${i}" ]; then
      zip "${ZIPFILE}" "${JCLOG}""${i}" > /dev/null 1
      LOGIT+=("${JCLOG}${i} has been successfully added to ${ZIPFILE}.")
    else
      LOGIT+=("${JCLOG}${i} doesn't exist.")
    fi
  done
}

function users() {
  # Get a list of users.
  PSWDFILE="/etc/passwd"
  USERLIST=( $(grep -v "nologin" ${PSWDFILE} | cut -d':' -f 1) )
  for i in "${USERLIST[@]}"; do
    if ! [[ "${i}" == 'root' ]] && ! [[ "${i}" == 'halt' ]] && ! [[ "${i}" == 'restart' ]]; then
    	USERS+=("${i}")
    fi
  done
}

function sudoers() {
  # Get a list of the sudoers list.
  SUDODIR="/etc/sudoers.d"
  SUDOLIST=( $(ls ${SUDODIR}) )
  for i in "${SUDOLIST[@]}"; do
    SUDOERS+=("${i}")
  done
}

function jconf() {
  # Get and format the contents of the jcagent.conf for quick display in the output.log.
  JCAGENTCONFIG=( $(sed 's/,/\n/g' "${JCPATH}"/jcagent.conf | sed 's/[{}]//g') )
  for i in "${JCAGENTCONFIG[@]}"; do
    JCONF+=("${i}")
  done
}

function info_out() {
  # Write the output.log file.
  SERVICEVERSION=$( cat /opt/jc/version.txt )
  SYSINFO=$( uname -rs )
  OS=$( grep PRETTY_NAME /etc/os-release | sed 's/\=/:/g' | cut -d':' -f 2 | sed 's/\"//g' )
  SERVICE="jcagent"
  STATUS=$( service ${SERVICE} status )
  TZONE=$( date +"%Z %z" )

  if [[ -f ./output.log ]]; then
    mv output.log output."${STAMP}".log
  fi
  {
  printf "OS/BUILD INFO:\n"
  printf "%s\n" "${OS}" | indent
  printf "%s\n" "${SYSINFO}" | indent
  printf "JCAGENT VERSION:\n"
  printf "%s\n" "${SERVICEVERSION}" | indent
  printf "JCAGENT STATUS:\n"
  printf "%s\n" "${STATUS}" | indent
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
  zip "${ZIPFILE}" ./output.log > /dev/null 1
}

function main() {
  # launch it all
  zipjc
  ziplog
  users
  sudoers
  jconf
  info_out
  cat ./output.log
}

main
