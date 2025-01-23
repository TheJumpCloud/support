#### Name

Mac - MQTT Troubleshooting Script | v1.1 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
# Default values
BROKER="a1hrq03pdcca60-ats.iot.us-east-1.amazonaws.com"
PORT=443
TIMEOUT=10
VERBOSE=false
# Help function
show_help() {
    echo "MQTT Troubleshooting Script"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -b, --broker         MQTT Broker address (required)"
    echo "  -p, --port           Broker port (default: 1883)"
    echo "  -v, --verbose        Enable verbose output"
    exit 1
}
# Parse command line arguments
PARSED_ARGUMENTS=$(getopt -a mqtt-troubleshooter -o hvb:p: --long help,verbose,broker:,port:, -- "$@")
VALID_ARGUMENTS=$?
[ $VALID_ARGUMENTS -ne 0 ] && show_help
eval set -- "$PARSED_ARGUMENTS"
while :
do
    case "$1" in
        -h | --help)         show_help; shift ;;
        -b | --broker)       BROKER="$2"; shift 2 ;;
        -p | --port)         PORT="$2"; shift 2 ;;
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
# Main diagnosis function
diagnose() {
    echo -e "${BLUE}=== MQTT Troubleshooting Diagnosis ===${NC}"
    # Run diagnostic checks
    local network_check=0
    check_network
    # Print final summary
    echo -e "\n${BLUE}=== Diagnostic Summary ===${NC}"
    echo -e "Network Connection:   ${network_check=0 && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"}"
    # Provide troubleshooting suggestions
    if [ $network_check -ne 0 ]; then
        echo -e "\n${YELLOW}Troubleshooting Network Issues:${NC}"
        echo "- Verify broker address and port"
        echo "- Check firewall settings"
        echo "- Confirm network connectivity"
    fi
}
# Run diagnosis
diagnose
exit 0
```

#### Description

This script helps diagnose common MQTT connectivity and communication issues by performing various network checks.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20MQTT%20Troubleshooting.md"
```
