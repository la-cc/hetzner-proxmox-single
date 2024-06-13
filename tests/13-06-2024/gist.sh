
root@proxmox-single ~ # ifconfig
enp0s31f6: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 116.202.228.230  netmask 255.255.255.192  broadcast 0.0.0.0
        inet6 2a01:4f8:241:485b::2  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::921b:eff:fe8d:99ef  prefixlen 64  scopeid 0x20<link>
        ether 90:1b:0e:8d:99:ef  txqueuelen 1000  (Ethernet)
        RX packets 1177  bytes 218733 (213.6 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1790  bytes 1872307 (1.7 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xf7000000-f7020000

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 102  bytes 21805 (21.2 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 102  bytes 21805 (21.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


root@proxmox-single ~ # ./network_config.sh
MAIN_SERVER_IP: 116.202.228.216
MAIN_SERVER_GATEWAY_ADRESS: 116.202.228.193
NETMASK: 255.255.255.192
BROADCASTIP: 116.202.228.255
ADDITIONAL_IP_ADRESS: ^C
root@proxmox-single ~ # ./network_config.sh
MAIN_SERVER_IP: 116.202.228.230
MAIN_SERVER_GATEWAY_ADRESS: 116.202.228.193
NETMASK: 255.255.255.192
BROADCASTIP: 116.202.228.255
ADDITIONAL_IP_ADRESS: 116.202.228.216
NETWORK_INTERFACE: enp0s31f6

##### Output ####

auto lo
iface lo inet loopback
iface lo inet6 loopback


iface enp0s31f6 inet manual

  up ip route add -net up ip route add -net 116.202.228.193 netmask 255.255.255.192 gw  116.202.228.193 vmbr0
  up sysctl -w net.ipv4.ip_forward=1
  up sysctl -w net.ipv4.conf.enp0s31f6.send_redirects=0
  up sysctl -w net.ipv6.conf.all.forwarding=1
  up ip route add 192.168.0.0/16 via 116.202.228.216 dev vmbr0
  up ip route add 172.16.0.0/12 via 116.202.228.216 dev vmbr0
  up ip route add 10.0.0.0/8 via 116.202.228.216 dev vmbr0


iface enp0s31f6 inet6 static
  address 2a01:4f8:110:5143::2
  netmask 64
  gateway fe80::1


auto vmbr0
iface vmbr0 inet static
        address  116.202.228.230
        netmask  255.255.255.192
        gateway  116.202.228.193
        broadcast  116.202.228.255
        bridge-ports enp0s31f6
        bridge-stp off
        bridge-fd 0
        pointopoint 116.202.228.193
#WAN


# Virtual switch for DMZ
# (connect your firewall/router KVM instance and private DMZ hosts here)
auto vmbr1
iface vmbr1 inet manual
        bridge_ports none
        bridge_stp off
        bridge_fd 0
#LAN0


Config correct? [yes][no]: yes

The network can be restarted with the following command:      /etc/init.d/networking restart
root@proxmox-single ~ # /etc/init.d/networking restart
-bash: /etc/init.d/networking: Permission denied
root@proxmox-single ~ # sudo /etc/init.d/networking restart
sudo: /etc/init.d/networking: command not found
root@proxmox-single ~ # ifconfig
enp0s31f6: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 116.202.228.230  netmask 255.255.255.192  broadcast 0.0.0.0
        inet6 2a01:4f8:241:485b::2  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::921b:eff:fe8d:99ef  prefixlen 64  scopeid 0x20<link>
        ether 90:1b:0e:8d:99:ef  txqueuelen 1000  (Ethernet)
        RX packets 2963  bytes 678603 (662.6 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3404  bytes 2360971 (2.2 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xf7000000-f7020000

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 102  bytes 21805 (21.2 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 102  bytes 21805 (21.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@proxmox-single ~ # reboot
root@proxmox-single ~ # Connection to 116.202.228.230 closed by remote host.
Connection to 116.202.228.230 closed.                                                                                                                                       13.06.24  11:42:40  aks-excelsior-development/default ⎈
Linux proxmox-single 6.8.4-3-pve #1 SMP PREEMPT_DYNAMIC PMX 6.8.4-3 (2024-05-02T11:55Z) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Thu Jun 13 11:34:38 2024 from 93.234.183.85
root@proxmox-single ~ # ifconfig
enp0s31f6: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 90:1b:0e:8d:99:ef  txqueuelen 1000  (Ethernet)
        RX packets 394  bytes 84943 (82.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 270  bytes 91513 (89.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xf7000000-f7020000

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vmbr0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 116.202.228.230  netmask 255.255.255.255  broadcast 116.202.228.255
        inet6 fe80::921b:eff:fe8d:99ef  prefixlen 64  scopeid 0x20<link>
        ether 90:1b:0e:8d:99:ef  txqueuelen 1000  (Ethernet)
        RX packets 281  bytes 72227 (70.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 265  bytes 89977 (87.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vmbr1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::a432:9cff:fe67:ad3c  prefixlen 64  scopeid 0x20<link>
        ether a6:32:9c:67:ad:3c  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4  bytes 480 (480.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0



############ network_config_updated.sh ############


root@proxmox-single ~ # ./network_config_updated.sh
MAIN_SERVER_IP [192.168.0.1]: 116.202.228.230
MAIN_SERVER_GATEWAY_ADDRESS [192.168.0.254]: 116.202.228.193
NETMASK [255.255.255.0]: 255.255.255.192
BROADCASTIP [192.168.0.255]: 116.202.228.255
ADDITIONAL_IP_ADDRESSES (comma-separated) []: 116.202.228.216
MAC_ADDRESSES for additional IPs (comma-separated) []: 00:50:56:00:4B:CF
NETWORK_INTERFACE [eth0]: enp0s31f6
---------------------------------------------------------------------
You have entered the following configuration:
MAIN_SERVER_IP: 116.202.228.230
MAIN_SERVER_GATEWAY_ADDRESS: 116.202.228.193
NETMASK: 255.255.255.192
BROADCASTIP: 116.202.228.255
ADDITIONAL_IP_ADDRESSES: 116.202.228.216
MAC_ADDRESSES: 00:50:56:00:4B:CF
NETWORK_INTERFACE: enp0s31f6
---------------------------------------------------------------------
Is this correct? [yes/no]: y
---------------------------------------------------------------------
Current network configuration (/etc/network/interfaces):

### Hetzner Online GmbH installimage

source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
iface lo inet6 loopback


iface enp0s31f6 inet manual

  up ip route add -net up ip route add -net 116.202.228.193 netmask 255.255.255.192 gw  116.202.228.193 vmbr0
  up sysctl -w net.ipv4.ip_forward=1
  up sysctl -w net.ipv4.conf.enp0s31f6.send_redirects=0
  up sysctl -w net.ipv6.conf.all.forwarding=1
  up ip route add 192.168.0.0/16 via 116.202.228.216 dev vmbr0
  up ip route add 172.16.0.0/12 via 116.202.228.216 dev vmbr0
  up ip route add 10.0.0.0/8 via 116.202.228.216 dev vmbr0


iface enp0s31f6 inet6 static
  address 2a01:4f8:110:5143::2
  netmask 64
  gateway fe80::1


auto vmbr0
iface vmbr0 inet static
        address  116.202.228.230
        netmask  255.255.255.192
        gateway  116.202.228.193
        broadcast  116.202.228.255
        bridge-ports enp0s31f6
        bridge-stp off
        bridge-fd 0
        pointopoint 116.202.228.193
#WAN


# Virtual switch for DMZ
# (connect your firewall/router KVM instance and private DMZ hosts here)
auto vmbr1
iface vmbr1 inet manual
        bridge_ports none
        bridge_stp off
        bridge_fd 0
#LAN0



---------------------------------------------------------------------
New network configuration:

### Hetzner Online GmbH installimage

source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
iface lo inet6 loopback

# Main network interface configuration
iface enp0s31f6 inet manual
    up ip route add -net 116.202.228.193 netmask 255.255.255.192 gw 116.202.228.193 vmbr0
    up sysctl -w net.ipv4.ip_forward=1
    up sysctl -w net.ipv4.conf.enp0s31f6.send_redirects=0
    up sysctl -w net.ipv6.conf.all.forwarding=1
    up ip route add 116.202.228.216 dev enp0s31f6

    up ip route add 192.168.0.0/16 via 116.202.228.230 dev vmbr0
    up ip route add 172.16.0.0/12 via 116.202.228.230 dev vmbr0
    up ip route add 10.0.0.0/8 via 116.202.228.230 dev vmbr0

auto vmbr0
iface vmbr0 inet static
    address  116.202.228.230
    netmask  255.255.255.192
    gateway  116.202.228.193
    broadcast  116.202.228.255
    bridge-ports enp0s31f6
    bridge-stp off
    bridge-fd 0
    pointopoint 116.202.228.193
#Main IP configuration

auto vmbr1
iface vmbr1 inet static
    address 116.202.228.216
    netmask 255.255.255.192
    bridge_ports none
    bridge_stp off
    bridge_fd 0
    hwaddress ether 00:50:56:00:4B:CF
#WAN 1

auto vmbr100
iface vmbr100 inet manual
    bridge_ports none
    bridge_stp off
    bridge_fd 0
#LAN 100
