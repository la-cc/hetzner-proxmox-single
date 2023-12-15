#!/bin/bash

# Function to prompt for input with a default value
prompt_input() {
    local prompt=$1
    local default=$2
    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}

# Function to create bridge interface text for additional IP
create_bridge_text() {
    local ip=$1
    local bridge_id=$2
    echo "
auto vmbr${bridge_id}
iface vmbr${bridge_id} inet static
    address ${ip}
    netmask ${NETMASK}
    bridge_ports none
    bridge_stp off
    bridge_fd 0
#LAN${bridge_id}"
}

# Collect inputs
MAINSERVERIP=$(prompt_input "MAIN_SERVER_IP" "192.168.0.1")
GATEWAYADDRESS=$(prompt_input "MAIN_SERVER_GATEWAY_ADDRESS" "192.168.0.254")
NETMASK=$(prompt_input "NETMASK" "255.255.255.0")
BROADCASTIP=$(prompt_input "BROADCASTIP" "192.168.0.255")
ADD_IP_ADDRESSES=$(prompt_input "ADDITIONAL_IP_ADDRESSES (comma-separated)" "")
NETWORK_INTERFACE=$(prompt_input "NETWORK_INTERFACE" "eth0")

# Display inputs for confirmation
echo "You have entered the following configuration:"
echo "MAIN_SERVER_IP: $MAINSERVERIP"
echo "MAIN_SERVER_GATEWAY_ADDRESS: $GATEWAYADDRESS"
echo "NETMASK: $NETMASK"
echo "BROADCASTIP: $BROADCASTIP"
echo "ADDITIONAL_IP_ADDRESSES: $ADD_IP_ADDRESSES"
echo "NETWORK_INTERFACE: $NETWORK_INTERFACE"
read -p "Is this correct? [yes/no]: " confirmation

if [[ $confirmation != [Yy]* ]]; then
    echo "Exiting without changes."
    exit
fi

# Split ADD_IP_ADDRESSES into an array
IFS=',' read -ra ADDR <<<"$ADD_IP_ADDRESSES"

# Initialize the interfaces file content
interfaces_content="
### Hetzner Online GmbH installimage

source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
iface lo inet6 loopback

iface ${NETWORK_INTERFACE} inet manual
  up ip route add -net up ip route add -net ${GATEWAYADDRESS} netmask ${NETMASK} gw  ${GATEWAYADDRESS} vmbr0
  up sysctl -w net.ipv4.ip_forward=1
  up sysctl -w net.ipv4.conf.${NETWORK_INTERFACE}.send_redirects=0
  up sysctl -w net.ipv6.conf.all.forwarding=1
  up ip route add 192.168.0.0/16 via ${ADDR[0]} dev vmbr0
  up ip route add 172.16.0.0/12 via ${ADDR[0]} dev vmbr0
  up ip route add 10.0.0.0/8 via ${ADDR[0]} dev vmbr0

iface ${NETWORK_INTERFACE} inet6 static
  address 2a01:4f8:110:5143::2
  netmask 64
  gateway fe80::1

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
#WAN
"

# Append bridge interfaces for each additional IP
for i in "${!ADDR[@]}"; do
    interfaces_content+=$(create_bridge_text "${ADDR[i]}" "$((i + 1))")
done

echo "$interfaces_content" >interfaces

# Confirm before applying changes
read -p "Apply this network configuration? [yes/no]: " apply_conf

if [[ $apply_conf == [Yy]* ]]; then
    mv /etc/network/interfaces /etc/network/interfaces.old
    mv interfaces /etc/network/interfaces
    echo "The network can be restarted with the following command: /etc/init.d/networking restart"
else
    echo "Exiting without applying changes."
fi
