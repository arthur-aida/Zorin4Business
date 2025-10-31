#!/bin/bash

# Este script recupera o nome da placa-mãe via sysfs e
# processa a string em duas partes (Fabricante e Produto).

# Caminhos do sistema (acessíveis sem sudo)
DMI_PATH="/sys/class/dmi/id"
VENDOR_FILE="$DMI_PATH/board_vendor"
PRODUCT_FILE="$DMI_PATH/board_name"

# Variáveis que serão definidas no final
VENDOR=""
LEN_VENDOR=0
NUMBERPRODUCTID=""
LEN_NUMBERPRODUCTID=0

# ==============================================================================
# 1. FUNÇÃO DE LEITURA E PREPARAÇÃO DOS DADOS BRUTOS
# ==============================================================================

# Função para ler o conteúdo de um arquivo DMI e limpar espaços no fim/início
read_dmi_file() {
    if [ -r "$1" ]; then
        # Lê, remove quebras de linha/tabulações, remove espaços no início/fim
        cat "$1" 2>/dev/null | tr -d '\n\t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
    else
        echo ""
    fi
}

# Capturar Fabricante e Produto
RAW_VENDOR_PART=$(read_dmi_file "$VENDOR_FILE")
RAW_PRODUCT_PART=$(read_dmi_file "$PRODUCT_FILE")
echo "rawvendorpart: "$RAW_VENDOR_PART
echo "rawproductpart: "$RAW_PRODUCT_PART

# Validar a leitura
if [ -z "$RAW_VENDOR_PART" ] || [ -z "$RAW_PRODUCT_PART" ]; then
    echo "ERRO: Não foi possível ler o Fabricante e/ou o Produto da placa-mãe. Usando valores de fallback." >&2
    RAW_VENDOR_PART="GENERIC MANUFACTURER"
    RAW_PRODUCT_PART="UNKNOWN_PRODUCT_MODEL"
fi

# ==============================================================================
# 2. PROCESSAMENTO DA PRIMEIRA PARTE (Fabricante -> VENDOR e LEN_VENDOR)
# ==============================================================================

# 2.1. Remoção de espaços e obtenção da Primeira Parte
CLEAN_VENDOR_PART=$(echo "$RAW_VENDOR_PART" | tr -d ' ')

# 2.2. Armazenar os 7 primeiros caracteres na variável "VENDOR"
# Usando 'cut' para garantir compatibilidade total (substitui ${VAR:0:7})
# Envia a string, e 'cut -c 1-7' pega os caracteres da posição 1 até 7.
VENDOR=$(echo "$CLEAN_VENDOR_PART" | cut -c 1-7)

# 2.3. Armazenar o comprimento de "VENDOR" em "LEN_VENDOR"
LEN_VENDOR=${#VENDOR}

# ==============================================================================
# 3. PROCESSAMENTO DA ÚLTIMA PARTE (Produto -> NUMBERPRODUCTID e LEN_NUMBERPRODUCTID)
# ==============================================================================

# 3.1. Remoção de espaços e obtenção da Última Parte
CLEAN_PRODUCT_PART=$(echo "$RAW_PRODUCT_PART" | tr -d ' ')

# 3.2. Armazenar até os 8 últimos caracteres na variável "NUMBERPRODUCTID"
MAX_LAST_CHARS=8

# Usando 'rev' e 'cut' para garantir compatibilidade total (substitui ${VAR: -8})
# 1. rev: Inverte a string
# 2. cut: Pega os 8 primeiros (que são os últimos 8 invertidos)
# 3. rev: Inverte de volta
NUMBERPRODUCTID=$(echo "$CLEAN_PRODUCT_PART" | rev | cut -c 1-$MAX_LAST_CHARS | rev)

# 3.3. Armazenar o comprimento de "NUMBERPRODUCTID" em "LEN_NUMBERPRODUCTID"
LEN_NUMBERPRODUCTID=${#NUMBERPRODUCTID}

# ==============================================================================
# 4. APRESENTAÇÃO DOS RESULTADOS FINAIS
# ==============================================================================

echo "$VENDOR$NUMBERPRODUCTID" > /etc/hostname
