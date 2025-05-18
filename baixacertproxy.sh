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
# Script executado pelo aptcacher.sh para atualizar certificado do ICP-Brasil e do proxy sef or o caso.
# Os IPs deverão refletir a rede de seu provedor. O URL do certificado deve ser editado nos arquivos .ips
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
#echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"
#  CARREGA VARIÁVEIS DE AMBIENTE
local=`pwd`
. /etc/os-release
. /etc/om.ips

#   TESTA CONEXÃO E RECUPERA O CERTIFICADO DO PROVEDOR SFC
nc -w 2 -v $APTCACHER 80 </dev/null
if [ $? -eq 0 ]; then
	# O certificado é necessário para autenticação no proxy
	wget --no-check-certificate $urlcert$nomecert -O /tmp/$nomecert
	unzip -qo /tmp/$nomecert -d /usr/local/share/ca-certificates/
fi

if [ -f /tmp/$nomecert ]; then
	certsize=`wc -c /tmp/$nomecert | awk '{print $1}'`
	if [ $certsize != 0 ]; then
			unzip -qo /tmp/$nomecert -d /usr/local/share/ca-certificates/
	fi
fi

echo "↓↓↓↓↓↓↓↓↓ ADICIONA OS CERTIFICADOS BAIXADOS"
update-ca-certificates
total=`ls -1 /usr/local/share/ca-certificates/ | wc -l`
echo "↓↓↓↓↓↓↓↓↓ TOTAL DE CERTIFICADOS ATIVOS: "$(( $total - 1 ))

