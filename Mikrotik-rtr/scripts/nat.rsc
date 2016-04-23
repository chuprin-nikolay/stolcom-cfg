# nov/30/2014 16:47:01 by RouterOS 6.22
# software id = 2UD3-AZ4N
#
/ip firewall nat
add action=masquerade chain=srcnat
add action=netmap chain=dstnat comment="DVR 1" dst-port=5920 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.10 to-ports=5920
add action=netmap chain=dstnat comment="DVR 1" dst-port=5921 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.10 to-ports=5921
add action=netmap chain=dstnat comment="DVR 1" dst-port=82 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.10 to-ports=80
add action=netmap chain=dstnat comment="DVR 2" dst-port=5922 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.11 to-ports=5922
add action=netmap chain=dstnat comment="DVR 2" dst-port=5923 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.11 to-ports=5923
add action=netmap chain=dstnat comment="DVR 2" dst-port=81 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.11 to-ports=81
add action=netmap chain=dstnat comment="DVR 3" dst-port=15920 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.12 to-ports=15920
add action=netmap chain=dstnat comment="DVR 3" dst-port=15921 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.12 to-ports=15921
add action=netmap chain=dstnat comment="DVR 3" dst-port=83 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.12 to-ports=80
add action=netmap chain=dstnat comment=RDP dst-port=40611 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.14 to-ports=33895
add action=netmap chain=dstnat comment=VPN dst-port=1723 in-interface=\
    ether6-WAN1 protocol=tcp to-addresses=192.168.1.14 to-ports=1723
