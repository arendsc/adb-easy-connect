#!/bin/sh
#
display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "This script is used to interact with adb (Android Debug Bridge). It provides options to disconnect, scan network, scan ports and connect to a device."
    echo ""
    echo "Options:"
    echo "  -d    Disconnect from adb"
    echo "  -s    Scan the ports of the device (requires nmap)"
    echo "  -i    Set the IP address of the device"
    echo "  -h    Display this help message"
    echo ""
    echo "If no option is provided, the script will try to connect to the device on the standard port (5555). If it fails, it will prompt the user to enter a port, and then try to connect on that port. If it still fails, it will exit with an error message."
    echo ""
    echo "Usage Examples:"
    echo "  Disconnect from adb: $0 -d"
    echo "  Scan the ports of the device: $0 -s"
    echo "  Set the IP address of the device: $0 -i 192.168.1.2"
    echo "  Run the script without any flags (tries to connect to the device): $0"
}

# Parse the command-line arguments
SCAN_PORTS=false
for arg in "$@"
do
    case $arg in
        --help)
            display_help
            exit 0
            ;;
    esac
done

while getopts "dshi:h" opt; do
    case $opt in
        d)
            adb disconnect
            exit 0
            ;;
        s)
            SCAN_PORTS=true
            if ! command -v nmap >/dev/null; then
                echo "nmap is not installed. Please install it and try again."
                exit 1
            fi
            ;;
        i)
            IP_ADDRESS=$OPTARG
            ;;
        h)
            display_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE="$SCRIPT_DIR/adb_config.txt"
STANDARD_PORT=5555

# Function to scan the network and find the IP address
scan_network() {
    echo "Scanning the network to find the IP address..."
    IP_ADDRESS=$(sudo arp-scan -l 2>/dev/null | awk -v mac="$MAC_ADDRESS" '$2 ~ mac {print $1}')
    if [ -z "$IP_ADDRESS" ]; then
        echo "No IP address found. Please check your network settings and try again."
        exit 1
    fi
    echo "Found IP address: $IP_ADDRESS"
    if grep -q "IP_ADDRESS" $CONFIG_FILE; then
        sed -i "/IP_ADDRESS/c\IP_ADDRESS=$IP_ADDRESS" $CONFIG_FILE
    else
        echo "IP_ADDRESS=$IP_ADDRESS" >> $CONFIG_FILE
    fi
}

scan_ports() {
    echo "Scanning the ports..."
    PORTS=$(nmap -sT $IP_ADDRESS -p30000-49999 | awk -F/ '/tcp open/ {print $1}')
    if [ -z "$PORTS" ]; then
        echo "No open ports found. Please check your network settings."
        exit 1
    fi
    for PORT in $PORTS; do
        ADB_OUTPUT=$(adb connect $IP_ADDRESS:$PORT 2>&1)
        if echo "$ADB_OUTPUT" | grep -q "connected"; then
            echo "Connected to $IP_ADDRESS:$PORT"
            return
        fi
    done
    echo "Failed to connect. Please check your device and network settings."
    exit 1
}

# Function to prompt the user to enter the port
prompt_port() {
    echo "Please enter the port:"
    read PORT
}

# Read the configuration file
if [ -z "$IP_ADDRESS" ]; then
    if [ -f $CONFIG_FILE ]; then
        . $CONFIG_FILE
    else
        echo "Config file not found. Please make sure it exists and contains your MAC address."
        exit 1
    fi
fi

if ! command -v adb >/dev/null; then
    echo "adb is not installed. Please install it and try again."
    exit 1
fi

# If IP address is not set, scan the network
if [ -z "$IP_ADDRESS" ]; then
    if ! command -v arp-scan >/dev/null; then
        echo "Config file does not contain an IP address, and arp-scan, which is needed to scan the network, is not installed."
        exit 1
    else
        scan_network
    fi
fi

# Try to connect
echo "Trying to connect to $IP_ADDRESS:$STANDARD_PORT..."
ADB_OUTPUT=$(adb connect $IP_ADDRESS:$STANDARD_PORT 2>&1)
if echo "$ADB_OUTPUT" | grep -q "failed"; then
    echo "Failed to connect to default port."
    if $SCAN_PORTS; then
        scan_ports
    else
        prompt_port
        echo "Trying to connect to $IP_ADDRESS:$PORT..."
        ADB_OUTPUT=$(adb connect $IP_ADDRESS:$PORT 2>&1)
        if echo "$ADB_OUTPUT" | grep -q "failed"; then
            echo "Failed to connect. Please check your device and network settings."
            exit 1
        fi
    fi
    # Change the port to the standard port
    adb tcpip $STANDARD_PORT
    adb disconnect >/dev/null 2>&1
    sleep 1 # wait to disconnect
    adb connect $IP_ADDRESS:$STANDARD_PORT
else
    echo "$ADB_OUTPUT"
fi
