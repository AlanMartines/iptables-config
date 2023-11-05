#!/bin/sh
#
IP6TABLES="/sbin/ip6tables"
#
# Remover módulos desnecessários
# (Nota: muitos destes módulos são para iptables (IPv4) e não são relevantes para ip6tables (IPv6))
/sbin/modprobe ip6_tables
#/sbin/modprobe nf_conntrack_ipv6
/sbin/modprobe ip6t_REJECT
/sbin/modprobe ip6t_LOG
/sbin/modprobe ip6t_rt
#
# Enable Forwarding
echo "1" > /proc/sys/net/ipv6/conf/all/forwarding
#
# Set default policies to DROP
$IP6TABLES -P INPUT DROP
$IP6TABLES -P FORWARD DROP
$IP6TABLES -P OUTPUT DROP
#
# Flush All Iptables Chains/Firewall rules
$IP6TABLES -F
$IP6TABLES -X
$IP6TABLES -Z
#
# PROTECT RULES
#
# Allow connection RELATED,ESTABLISHED on eth0
$IP6TABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#
# Log all packets
$IP6TABLES -A INPUT -m conntrack --ctstate NEW -j LOG --log-prefix='[ip6tables_input] '
$IP6TABLES -A OUTPUT -m conntrack --ctstate NEW -j LOG --log-prefix='[ip6tables_output] '
#
# Allow unlimited traffic on loopback and docker
$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A INPUT -i docker0 -j ACCEPT
#
# Allow specific services
$IP6TABLES -A INPUT -p tcp -m multiport --dports ssh,smtp,http,https -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A INPUT -p tcp -m multiport --dports 22,2280 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A INPUT -p tcp -m multiport --dports 25,587,465,2525 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
#
# Allow Ping from Inside to Outside
$IP6TABLES -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp --icmpv6-type echo-reply -j ACCEPT
#
# Zabbix agent
# (Nota: Zabbix agent normalmente usa TCP, então removi a opção UDP)
$IP6TABLES -A INPUT -p tcp --sport 10050 -j ACCEPT
$IP6TABLES -A INPUT -p tcp --sport 10051 -j ACCEPT
#
# Allow DNS
$IP6TABLES -A INPUT -p udp --sport 53 -j ACCEPT
$IP6TABLES -A INPUT -p tcp --sport 53 -j ACCEPT
#
# SSH brute-force protection
$IP6TABLES -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
$IP6TABLES -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
#
# Syn-flood protection
$IP6TABLES -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j RETURN
$IP6TABLES -A INPUT -p tcp --syn -j DROP
#
# Protection against port scanning
$IP6TABLES -N port-scanning
$IP6TABLES -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
$IP6TABLES -A port-scanning -j DROP
#
# Block Packets From Special-Purpose IPv6 Addresses
$IP6TABLES -t mangle -A PREROUTING -s ff00::/8 -j DROP  # Multicast
$IP6TABLES -t mangle -A PREROUTING -s fe80::/10 -j DROP # Link-local
$IP6TABLES -t mangle -A PREROUTING -s 2001:db8::/32 -j DROP # Documentation
$IP6TABLES -t mangle -A PREROUTING -s fc00::/7 -j DROP  # Unique local address
$IP6TABLES -t mangle -A PREROUTING -s ::1/128 -j DROP   # Loopback address
#
# Allow outgoing traffic
$IP6TABLES -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IP6TABLES -A OUTPUT -j ACCEPT
#
#
ip6tables-save
ip6tables-save > /usr/local/rules6.save
#
echo "Ip6tables rules have been set!"
