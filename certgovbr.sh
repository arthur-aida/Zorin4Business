#!/bin/bash
# The contents of this file are released under the GNU General Public License.
# Feel free to reuse the contents of this work, as long as the resultant works give proper
# attribution and are made publicly available under the GNU General Public License.
# https://www.gnu.org/licenses/gpl-faq.en.html#GPLRequireSourcePostedPublic
#-------------------------------------------------------------------------------------------------------------------------------
# Este script é um software livre; você pode redistribuí-lo e/ou
#  modificá-lo dentro dos termos da Licença Pública Geral GNU como
#  publicada pela Free Software Foundation (FSF); na versão 3 da
#  Licença, ou (a seu critério) qualquer versão posterior.
# Este programa é distribuído na esperança de que possa ser útil,
#  mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO
#  a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a
#  Licença Pública Geral GNU para maiores detalhes.
#-------------------------------------------------------------------------------------------------------------------------------
# Este script baixa certificados, configura e os disponibiliza aos MOZILLAs. 
# No momento, os sites GOV são acessados por certificados assinados pelo ICP-Brasil não incluidos nos navegadores
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.

# Marca o path
local=`pwd`
# Carrega variaveis de cada perfil
. /etc/om.ips

echo "######### VERIFICANDO A VALIDADE EM https://www.gov.br/iti/pt-br/assuntos/repositorio/cadeias-da-icp-brasil"
# https://www.gov.br/iti/pt-br/assuntos/repositorio/certificados-das-acs-da-icp-brasil-arquivo-unico-compactado

# BAIXA UMA REFERÊNCIA EM /tmp/hashsha512.txt E VERIFICA A PRE-EXISTENCIA EM /usr/local/share/ca-certificates/hashsha512.txt
wget --no-check-certificate -c https://acraiz.icpbrasil.gov.br/credenciadas/CertificadosAC-ICP-Brasil/hashsha512.txt -P /tmp/
if [ ! -f /usr/local/share/ca-certificates/hashsha512.txt ]; then
	echo "" > /usr/local/share/ca-certificates/hashsha512.txt
fi 

# Se a referência não for igual a /usr/local/share/ca-certificates/hashsha512.txt, baixa o novo pacote de certificados
if ! cmp --silent /tmp/hashsha512.txt /usr/local/share/ca-certificates/hashsha512.txt; then
	wget --no-check-certificate -c https://acraiz.icpbrasil.gov.br/credenciadas/CertificadosAC-ICP-Brasil/ACcompactado.zip -O /tmp/ACcompactado.zip
	cd /tmp
	# Calcula o checksum para autenticar com a referencia baixada do site
	sha512sum ACcompactado.zip > /usr/local/share/ca-certificates/hashsha512.txt
	cd $local
	
	# Verifica se os hash são iguais, descompacta os certificados.
	if cmp --silent /tmp/hashsha512.txt /usr/local/share/ca-certificates/hashsha512.txt; then
		unzip -o -d /usr/local/share/ca-certificates/ /tmp/ACcompactado.zip
	else
		zenity   --warning --text="O CHECKSUM DO ARQUIVO BAIXADO NÃO CONFERE COM O DISPONIVEL NO SITE." --width=550 --height=100
		exit
	fi
fi

# ATUALIZA OS CERTIFICADOS BAIXADOS
update-ca-certificates

# Esta atualização é muito útil para acesso ao contratos via tokens, assim como em sites que exigem acesso com certificados e tokens

