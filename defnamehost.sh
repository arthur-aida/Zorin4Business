#!/bin/bash

# Este script recupera o MAC e o IP do gateway default, processa os dados
# e define a variável a ser atribuída como nome do host (hostname).

# ==============================================================================
# 1. IDENTIFICAÇÃO E VERIFICAÇÃO INICIAL
# ==============================================================================

# Obter o Endereço IP do Gateway Padrão
GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}' 2>/dev/null)
if [ -z "$GATEWAY_IP" ]; then
    echo "ERRO Crítico: Não foi possível determinar o endereço IP do gateway default." >&2
    exit 1
fi

# Obter a Interface de Rede Padrão
DEFAULT_INTERFACE=$(ip route show default | grep -oP 'dev\s+\K\S+' 2>/dev/null)
if [ -z "$DEFAULT_INTERFACE" ]; then
    echo " ERRO Crítico: Não foi possível determinar a interface de rede padrão." >&2
    echo "" > /etc/hostname
    #bash +x nameboardwithid.sh
    exit 1
fi

# ==============================================================================
# 2. PROCESSAMENTO DO MAC ADDRESS (4 últimos hexadecimais)
# ==============================================================================

# Obter o MAC address bruto
RAW_MAC_ADDRESS=$(ip link show "$DEFAULT_INTERFACE" | awk '/ether/ {print $2}' 2>/dev/null)
if [ -z "$RAW_MAC_ADDRESS" ]; then
    echo "ERRO: Não foi possível obter o MAC address para a interface $DEFAULT_INTERFACE." >&2
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
HOST_NAME="${ID_LAN}_${FOUR_LAST_HEX}"
if [ -f /etc/hostname ] && [ ! -f /etc/hostname.old ]; then
	mv /etc/hostname /etc/hostname.old
	echo "$HOST_NAME" > /etc/hostname
fi
