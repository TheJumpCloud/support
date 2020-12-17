#!/bin/bash

# agent_diagnostics.sh collects all artifacts required for troubleshooting,
# including logs, configuration files, and application files. Those artifacts
# are compressed into a zip file, along with an output file of relevant information
# about the system for quick reference and an inventory of the files included
# in the zip file.

# guard against the script being run in a non-POSIX shell environment
set +o posix

if [[ "${UID}" != 0 ]]; then
  (echo >&2 "Error:  $0 must be run as root")
  exit 1
fi

# Some global variables
JCPATH="/opt/jc"
JCLOG="/var/log/"
STAMP=$(date +"%Y%m%d%H%M%S")
ZIPFILE="./jc${STAMP}.zip"
TARFILE="./jc${STAMP}.tar"
declare -a INVENTORY

# Is jcagent installed? if not, exit.
if [[ ! -d "${JCPATH}" ]]; then
  echo "JCAGENT IS NOT INSTALLED ON THIS MACHINE."
  exit 1
fi

# Is zip installed?
if ! command -v zip 1>/dev/null; then
  ZPATH="false"
else
  ZPATH=$(command -v zip)
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
  if [[ "${ZPATH}" == "false" ]]; then
    if [[ -f "${TARFILE}" ]]; then
      mv "${TARFILE}" ./jc"${STAMP}".bak.tar
      tar -rf "${TARFILE}" "${INVENTORY[@]}" 1>/dev/null
    else
      ZIPIT="${TARFILE} has been created containing the following files:"
      tar -rf "${TARFILE}" "${INVENTORY[@]}" 1>/dev/null
    fi
  else
    if [[ -f "${ZIPFILE}" ]]; then
      mv "${ZIPFILE}" ./jc"${STAMP}".bak.zip
      zip -r "${ZIPFILE}" "${INVENTORY[@]}" 1>/dev/null
    else
      ZIPIT="${ZIPFILE} has been created containing the following files:"
      zip -r "${ZIPFILE}" "${INVENTORY[@]}" 1>/dev/null
    fi
  fi
}

function ziplog() {
  # Archive the log files.
  # This method should be called *after* `users` has been called
  USER_DIR="/Users"
  USER_AGENT_LOG_DIR="Library/Logs/JumpCloud"
  USER_AGENT_CURR_LOG="jc-user-agent.log"
  USER_AGENT_PREV_LOG="${USER_AGENT_CURR_LOG}.prev"
  LOGFILES=("jcagent.log" "jcagent.log.prev" "jcUpdate.log" "jctray.log" "jumpcloud-loginwindow" "jcagent-preinstall.log" "jcagent-postinstall.log" "jcUninstall.log")
  if [[ "${ZPATH}" == "false" ]]; then
    ARC_FILE="${TARFILE}"
    ZIP_CMD="tar -rf "
  else
    ARC_FILE="${ZIPFILE}"
    ZIP_CMD="zip -r "
  fi

  for i in "${LOGFILES[@]}"; do
    if [[ -f "${JCLOG}""${i}" ]] || [[ -d "${JCLOG}""${i}" ]]; then
      ${ZIP_CMD} "${ARC_FILE}" "${JCLOG}""${i}" 1>/dev/null
      LOGIT+=("${JCLOG}${i} has been added to ${ARC_FILE}.")
    fi
  done

  for u in "${USERS[@]}"; do
    USER_AGENT_LOG_BASE="${USER_DIR}/${u}/${USER_AGENT_LOG_DIR}"
    # Archive current log file, if it exists
    USER_AGENT_LOG_FILEPATH="${USER_AGENT_LOG_BASE}/${USER_AGENT_CURR_LOG}"
    if [[ -f "${USER_AGENT_LOG_FILEPATH}" ]]; then
      ${ZIP_CMD} "${ARC_FILE}" "${USER_AGENT_LOG_FILEPATH}" 1>/dev/null
      LOGIT+=("${USER_AGENT_LOG_FILEPATH} has been added to ${ARC_FILE}")
    fi
    # Archive previous log file, if it exists
    USER_AGENT_LOG_FILEPATH="${USER_AGENT_LOG_BASE}/${USER_AGENT_PREV_LOG}"
    if [[ -f "${USER_AGENT_LOG_FILEPATH}" ]]; then
      ${ZIP_CMD} "${ARC_FILE}" "${USER_AGENT_LOG_FILEPATH}" 1>/dev/null
      LOGIT+=("${USER_AGENT_LOG_FILEPATH} has been added to ${ARC_FILE}")
    fi
  done
}

function users() {
  # Get a list of users.
  USERLIST=()
  while IFS='' read -r line; do USERLIST+=("$line"); done < <(dscl . list /Users | grep -v '_')
  for i in "${USERLIST[@]}"; do
    if ! [[ ${i} == "root" ]] && ! [[ ${i} == "daemon" ]] && ! [[ ${i} == "nobody" ]]; then
      USERS+=("${i}")
    fi
  done
}

function sudoers() {
  # Get a list of the sudoers directory.
  SUDODIR="/etc/sudoers.d"
  SUDOLIST=()
  while IFS='' read -r line; do SUDOLIST+=("$line"); done < <(ls ${SUDODIR})
  for i in "${SUDOLIST[@]}"; do
    SUDOERS+=("${i}")
  done
}

function jconf() {
  # Grab the contents of jcagent.conf for quick display in the output.log file.
  JCAGENTCONFIG=()
  while IFS='' read -r line; do JCAGENTCONFIG+=("${line}"); done < <(sed 's/[{}]//g' "${JCPATH}"/jcagent.conf | tr ',' '\n')
  for i in "${JCAGENTCONFIG[@]}"; do
    if [[ "" != "${i}" ]]; then
      JCONF+=("${i}")
    fi
  done
}

function info_out() {
  # Write the output.log file.
  SERVICEVERSION=$(cat /opt/jc/version.txt)
  SYSINFO=$(sw_vers)
  STATUS=$(launchctl list | grep jumpcloud | cut -d'	' -f 1)
  TZONE=$(date +"%Z %z")

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
    printf "LOGS INCLUDED:\n"
    printf "%s\n" "${LOGIT[@]}" | indent
  } >output.log
  if [[ "${ZPATH}" == "false" ]]; then
    tar -rf "${TARFILE}" ./output.log 1>/dev/null
  else
    zip "${ZIPFILE}" ./output.log 1>/dev/null
  fi
}

function main() {
  # Launch it all.
  users
  sudoers
  zipjc
  ziplog
  jconf
  info_out
  cat ./output.log
}

main
