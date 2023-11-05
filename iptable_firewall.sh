#!/bin/sh
#
IPTABLES="/sbin/iptables"
#
# Carregar módulos do kernel
/sbin/modprobe ip_tables
/sbin/modprobe nf_conntrack
/sbin/modprobe iptable_filter
/sbin/modprobe iptable_mangle
/sbin/modprobe iptable_nat
/sbin/modprobe ipt_LOG
/sbin/modprobe ipt_limit
/sbin/modprobe ipt_state
#
# Habilitar Encaminhamento
echo "1" > /proc/sys/net/ipv4/ip_forward
#
# Definir políticas padrão para DROP
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP
#
# Limpar todas as regras do Iptables
$IPTABLES -F
$IPTABLES -X
$IPTABLES -Z
#
# REGRAS DE PROTEÇÃO
#
# Permitir conexões RELATED e ESTABLISHED
$IPTABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#
# Registrar todos os pacotes
$IPTABLES -A INPUT -m conntrack --ctstate NEW -j LOG --log-prefix='[iptables_input] '
$IPTABLES -A OUTPUT -m conntrack --ctstate NEW -j LOG --log-prefix='[iptables_output] '
#
# Permitir tráfego ilimitado na interface de loopback e docker0
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -i docker0 -j ACCEPT
#
# Allow custom rule# Obtenha o endereço IP do contêiner
# Permita todo o tráfego do contêiner para o host
# Lista todos os IDs dos containers em execução
container_ids=$(docker ps -q)
#
# Loop através de cada ID de container
for id in $container_ids
do
    # Obtém o IP do container
    container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    
    # Aplica as regras do iptables para aceitar tráfego de entrada e saída para o IP do container
    $IPTABLES -A INPUT -s $container_ip -j ACCEPT
    $IPTABLES -A OUTPUT -d $container_ip -j ACCEPT
done
#
# Permitir serviços específicos
$IPTABLES -A INPUT -p tcp -m multiport --dports 22,25,80,443,587,465,2525,2280 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
#
# Permitir pings ICMP
$IPTABLES -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
#
# Permitir tráfego para o agente Zabbix
$IPTABLES -A INPUT -p udp --sport 10050 -j ACCEPT
$IPTABLES -A INPUT -p tcp --sport 10051 -j ACCEPT
#
# Permitir tráfego DNS
$IPTABLES -A INPUT -p udp --sport 53 -j ACCEPT
$IPTABLES -A INPUT -p tcp --sport 53 -j ACCEPT
#
# Proteção contra ataques de força bruta no SSH
$IPTABLES -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
$IPTABLES -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
#
# Proteção contra ataques SYN-flood
$IPTABLES -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j RETURN
$IPTABLES -A INPUT -p tcp --syn -j DROP
#
# Proteção contra varredura de portas
$IPTABLES -N port-scanning
$IPTABLES -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
$IPTABLES -A port-scanning -j DROP
#
# Bloquear pacotes com flags TCP inválidos
$IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
#
# Permitir tráfego de saída
$IPTABLES -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -j ACCEPT
#
#
iptables-save
iptables-save > /usr/local/rules.save
#
echo "Iptables rules have been set!"
