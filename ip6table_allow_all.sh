#!/bin/sh
# Accept all traffic first to avoid ssh lockdown  via ip6tables firewall rules #
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT
 
# Flush All ip6tables Chains/Firewall rules #
ip6tables -F
 
# Delete all ip6tables Chains #
ip6tables -X
 
# Flush all counters too #
ip6tables -Z 
# Flush and delete all nat and  mangle #
ip6tables -t nat -F
ip6tables -t nat -X
ip6tables -t mangle -F
ip6tables -t mangle -X
ip6tables -t raw -F
ip6tables -t raw -X
#
#
ip6tables-save
ip6tables-save > /usr/local/rules6.save
#
echo "Ip6tables rules have been set!"
