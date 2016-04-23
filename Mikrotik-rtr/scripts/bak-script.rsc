# apr/23/2016 15:41:50 by RouterOS 6.22
# software id = 2UD3-AZ4N
#
/interface bridge
add name=bridge1-Local
add name=bridge2-DMZ
/interface ethernet
set [ find default-name=ether1 ] comment=DMZ name=LAN1-Master
set [ find default-name=ether2 ] master-port=LAN1-Master name=LAN2-Slave
set [ find default-name=ether3 ] master-port=LAN1-Master name=LAN3-Slave
set [ find default-name=ether4 ] master-port=LAN1-Master name=LAN4-Slave
set [ find default-name=ether5 ] name=LAN5-Local
set [ find default-name=ether6 ] comment="Formula 7" name=ether6-WAN1
set [ find default-name=ether7 ] comment="SXT - Provider 2" name=ether7-WAN2
/ip neighbor discovery
set LAN1-Master comment=DMZ
set ether6-WAN1 comment="Formula 7"
set ether7-WAN2 comment="SXT - Provider 2"
/interface wireless security-profiles
add authentication-types=wpa2-psk eap-methods="" management-protection=\
    allowed mode=dynamic-keys name=Office-WiFi supplicant-identity="" \
    wpa2-pre-shared-key=1q2w3e4r
add authentication-types=wpa2-psk eap-methods="" management-protection=\
    allowed mode=dynamic-keys name=Guest-WiFi supplicant-identity="" \
    wpa2-pre-shared-key=9199643127
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n disabled=no l2mtu=1600 mode=\
    ap-bridge name=wlan1-Local security-profile=Office-WiFi ssid=STOL-COM
add disabled=no l2mtu=1600 mac-address=4E:5E:0C:BC:E8:EB master-interface=\
    wlan1-Local name=wlan2-Guest security-profile=Guest-WiFi ssid=\
    "STOL-COM Guest" wds-cost-range=0 wds-default-cost=0
/ip pool
add name=dhcp_pool1 ranges=192.168.1.40-192.168.1.254
/ip dhcp-server
add address-pool=dhcp_pool1 disabled=no interface=bridge2-DMZ lease-time=3d \
    name=dhcp1-DMZ
/port
set 0 name=serial0
/system logging action
set 2 remember=yes
set 3 src-address=0.0.0.0
/interface bridge port
add bridge=bridge1-Local interface=LAN5-Local
add bridge=bridge1-Local interface=wlan1-Local
add bridge=bridge2-DMZ interface=LAN1-Master
add bridge=bridge2-DMZ interface=wlan2-Guest
add bridge=bridge2-DMZ interface=ether8
/ip address
add address=192.168.1.1/24 interface=bridge2-DMZ network=192.168.1.0
add address=87.251.141.242/25 interface=ether7-WAN2 network=87.251.141.128
add address=109.197.29.19/28 interface=ether6-WAN1 network=109.197.29.16
/ip dhcp-client
add add-default-route=no dhcp-options=hostname,clientid disabled=no \
    interface=LAN5-Local use-peer-dns=no use-peer-ntp=no
/ip dhcp-server network
add address=192.168.1.0/24 dns-server=192.168.1.1,8.8.8.8 gateway=192.168.1.1
/ip dns
set allow-remote-requests=yes servers=109.197.24.4,81.91.176.2,8.8.8.8
/ip firewall address-list
add address=81.91.176.2 comment="DNS ISP2" list=to-ISP2
add address=81.91.177.130 comment="DNS ISP2" list=to-ISP2
add address=172.19.0.4 comment="DNS ISP1" list=to-ISP1
add address=192.168.1.14 list=GATE-Local
add address=194.190.11.143 comment="\E4\EE\EC" disabled=yes list=to-ISP2
add address=192.168.1.0/24 comment=DNS_access list=DNS_access
/ip firewall filter
add chain=input protocol=icmp
add chain=forward protocol=icmp
add chain=input connection-state=established
add chain=forward connection-state=established
add chain=input connection-state=related
add chain=forward connection-state=related
add action=drop chain=forward disabled=yes in-interface=ether6-WAN1 log=yes
add action=drop chain=input connection-state=invalid
add action=drop chain=forward connection-state=invalid
add chain=input protocol=udp
add chain=forward protocol=udp
add chain=input src-address=192.168.1.0/24
add chain=forward src-address=192.168.1.0/24
add chain=input src-address=10.10.1.0/24
add chain=forward src-address=10.10.1.0/24
add chain=input port=40611 protocol=tcp
add chain=forward port=40611 protocol=tcp
add chain=forward log=yes port=33895 protocol=tcp
add chain=input port=1723 protocol=tcp
add chain=forward port=1723 protocol=tcp
add chain=input comment="DNS resolver service filtering LAN" \
    dst-address-list=DNS_access dst-port=53 log=yes protocol=udp
add action=drop chain=input in-interface=ether6-WAN1 log=yes
/ip firewall mangle
add action=mark-connection chain=input in-interface=ether6-WAN1 \
    new-connection-mark=ISP1-con
add action=mark-connection chain=forward in-interface=ether6-WAN1 \
    new-connection-mark=ISP1-con
add action=mark-connection chain=input in-interface=ether7-WAN2 \
    new-connection-mark=ISP2-con
add action=mark-connection chain=forward in-interface=ether7-WAN2 \
    new-connection-mark=ISP2-con
add action=mark-routing chain=prerouting connection-mark=ISP1-con \
    new-routing-mark=ISP1-rt src-address=192.168.1.0/24
add action=mark-routing chain=prerouting connection-mark=ISP2-con \
    new-routing-mark=ISP2-rt src-address=192.168.1.0/24
add action=mark-routing chain=prerouting connection-mark=ISP1-con \
    new-routing-mark=ISP1-rt src-address=10.10.1.0/24
add action=mark-routing chain=prerouting connection-mark=ISP2-con \
    new-routing-mark=ISP2-rt src-address=10.10.1.0/24
add action=mark-routing chain=prerouting connection-state=new \
    dst-address-list=to-ISP1 new-routing-mark=ISP1-rt
add action=mark-routing chain=prerouting connection-state=new \
    dst-address-list=to-ISP2 new-routing-mark=ISP2-rt
/ip firewall nat
add action=masquerade chain=srcnat
add action=netmap chain=dstnat comment="DVR 1" disabled=yes dst-address=\
    !194.190.11.143 dst-port=5920 log=yes log-prefix=a protocol=tcp \
    to-addresses=192.168.1.10 to-ports=5920
add action=netmap chain=dstnat comment="DVR 1" disabled=yes dst-address=\
    !194.190.11.143 dst-port=5921 log=yes log-prefix=a protocol=tcp \
    to-addresses=192.168.1.10 to-ports=5921
add action=netmap chain=dstnat comment="DVR 1" disabled=yes dst-port=82 \
    protocol=tcp to-addresses=192.168.1.10 to-ports=80
add action=dst-nat chain=dstnat comment="DVR 2-WAN1" dst-address=\
    109.197.29.19 dst-port=37778 protocol=tcp to-addresses=192.168.1.127 \
    to-ports=0-65535
add action=dst-nat chain=dstnat comment="DVR 2-WAN1" disabled=yes \
    dst-address=109.197.29.19 dst-port=37779 protocol=udp to-addresses=\
    192.168.1.127 to-ports=37779
add action=dst-nat chain=dstnat comment="DVR 2-WAN1" disabled=yes \
    dst-address=109.197.29.19 dst-port=86 protocol=tcp to-addresses=\
    192.168.1.127 to-ports=0-65535
add action=dst-nat chain=dstnat comment="DVR 2-WAN2" dst-address=\
    87.251.141.242 dst-port=37778 protocol=tcp to-addresses=192.168.1.127 \
    to-ports=0-65535
add action=netmap chain=dstnat comment="DVR 2-WAN2" disabled=yes dst-address=\
    87.251.141.242 dst-port=5923 protocol=tcp to-addresses=192.168.1.115 \
    to-ports=5923
add action=netmap chain=dstnat comment="DVR 2-WAN2" disabled=yes dst-address=\
    87.251.141.242 dst-port=81 protocol=tcp to-addresses=192.168.1.115 \
    to-ports=81
add action=netmap chain=dstnat comment="DVR 3" disabled=yes dst-port=15920 \
    protocol=tcp to-addresses=192.168.1.12 to-ports=15920
add action=netmap chain=dstnat comment="DVR 3" disabled=yes dst-port=15921 \
    protocol=tcp to-addresses=192.168.1.12 to-ports=15921
add action=netmap chain=dstnat comment="DVR 3" disabled=yes dst-port=83 \
    protocol=tcp to-addresses=192.168.1.12 to-ports=80
add action=netmap chain=dstnat comment="DVR 4" disabled=yes dst-port=15923 \
    protocol=tcp to-addresses=192.168.1.87 to-ports=15923
add action=netmap chain=dstnat comment="DVR 4" disabled=yes dst-port=15922 \
    protocol=tcp to-addresses=192.168.1.87 to-ports=15922
add action=netmap chain=dstnat comment="DVR 4" disabled=yes dst-port=87 \
    protocol=tcp to-addresses=192.168.1.87 to-ports=87
add action=netmap chain=dstnat comment="DVR 5-WAN1" dst-address=109.197.29.19 \
    dst-port=8000 protocol=tcp to-addresses=192.168.1.108 to-ports=8000
add action=netmap chain=dstnat comment="DVR 5-WAN1" dst-address=109.197.29.19 \
    dst-port=1200 protocol=tcp to-addresses=192.168.1.108 to-ports=1200
add action=netmap chain=dstnat comment="DVR 5-WAN1" dst-address=109.197.29.19 \
    dst-port=850 protocol=tcp to-addresses=192.168.1.108 to-ports=850
add action=netmap chain=dstnat comment="DVR 5-WAN2" dst-address=\
    87.251.141.242 dst-port=8000 protocol=tcp to-addresses=192.168.1.108 \
    to-ports=8000
add action=netmap chain=dstnat comment="DVR 5-WAN2" dst-address=\
    87.251.141.242 dst-port=850 protocol=tcp to-addresses=192.168.1.108 \
    to-ports=850
add action=netmap chain=dstnat comment="DVR 5-WAN2" dst-address=\
    87.251.141.242 dst-port=1200 protocol=tcp to-addresses=192.168.1.108 \
    to-ports=1200
add action=dst-nat chain=dstnat comment=RDP-WAN1 dst-port=40611 protocol=tcp \
    to-addresses=192.168.1.14 to-ports=33896
add action=dst-nat chain=dstnat comment=RDP2-WAN1 dst-port=40612 protocol=tcp \
    to-addresses=192.168.1.14 to-ports=33896
add action=dst-nat chain=dstnat comment=RDP-WAN2 disabled=yes dst-address=\
    87.251.141.242 dst-port=40611 protocol=tcp to-addresses=191.168.1.14 \
    to-ports=33895
add action=netmap chain=dstnat comment=VPN-WAN1 dst-port=1723 protocol=tcp \
    to-addresses=192.168.1.14 to-ports=1723
add action=netmap chain=dstnat comment=VPN-WAN2 disabled=yes dst-address=\
    87.251.141.128 dst-port=1723 protocol=tcp to-addresses=192.168.1.14 \
    to-ports=1723
add action=netmap chain=dstnat comment="DVR 1 " disabled=yes dst-port=5921 \
    in-interface=ether7-WAN2 protocol=tcp to-addresses=192.168.1.10 to-ports=\
    5921
add action=netmap chain=dstnat comment="DVR 1 " disabled=yes dst-port=82 \
    in-interface=ether7-WAN2 protocol=tcp to-addresses=192.168.1.10 to-ports=\
    80
add action=netmap chain=dstnat comment="DVR 3 " disabled=yes dst-port=15920 \
    in-interface=ether7-WAN2 protocol=tcp to-addresses=192.168.1.12 to-ports=\
    15920
add action=netmap chain=dstnat comment="DVR 3 " disabled=yes dst-port=15921 \
    in-interface=ether7-WAN2 protocol=tcp to-addresses=192.168.1.12 to-ports=\
    15921
add action=netmap chain=dstnat comment="DVR 3 " disabled=yes dst-port=83 \
    in-interface=ether7-WAN2 protocol=tcp to-addresses=192.168.1.12 to-ports=\
    80
add action=netmap chain=dstnat comment=RDP disabled=yes dst-port=40611 \
    in-interface=ether7-WAN2 log=yes protocol=tcp to-addresses=192.168.1.14 \
    to-ports=33895
add action=netmap chain=dstnat comment=VPN disabled=yes dst-port=1723 \
    in-interface=ether7-WAN2 protocol=tcp to-addresses=192.168.1.14 to-ports=\
    1723
/ip ipsec policy
set 0 dst-address=0.0.0.0/0 src-address=0.0.0.0/0
/ip route
add check-gateway=ping distance=4 gateway=109.197.29.17 routing-mark=ISP1-rt
add check-gateway=ping distance=4 gateway=87.251.141.129 routing-mark=ISP2-rt
add check-gateway=ping distance=2 gateway=109.197.29.17
add check-gateway=ping distance=3 gateway=87.251.141.129
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/ip upnp
set allow-disable-external-interface=no
/lcd
set time-interval=hour
/snmp
set trap-community=public
/system clock
set time-zone-name=Europe/Moscow
/system ntp client
set enabled=yes primary-ntp=88.147.254.228 secondary-ntp=194.190.168.1
