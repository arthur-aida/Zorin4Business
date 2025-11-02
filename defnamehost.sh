#!/bin/bash
# NOTA: O shebang é configurado para '/bin/sh' para garantir a máxima compatibilidade (POSIX).

# Este script depende do acionamento no /etc/crontab pela linha 
# @reboot root /bin/sleep 30 && bash /etc/defnamehost.sh
# Este script testa o IP do gateway default e a interface padrão, 
# na sequencia, processa o MAC ADDRESS e o endereço IP da interface 
# padrão como exemplo, MAC:AA:BB:CC:DD:EE:FF e IP: 172.16.0.1/24 com 
# a saída processada igual a z172016ccddeeff que será a variável a ser 
# atribuída como nome do host (hostname). VM são exceção. 
# Em quaisquer situaçoes de erro, o hostname será redefinido para localhost.

VIRTUAL="NO"
VM_MANUFACTURER=$(dmidecode -s system-manufacturer 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr -d ' ')

if echo "vmware virtualbox kvm hyper-v qemu" | grep -q "$VM_MANUFACTURER"; then
    NAMEBOARD="$VM_MANUFACTURER"
    VIRTUAL="YES"
fi

# Obter o Endereço IP do Gateway Padrão
GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}' 2>/dev/null)
if [ -z "$GATEWAY_IP" ]; then
    echo "ERRO Crítico: Não foi possível determinar o endereço IP do gateway default." >&2
    hostnamectl set-hostname ""
    exit 1
fi

# Obter a Interface de Rede Padrão
DEFAULT_INTERFACE=$(ip route show default | grep -oP 'dev\s+\K\S+' 2>/dev/null)
if [ -z "$DEFAULT_INTERFACE" ]; then
    echo " ERRO Crítico: Não foi possível determinar a interface de rede padrão." >&2
    hostnamectl set-hostname ""
    exit 1
fi

# Obter o MAC address bruto
RAW_MAC_ADDRESS=$(ip link show "$DEFAULT_INTERFACE" | awk '/ether/ {print $2}' 2>/dev/null)
if [ -z "$RAW_MAC_ADDRESS" ]; then
    echo "ERRO: Não foi possível obter o MAC address para a interface $DEFAULT_INTERFACE." >&2
    hostnamectl set-hostname ""
    exit 1
fi

# Remove os dois pontos e pega os 8 caracteres finais (4 últimos pares hexadecimais)
# Ex: AABBCCDDeeff0123 -> EEFF0123 (8 caracteres)
MAC_FULL_UNIFIED=$(echo "$RAW_MAC_ADDRESS" | tr -d ':')
# Usamos expansão de parâmetro do Bash: : -8 pega os últimos 8 caracteres.
FOUR_LAST_HEX="${MAC_FULL_UNIFIED: -8}"

if [ $VIRTUAL = "NO" ]; then

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
	HOST_NAME="z${ID_LAN}${FOUR_LAST_HEX}"

else

	#É UMA VM. DEVERÁ SER PROCESSADO OS 6 CARACTERES INICIAIS DA STRING DA PLATAFORMA DE VIRTUALIZAÇÃO 

	# Define o caminho para o arquivo do fornecedor (Vendor) no sistema DMI
	VENDOR_FILE="/sys/class/dmi/id/chassis_vendor"
	MAX_CHARS=6

	# Variável final
	hostname=""
	RAW_VENDOR_STRING=""

	if [ -r "$VENDOR_FILE" ]; then
	    # cat: lê o arquivo
	    # tr -d '\n\t': remove quebras de linha e tabulações
	    # sed 's/^[[:space:]]*//;s/[[:space:]]*$//': remove espaços no início/fim
	    RAW_VENDOR_STRING=$(cat "$VENDOR_FILE" 2>/dev/null | tr -d '\n\t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	    
	    if [ -z "$RAW_VENDOR_STRING" ]; then
		echo "ERRO: Arquivo do Fabricante acessível. A string está vazia." >&2
		RAW_VENDOR_STRING="UNKNOW"
	    fi
	else
	    echo "ERRO: Não foi possível acessar o arquivo $VENDOR_FILE sem root. Falha na leitura." >&2
	    # Valor de fallback, caso a leitura falhe completamente
	    RAW_VENDOR_STRING="UNKNOW"
	fi

	# Remover espaços da string do Fabricante
	# tr -d ' ': remove todos os espaços
	CLEAN_VENDOR=$(echo "$RAW_VENDOR_STRING" | tr -d ' ')

	# Truncar para os 6 primeiros caracteres
	# cut -c 1-6: comando POSIX padrão para fatiamento (slice) de string
	TRUNCATED_VENDOR=$(echo "$CLEAN_VENDOR" | cut -c 1-$MAX_CHARS)

	# Definir a variável final 'hostname'
	ID_LAN=$(echo "$TRUNCATED_VENDOR" | tr '[:lower:]' '[:upper:]')
	HOST_NAME="${ID_LAN}${FOUR_LAST_HEX}"
fi

hostnamectl set-hostname "$HOST_NAME"
echo "$HOST_NAME"


