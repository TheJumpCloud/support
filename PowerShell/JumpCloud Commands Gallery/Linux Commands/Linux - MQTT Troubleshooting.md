#### Name

Linux - MQTT Troubleshooting script | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash
################################################################################
# This script is used for MQTT Troubleshooting
# Requires: netcat (nc), openssl
################################################################################

if [[ "${UID}" != 0 ]]; then
    (>&2 echo "Error:  $0 must be run as root")
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
# Default values
BROKER="a1hrq03pdcca60-ats.iot.us-east-1.amazonaws.com"
PORT=443
TIMEOUT=10
USE_TLS=true
CA_CERT_PATH="/etc/ssl/certs"
CLIENT_CERT="/opt/jc/client.crt"
CLIENT_KEY="/opt/jc/client.key"
VERBOSE=false
# Help function
show_help() {
    echo "MQTT Troubleshooting Script"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -b, --broker         MQTT Broker address (required)"
    echo "  -p, --port           Broker port (default: 1883)"
    echo "  --tls                Use TLS connection"
    echo "  --ca-cert-path       Path to CA certificate"
    echo "  --client-cert        Path to client certificate"
    echo "  --client-key         Path to client key"
    echo "  -v, --verbose        Enable verbose output"
    exit 1
}
# Parse command line arguments
PARSED_ARGUMENTS=$(getopt -a -n mqtt-troubleshooter -o hvb:p: --long help,verbose,broker:,port:,tls,ca-cert:,client-cert:,client-key: -- "$@")
VALID_ARGUMENTS=$?
[ $VALID_ARGUMENTS -ne 0 ] && show_help
eval set -- "$PARSED_ARGUMENTS"
while :
do
    case "$1" in
        -h | --help)         show_help; shift ;;
        -b | --broker)       BROKER="$2"; shift 2 ;;
        -p | --port)         PORT="$2"; shift 2 ;;
        --tls)               USE_TLS=true; shift ;;
        --ca-cert-path)      CA_CERT_PATH="$2"; shift 2 ;;
        --client-cert)       CLIENT_CERT="$2"; shift 2 ;;
        --client-key)        CLIENT_KEY="$2"; shift 2 ;;
        -v | --verbose)      VERBOSE=true; shift ;;
        --) shift; break ;;
        *) echo "Unexpected option: $1"; show_help ;;
    esac
done
# Validate required arguments
if [ -z "$BROKER" ]; then
    echo "${RED}Error: Broker address is required${NC}"
    show_help
fi
# Logging function
log() {
    local level="$1"
    local message="$2"
    local color=""
    case "$level" in
        "INFO")  color=$GREEN ;;
        "WARN")  color=$YELLOW ;;
        "ERROR") color=$RED ;;
        "DEBUG") color=$BLUE ;;
        *)       color=$NC ;;
    esac
    if [ "$VERBOSE" = true ] || [ "$level" != "DEBUG" ]; then
        echo -e "${color}[${level}]${NC} $message"
    fi
}
# Network connectivity check
check_network() {
    log "INFO" "Checking network connectivity to $BROKER:$PORT"
    nc -z -w$TIMEOUT "$BROKER" "$PORT"
    if [ $? -eq 0 ]; then
        log "INFO" "Network connection successful"
        return 0
    else
        log "ERROR" "Network connection failed"
        return 1
    fi
}
# TLS connection check
check_tls() {
    if [ "$USE_TLS" = true ]; then
        log "INFO" "Checking TLS connection"
        # Validate TLS parameters
        if [ -z "$CA_CERT_PATH" ]; then
            log "ERROR" "CA Certificate path is required for TLS connection"
            return 1
        fi
        # Attempt TLS connection using openssl
        echo "Q" | openssl s_client -connect "$BROKER:$PORT" -CApath "$CA_CERT_PATH" \
            ${CLIENT_CERT:+-cert "$CLIENT_CERT"} \
            ${CLIENT_KEY:+-key "$CLIENT_KEY"} \
            -verify=2 -brief
	
        if [ $? -eq 0 ]; then
            log "INFO" "TLS connection successful"
            return 0
        else
            log "ERROR" "TLS connection failed"
            return 1
        fi
    fi
    return 0
}
# Main diagnosis function
diagnose() {
    echo -e "${BLUE}=== MQTT Troubleshooting Diagnosis ===${NC}"
    # Run diagnostic checks
    local network_check=0
    local tls_check=0
    check_network
    network_check=$?
    if [ $network_check -eq 0 ]; then
        check_tls
        tls_check=$?
    fi
    # Print final summary
    echo -e "\n${BLUE}=== Diagnostic Summary ===${NC}"
    echo -e "Network Connection:   ${network_check=0 && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"}"
    echo -e "TLS Connection:       ${tls_check=0 && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"}"
    # Provide troubleshooting suggestions
    if [ $network_check -ne 0 ]; then
        echo -e "\n${YELLOW}Troubleshooting Network Issues:${NC}"
        echo "- Verify broker address and port"
        echo "- Check firewall settings"
        echo "- Confirm network connectivity"
    fi
    if [ $tls_check -ne 0 ]; then
        echo -e "\n${YELLOW}Troubleshooting TLS Issues:${NC}"
        echo "- Verify CA certificate path"
        echo "- Check client certificates"
        echo "- Confirm TLS configuration"
    fi
}
# Run diagnosis
diagnose
exit 0
```

#### Description

This script is used for troubleshooting MQTT on the Linux machine.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20MQTT%20Troubleshooting.md"
```
