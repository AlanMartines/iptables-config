Documentação dos Scripts de Firewall
====================================

Esta documentação abrange os scripts de configuração de firewall para IPv6 e IPv4 utilizados em sistemas Linux. Os scripts são responsáveis por configurar regras de segurança que controlam o tráfego de entrada e saída.

ip6table\_firewall.sh
---------------------

Este script configura o firewall para IPv6 usando o `ip6tables`. Ele define políticas padrão para rejeitar todo o tráfego, exceto o que é explicitamente permitido.

### Uso:

    sh ip6table_firewall.sh

### Funcionalidades:

*   Ativa o encaminhamento de IPv6.
*   Define políticas padrão para DROP.
*   Permite tráfego relacionado e estabelecido.
*   Registra novas conexões.
*   Permite tráfego ilimitado na interface de loopback e docker0.
*   Permite serviços específicos como SSH, SMTP, HTTP e HTTPS.
*   Proteção contra ataques de força bruta no SSH, SYN-flood e varredura de portas.
*   Bloqueia pacotes de endereços IPv6 especiais.

iptable\_firewall.sh
--------------------

Este script configura o firewall para IPv4 usando o `iptables`. Semelhante ao script de IPv6, ele estabelece uma política de segurança rigorosa e permite apenas o tráfego definido.

### Uso:

    sh iptable_firewall.sh

### Funcionalidades:

*   Habilita o encaminhamento de IPv4.
*   Define políticas padrão para DROP.
*   Permite conexões RELATED e ESTABLISHED.
*   Registra novas conexões.
*   Permite tráfego ilimitado na interface de loopback e docker0.
*   Permite serviços específicos como SSH, SMTP, HTTP e HTTPS.
*   Proteção contra ataques de força bruta no SSH, SYN-flood e varredura de portas.

Instruções de Instalação
------------------------

Para instalar e executar estes scripts em seu sistema:

1.  Faça o download dos scripts para o seu sistema Linux.
2.  Dê permissão de execução para os scripts com o comando `chmod +x ip6table_firewall.sh iptable_firewall.sh`.
3.  Execute os scripts como superusuário (root) para aplicar as regras de firewall.

Nota Importante
---------------

Modificar as regras de firewall pode afetar a segurança e a acessibilidade do seu sistema. Certifique-se de entender completamente as regras que você está aplicando e tenha cuidado ao expor serviços na internet.

Contribuições
-------------

[Contribuições](CONTRIBUTING.md) são bem-vindas! Por favor, abra uma issue ou pull request.

Licença
-------

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
