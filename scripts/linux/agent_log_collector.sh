#!/bin/bash

## Has jcagent been installed? If not, exit
if [[ -z $( service jcagent status ) ]]; then
  printf "JCAGENT IS NOT INSTALLED ON THIS MACHINE, THERE IS NOTHING MORE TO DO\n" >> output.log
  exit 0
fi

## Some global variables
SYSINFO=$( uname -rs )
OS=$( grep PRETTY_NAME /etc/os-release | sed 's/\=/:/g' | cut -d':' -f 2 | sed 's/\"//g' )
SERVICE="jcagent"
SERVICEVERSION=$( cat /opt/jc/version.txt )
JCPATH="/opt/jc"
JCLOG="/var/log/"
STAMP=$( date +"%Y%m%d%H%M%S" )
TZONE=$( date +"%Z %z" )
STATUS=$( service ${SERVICE} status )
ZIPFILE="./jc${STAMP}.zip"
if [ -z $(which zip) ]; then
  ZPATH="false"
else
  ZPATH=$(which zip)
fi

function indent() {
  ## Formatting for output.log
  sed 's/^/\t\t/g'
}

function zipjc() {
  ## Take inventory of files to be zipped
  INVENTORY=$( ls ${JCPATH} | grep -v '.crt' )

  ## check to see if zip exists.
  if [ $ZPATH = "false" ]; then
    ZIPIT="zip is not installed. please send the following files with your support request:\n${INVENTORY}"
  else
    if [ -f ${ZIPFILE} ]; then
      mv ${ZIPFILE} ./jc"${STAMP}".bak.zip
      zip -r "*.crt" -r ${ZIPFILE} ${JCPATH} > /dev/null 1
    else
      ZIPIT="${ZIPFILE} has been created, containing the following files:\n${INVENTORY}"
      zip -x "*.crt" -r ${ZIPFILE} ${JCPATH} > /dev/null 1
    fi
  fi
}

function ziplog() {
  ## Zip the log files. 
  LOGFILES=("jcagent.log" "jcUpdate.log")
  for i in ${LOGFILES[@]}; do
    if [ -f ${JCLOG}${i} ]; then
      zip ${ZIPFILE} ${JCLOG}${i} > /dev/null 1
      LOGIT+=("${JCLOG}${i} has been successfully added to ${ZIPFILE}.\n")
    else
      LOGIT+=("${JCLOG}${i} doesn't exist.\n")
    fi
  done
}

function users() {
  ## Get a list of users.
  PSWDFILE="/etc/passwd"
  USERLIST=( $(grep -v "nologin" ${PSWDFILE} | cut -d':' -f 1) )
  for i in ${USERLIST[@]}; do
    if ! [ ${i} == 'root' ] && ! [ ${i} == 'halt' ] && ! [ ${i} == 'restart' ]; then
    	USERS+=("${i}\n")
    fi
  done
}

function sudoers() {
  ## Get a list of the sudoers list.
  SUDODIR="/etc/sudoers.d"
  SUDOLIST=( $(ls ${SUDODIR}) )
  for i in ${SUDOLIST[@]}; do
    SUDOERS+=("${i}\n")
  done
}

function jconf() {
  ## Get and format the contents of the jcagent.conf for quick display in the output.log.
  JCAGENTCONFIG=( $(cat ${JCPATH}/jcagent.conf | sed 's/,/\n/g' | sed 's/[{}]//g') )
  for i in ${JCAGENTCONFIG[@]}; do
    JCONF+=("${i}\n")
  done
}

function info_out() {
  ## Write the output.log file.
  if [ -f ./output.log ]; then
    mv output.log output.${STAMP}.log
  fi
  printf "OS/BUILD INFO:\n" > output.log
  printf "${OS}\n" | indent >> output.log
  printf "${SYSINFO}\n" | indent >> output.log
  printf "JCAGENT VERSION:\n" >> output.log
  printf "${SERVICEVERSION}\n" | indent >> output.log
  printf "JCAGENT STATUS:\n" >> output.log
  printf "${STATUS}\n" | indent >> output.log
  printf "TIMEZONE:\n" >> output.log
  printf "${TZONE}\n" | indent >> output.log
  printf "SYSTEM USERS:\n" >> output.log
  printf "${USERS[*]}\n" | indent >> output.log
  printf "SUDOERS:\n" >> output.log
  printf "${SUDOERS[*]}\n" | indent >> output.log
  printf "JCAGENT CONFIGURATION:\n" >> output.log
  printf "${JCONF[*]}\n" | indent >> output.log
  printf "FILES INCLUDED:\n" >> output.log
  printf "${ZIPIT}\n" | indent >> output.log
  printf "LOGS INCLUDED FROM ${JCLOG}:\n" >> output.log
  printf "${LOGIT[*]}\n" | indent >> output.log
  zip ${ZIPFILE} ./output.log > /dev/null 1
}

## launch it all
zipjc
ziplog
users
sudoers
jconf
info_out
cat ./output.log
