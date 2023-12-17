#!/bin/bash

read -p "MAIN_SERVER_IP: " MAINSERVERIP
read -p "MAIN_SERVER_GATEWAY_ADRESS: " GATEWAYADRESS
read -p "NETMASK: " NETMASK
read -p "BROADCASTIP: " BROADCASTIP
read -p "ADDITIONAL_IP_ADRESS: " ADD_IP_ADRESS
read -p "NETWORK_INTERFACE: " NETWORK_INTERFACE

echo "
### Hetzner Online GmbH installimage

source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
iface lo inet6 loopback


iface ${NETWORK_INTERFACE} inet manual

  up ip route add -net up ip route add -net ${GATEWAYADRESS} netmask ${NETMASK} gw  ${GATEWAYADRESS} vmbr0
  up sysctl -w net.ipv4.ip_forward=1
  up sysctl -w net.ipv4.conf.${NETWORK_INTERFACE}.send_redirects=0
  up sysctl -w net.ipv6.conf.all.forwarding=1
  up ip route add 192.168.0.0/16 via ${ADD_IP_ADRESS} dev vmbr0
  up ip route add 172.16.0.0/12 via ${ADD_IP_ADRESS} dev vmbr0
  up ip route add 10.0.0.0/8 via ${ADD_IP_ADRESS} dev vmbr0


iface ${NETWORK_INTERFACE} inet6 static
  address 2a01:4f8:110:5143::2
  netmask 64
  gateway fe80::1


auto vmbr0
iface vmbr0 inet static
        address  ${MAINSERVERIP}
        netmask  32
        gateway  ${GATEWAYADRESS}
        broadcast  ${BROADCASTIP}
        bridge-ports ${NETWORK_INTERFACE}
        bridge-stp off
        bridge-fd 0
        pointopoint ${GATEWAYADRESS}
#WAN


# Virtual switch for DMZ
# (connect your firewall/router KVM instance and private DMZ hosts here)
auto vmbr1
iface vmbr1 inet manual
        bridge_ports none
        bridge_stp off
        bridge_fd 0
#LAN0

" >interfaces

cat interfaces

while true; do
    read -p "Config correct? [yes][no]: " yn
    case $yn in
    [Yy]*)
        echo ""
        break
        ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
done

mv /etc/network/interfaces /etc/network/interfaces.old
mv interfaces /etc/network/interfaces

echo "The network can be restarted with the following command:      /etc/init.d/networking restart    "
