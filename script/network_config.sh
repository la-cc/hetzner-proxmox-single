#!/bin/bash

# Function to prompt for input with a default value
prompt_input() {
    local prompt=$1
    local default=$2
    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}

# Function to create bridge interface text for additional IP and internal bridges
create_bridge_text() {
    local ip=$1
    local bridge_id=$2
    local mac_address=$3
    local external_bridge_id=$bridge_id
    local internal_bridge_id=$((bridge_id * 100))

    # WAN bridge configuration with MAC address and public IP
    local bridge_config="
auto vmbr${external_bridge_id}
iface vmbr${external_bridge_id} inet static
    address ${ip}
    netmask ${NETMASK}
    bridge_ports none
    bridge_stp off
    bridge_fd 0
    hwaddress ether ${mac_address}
#WAN ${external_bridge_id}
"

    # LAN bridge configuration without an IP, as it's for internal network only
    bridge_config+="
auto vmbr${internal_bridge_id}
iface vmbr${internal_bridge_id} inet manual
    bridge_ports none
    bridge_stp off
    bridge_fd 0
#LAN ${internal_bridge_id}
"

    echo "$bridge_config"
}

# Collect inputs
MAINSERVERIP=$(prompt_input "MAIN_SERVER_IP" "192.168.0.1")
GATEWAYADDRESS=$(prompt_input "MAIN_SERVER_GATEWAY_ADDRESS" "192.168.0.254")
NETMASK=$(prompt_input "NETMASK" "255.255.255.0")
BROADCASTIP=$(prompt_input "BROADCASTIP" "192.168.0.255")
ADD_IP_ADDRESSES=$(prompt_input "ADDITIONAL_IP_ADDRESSES (comma-separated)" "")
MAC_ADDRESSES=$(prompt_input "MAC_ADDRESSES for additional IPs (comma-separated)" "")
NETWORK_INTERFACE=$(prompt_input "NETWORK_INTERFACE" "eth0")

# Display inputs for confirmation
echo "---------------------------------------------------------------------"
echo "You have entered the following configuration:"
echo "MAIN_SERVER_IP: $MAINSERVERIP"
echo "MAIN_SERVER_GATEWAY_ADDRESS: $GATEWAYADDRESS"
echo "NETMASK: $NETMASK"
echo "BROADCASTIP: $BROADCASTIP"
echo "ADDITIONAL_IP_ADDRESSES: $ADD_IP_ADDRESSES"
echo "MAC_ADDRESSES: $MAC_ADDRESSES"
echo "NETWORK_INTERFACE: $NETWORK_INTERFACE"

echo "---------------------------------------------------------------------"
read -p "Is this correct? [yes/no]: " confirmation

if [[ $confirmation != [Yy]* ]]; then
    echo "Exiting without changes."
    exit
fi

# Split ADD_IP_ADDRESSES and MAC_ADDRESSES into arrays
IFS=',' read -ra ADDR <<<"$ADD_IP_ADDRESSES"
IFS=',' read -ra MACS <<<"$MAC_ADDRESSES"

# Initialize the interfaces file content
interfaces_content="
### Hetzner Online GmbH installimage

source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
iface lo inet6 loopback

auto vmbr0
iface vmbr0 inet static
    address  ${MAINSERVERIP}
    netmask  32
    gateway  ${GATEWAYADDRESS}
    broadcast  ${BROADCASTIP}
    bridge-ports ${NETWORK_INTERFACE}
    bridge-stp off
    bridge-fd 0
    pointopoint ${GATEWAYADDRESS}
#Main IP configuration
"

# Append bridge interfaces for each additional IP and MAC address and create internal bridges
for i in "${!ADDR[@]}"; do
    # Increment bridge_id for each additional IP
    bridge_id=$((i + 1))
    interfaces_content+=$(create_bridge_text "${ADDR[i]}" "$bridge_id" "${MACS[i]}")
done

# Save the new configuration to a temporary file
echo "$interfaces_content" > /tmp/new_interfaces

# Display the current network configuration
echo "---------------------------------------------------------------------"
echo "Current network configuration (/etc/network/interfaces):"
cat /etc/network/interfaces
echo ""

# Display the new network configuration
echo "---------------------------------------------------------------------"
echo "New network configuration:"
cat /tmp/new_interfaces
echo ""

# Show the differences
echo "---------------------------------------------------------------------"
echo "Configuration differences:"
diff /etc/network/interfaces /tmp/new_interfaces
echo ""

# Confirm before applying changes
echo "---------------------------------------------------------------------"
read -p "Apply this network configuration? [yes/no]: " apply_conf

if [[ $apply_conf == [Yy]* ]]; then
    timestamp=$(date +%Y%m%d-%H%M%S)
    mv /etc/network/interfaces /etc/network/interfaces.bak-$timestamp
    mv /tmp/new_interfaces /etc/network/interfaces
    echo "The network can be restarted with the following command: '/etc/init.d/networking' restart or 'systemctl restart networking'"
else
    echo "Exiting without applying changes."
    rm /tmp/new_interfaces
fi
