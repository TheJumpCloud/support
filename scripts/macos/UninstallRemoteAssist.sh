#!/usr/bin/env bash
set -euo pipefail

function get_app_pid() {
    local -r APP_NAME=$1
    ps -eo pid,comm | awk "/${APP_NAME}$/ {print \$1}"
}

function remove_app_by_name() {
    local -r APP_NAME=$1
    if PID=$(get_app_pid "${APP_NAME}") && [[ -n "${PID}" ]]; then
        kill -s TERM "${PID}"
        sleep 1
    fi
    if PID=$(get_app_pid "${APP_NAME}") && [[ -n "${PID}" ]]; then
        kill -s KILL "${PID}"
    fi

    sudo rm -Rdf "/Applications/${APP_NAME}.app"
}

# Clean up installs having legacy name
remove_app_by_name "Jumpcloud Assist App"
# Clean up installs
remove_app_by_name "JumpCloud Remote Assist"
