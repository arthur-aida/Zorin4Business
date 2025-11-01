#!/bin/bash
# Este script depende do acionamento no /etc/crontab pela linha 
# @reboot root /bin/sleep 30 && bash /etc/defnamehost.sh
# Este script testa o IP do gateway default e a interface padrão, 
# na sequencia, processa o MAC ADDRESS e o endereço IP da interface 
# padrão como exemplo, MAC:AA:BB:CC:DD:EE:FF e IP: 172.16.0.1/24 com 
# a saída processada igual a z172016ccddeeff que será a variável a ser 
# atribuída como nome do host (hostname). Em quaisquer situaçoes de erro,
# o hostname será redefinido para o modelo da placa mãe, se possível.
# ==============================================================================
# 1. IDENTIFICAÇÃO E VERIFICAÇÃO INICIAL
# ==============================================================================
CODE_MANUFACTOR=`dmidecode -s system-manufacturer`
VM_MODELS= "VMwareVirtualBoxQEMUKVMHyper-V"
if echo $CODE_MANUFACTOR | grep -qi $VM_MODELS; then
    NAMEBOARD=$(dmidecode -s system-product-name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
else
    NAMEBOARD=$(cat /sys/class/dmi/id/board_name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
fi
hostnamectl set-hostname $NAMEBOARD

# Obter o Endereço IP do Gateway Padrão
GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}' 2>/dev/null)
if [ -z "$GATEWAY_IP" ]; then
    echo "ERRO Crítico: Não foi possível determinar o endereço IP do gateway default." >&2
    hostnamectl set-hostname $NAMEBOARD
    exit 1
fi

# Obter a Interface de Rede Padrão
DEFAULT_INTERFACE=$(ip route show default | grep -oP 'dev\s+\K\S+' 2>/dev/null)
if [ -z "$DEFAULT_INTERFACE" ]; then
    echo " ERRO Crítico: Não foi possível determinar a interface de rede padrão." >&2
    hostnamectl set-hostname $NAMEBOARD
    exit 1
fi

# ==============================================================================
# 2. PROCESSAMENTO DO MAC ADDRESS (4 últimos hexadecimais)
# ==============================================================================

# Obter o MAC address bruto
RAW_MAC_ADDRESS=$(ip link show "$DEFAULT_INTERFACE" | awk '/ether/ {print $2}' 2>/dev/null)
if [ -z "$RAW_MAC_ADDRESS" ]; then
    echo "ERRO: Não foi possível obter o MAC address para a interface $DEFAULT_INTERFACE." >&2
    hostnamectl set-hostname $NAMEBOARD
    exit 1
fi

# Remove os dois pontos e pega os 8 caracteres finais (4 últimos pares hexadecimais)
# Ex: AABBCCDDeeff0123 -> EEFF0123 (8 caracteres)
MAC_FULL_UNIFIED=$(echo "$RAW_MAC_ADDRESS" | tr -d ':')
# Usamos expansão de parâmetro do Bash: : -8 pega os últimos 8 caracteres.
FOUR_LAST_HEX="${MAC_FULL_UNIFIED: -8}"

# ==============================================================================
# 3. PROCESSAMENTO DO ENDEREÇO IP (2 primeiros octetos formatados)
# ==============================================================================

# Separa os octetos usando o ponto como delimitador e armazena em um array
IFS='.' read -r -a IP_OCTETS <<< "$GATEWAY_IP"

# Verifica se o IP é IPv4
if [ ${#IP_OCTETS[@]} -ne 4 ]; then
    echo "ERRO: O IP do gateway ($GATEWAY_IP) não é um IPv4 válido (4 octetos)." >&2
    hostnamectl set-hostname $(cat /sys/class/dmi/id/board_name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    exit 1
fi

# Os dois primeiros octetos são os índices [0] e [1]
OCTET_A=${IP_OCTETS[0]} # Primeiro octeto
OCTET_B=${IP_OCTETS[1]} # Segundo octeto

# Formatar cada octeto para 3 caracteres, preenchendo com "0" à esquerda
# Usamos printf para garantir a formatação correta: %03d
FORMATTED_A=$(printf "%03d" "$OCTET_A")
FORMATTED_B=$(printf "%03d" "$OCTET_B")

# Concatenar os octetos formatados e definir ID_LAN
ID_LAN="${FORMATTED_A}${FORMATTED_B}"

# ==============================================================================
# 4. CONCATENAÇÃO FINAL
# ==============================================================================

# Definir a variável HOST_NAME concatenando ID_LAN e FOUR_LAST_HEX, separados por "_"
HOST_NAME='z'"${ID_LAN}_${FOUR_LAST_HEX}"
hostnamectl set-hostname "$HOST_NAME"
