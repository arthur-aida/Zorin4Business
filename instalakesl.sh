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
# Este script é executado a partir do script aptcacher.sh condicionado a conectividade do DNS
# Faz a correção do arquivo install.sh original para o ubuntu, permitindo a instalação no Zorin OS
#-------------------------------------------------------------------------------------------------------------------------------
# https://www.gnu.org/licenses/gpl-faq.en.html#GPLRequireSourcePostedPublic
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#

. /etc/os-release
. /etc/om.ips
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} = 'x86_64' ]; then
	# 64-bit stuff here
	nome="klnagent64"
else
	# 32-bit stuff here
	nome="klnagent"
fi
#  Aborta a instalação se pre-existe alguma instalação nos caminho especificados  
if [ -d /opt/kaspersky/kesl ] && [ -d /opt/kaspersky/$nome ] ; then
	exit
fi

# descompacta o arquivo previamente preparado, com todos os requisitos da instalação na mesma pasta 
unzip -q /etc/kes-lnx.zip -d /tmp
cd  /tmp/kes-lnx

# Corrige o script para executar especificamente no bash do Zorin OS
if [ $ID="zorin" ]; then
	sed -i 's/==/=/' /tmp/kes-lnx/install.sh
fi
sh /tmp/kes-lnx/install.sh
