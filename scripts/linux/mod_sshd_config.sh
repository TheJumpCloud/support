#!/bin/bash

if [[ "${UID}" != 0 ]]; then
  (>&2 echo "Error:  $0 must be run as root")
  exit 1
fi

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old

if [[ $? != 0 ]]; then
  echo "unable to backup current sshd_config, exiting"
  exit 1
fi

cat << EOF >> /etc/ssh/sshd_config
# BeginGlobalExceptions
Match All
  PasswordAuthentication yes
  PubkeyAuthentication yes
  AuthenticationMethods password publickey
# GlobalExceptionsEnd
EOF

check=$(systemctl --version >/dev/null 2>&1)

if [[ "${check}" = 0 ]]; then
  restart=$(systemctl restart sshd)
else
  restart=$(service sshd restart)
fi

eval "${restart}"

if [[ $? != 0 ]]; then
  echo "sshd did not restart properly, reverting to original sshd_config"
  mv --force /etc/ssh/sshd_config.old /etc/ssh/sshd_config
  eval "${restart}"
  exit 1
fi
