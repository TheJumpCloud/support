#### Name

Linux - remote-assist - Installation script | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/usr/bin/env bash
################################################################################
# This script will install remote assist application on a Linux device
################################################################################

# Disable following external sources
# shellcheck disable=SC1091,SC1090,SC2059

if [[ "${UID}" != 0 ]]; then
    (>&2 echo "Error: $0 must be run as root")
    exit 1
fi

set -u

# set the RAA version string in the below variable before running the script.
# the example format of version: v0.75.0
declare -t raa_version=""

if [[ "$raa_version" == "" ]]; then
    echo "'raa_version' need to be provided in the script (eg. v0.75.0)"
    exit 0
fi

tmp_dir=$(mktemp -d)
arch="$(uname -m)"
echo $(arch)

declare -r timeout=900
declare -r max_retries=4
declare -r max_retry_time=3600

declare -r tmp_dir

declare -r pub_key_name="jumpcloud-remote-assist-agent.gpg.asc"
declare -r raa_binary_name="jumpcloud-remote-assist"
declare -r raa_binary_path="$raa_directory/jumpcloud-remote-assist"

declare -r install_prefix="/opt/jc_user_ro"
declare -r apps_path="/usr/share/applications"
declare -r raa_directory="${install_prefix}/jumpcloud-remote-assist"
declare -r raa_desktop_file="${raa_directory}/resources/build-app/linux/jumpcloud-remote-assist.desktop"
declare -r uninstaller_path="${install_prefix}/bin/uninstall-${raa_binary_name}"
declare -r raa_service_install_file="${raa_directory}/resources/build-app/linux/raasvc-install.sh"

declare -r remote_pub_key_url="https://cdn02.jumpcloud.com/production/remote-assist/jumpcloud-remote-assist-agent.gpg.asc"
declare -r remote_tgz_url="https://cdn02.jumpcloud.com/production/remote-assist/versions/${raa_version}/jumpcloud-remote-assist-agent_${arch}.tar.gz"

declare -r old_pub_key_fingerprint="83463C47A34D1BC1"
declare -r pub_key_fingerprint="8C31C1376B37D307"
declare -r owner_trust="C2122200660347DB094054808C31C1376B37D307:6:"
declare -r tgz_name="jumpcloud-remote-assist-agent.tar.gz"
declare -r sig_name="${tgz_name}.zig"

declare -r local_pub_key_path="${tmp_dir}/${pub_key_name}"
declare -r local_tgz_tmp_path="${tmp_dir}/${tgz_name}"
declare -r local_sig_tmp_path="${tmp_dir}/${sig_name}"

declare -r remote_sig_url="${remote_tgz_url}.sig"

function cleanup() {
  rm -rf "${tmp_dir}"
}

function download_single_file() {
  local url=${1}
  local local_file=${2}

  echo "Downloading ${url}"

  curl_output=$(curl -v --trace-time \
    --max-time "${timeout}" --retry "${max_retries}" \
    --retry-max-time "${max_retry_time}" \
    --output "${local_file}" "${url}" -C - 2>&1)

  rc=$?
  if [[ "$rc" != "0" ]]; then
    echo "Failed to download ${url}"
    echo "${curl_output}"
    exit ${rc}
  fi
}

function remove_old_pub_key() {
  if gpg --list-keys | grep -q "${old_pub_key_fingerprint}"; then
    echo "Removing old public key ${old_pub_key_fingerprint}"
    gpg  --batch --yes --delete-key "${old_pub_key_fingerprint}"
  fi
}

function install_pub_key() {
  remove_old_pub_key

  output=$(gpg --list-keys | grep "${pub_key_fingerprint}")
  if [[ "${output}" == "" ]]; then
    download_single_file "${remote_pub_key_url}" "${local_pub_key_path}"
    echo "Importing public key ${pub_key_fingerprint}"
    gpg --import "${local_pub_key_path}"
    echo "${owner_trust}" | gpg --import-ownertrust
  fi
}

function verify_signature() {
  local sig="${1}"
  local tgz="${2}"
  gpg --verify "${sig}" "${tgz}" 2>&1
}

function download_files() {
  download_single_file "${remote_tgz_url}" "${local_tgz_tmp_path}"
  download_single_file "${remote_sig_url}" "${local_sig_tmp_path}"
  if ! verify_signature "${local_sig_tmp_path}" "${local_tgz_tmp_path}"; then
    echo "Unable to verify signature for ${tgz_name}"
    exit 1
  fi
}

function uncompress_tarball() {
  echo "Installing new RAA"
  mkdir -p "${install_prefix}"
  chmod 755 "${install_prefix}"
  tar zxf "${local_tgz_tmp_path}" -C "${install_prefix}"
}

function remove_old_raa_dir() {
  if [[ -d "${raa_directory}" ]]; then
    echo "Removing old RAA"
    rm -rf "${raa_directory}"
  fi
}

function kill_running_raa_instance() {
  local pid_list
  pid_list=$(pidof "${raa_binary_path}")
  for raa_pid in ${pid_list}; do
    echo "Stopping remote assist process ${raa_pid}"
    kill -9 "${raa_pid}"
  done
}

function install_new_raa() {
  remove_old_raa_dir
  uncompress_tarball
}

function install_desktop_file() {
  echo "Installing desktop shortcut"
  if [[ -d "${apps_path}" ]]; then
    cp "${raa_desktop_file}" "${apps_path}"
    if command -v "update-desktop-database" &>/dev/null; then
      update-desktop-database
    fi
  fi
}

function install_raasvc_file() {
  echo "Installing raasvc and raal service"
  if [[ -f "${raa_service_install_file}" ]]; then
    chmod +x "${raa_service_install_file}"
    /bin/bash "${raa_service_install_file}"
  fi
}

function install_uninstall_script() {
  mkdir -p "$(dirname "${uninstaller_path}")"
  cat > "${uninstaller_path}" <<'EOF'
{{template "linuxUninstall.tmpl.sh" .}}
EOF
  chmod -x "${uninstaller_path}"
  chmod 700 "${uninstaller_path}"
}

function main() {
  trap cleanup EXIT
  install_pub_key
  download_files
  kill_running_raa_instance
  install_new_raa
  install_desktop_file
  install_raasvc_file
  install_uninstall_script
}

main
```

#### Description

This script installs rempte assist application on the Linux machine.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20remote-assist%20-%20Installation%20script.md"
```
