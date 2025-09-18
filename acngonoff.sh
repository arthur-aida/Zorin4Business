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
# Script que ativa o APTCACHER-NG nos possíveis endereços onde possa estar disponível. 
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing

if [ ! -f /etc/om.ips  ]; then
	cp -f hgu.ips /etc/om.ips 
fi
. /etc/om.ips

apt install net-tools -y
# Recupera o endereço IP/NETMASK
KVMIP=`ip addr show |grep "virbr0" |grep -v dynamic | grep "inet " | head -1|cut -d" " -f6`
HOSTIP=`ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
if [ ! -z $KVMIP ]; then
	# Extrai os OCTETOS do endereço/mask para remontar o IP
	OI1=`echo $KVMIP | cut -d . -f 1`
	OI2=`echo $KVMIP | cut -d . -f 2`
	OI3=`echo $KVMIP | cut -d . -f 3`
else
	if [ ! -z $HOSTIP ]; then
		# Extrai os OCTETOS do endereço/mask para remontar o IP
		OI1=`echo $HOSTIP | cut -d . -f 1`
		OI2=`echo $HOSTIP | cut -d . -f 2`
		OI3=`echo $HOSTIP | cut -d . -f 3`
	else
		zenity   --warning --text="FALHA! O AMBIENTE PARA CUSTOMIZAÇÃO DE ISOS E QUE USA O APT-CACHER-NG NÃO ESTA INSTALADO!" --width=550 --height=200
		# Remove configuração anterior do proxy 
		if [ -f /etc/apt/apt.conf.d/00aptproxy ]; then
			rm -f /etc/apt/apt.conf.d/00aptproxy
		fi
		exit
	fi
fi

# Define as variaveis para acessar o AptCacherNG na porta padrão no host real do KVM
HTP="http://"$OI1"."$OI2"."$OI3".1:3142"
FTP="ftp://"$OI1"."$OI2"."$OI3".1:3142"

# Recupera o gateway default para verificar o ambiente de execução (KVM-server ou VM)
GW=`route -n | awk '$1 == "0.0.0.0" {print $2}'`
OG1=`echo $GW | cut -d . -f 1`
OG2=`echo $GW | cut -d . -f 2`
OG3=`echo $GW | cut -d . -f 3`

# Normalmente o IP do AptCacher é = AC_NG
AC_NG=$OI1"."$OI2"."$OI3".1"
if [ -z $KVMIP ]; then
	# Se KVMIP for vazio, deve ser uma VM executada dentro do KVM-linux

	nc -w 1 -v $AC_NG 3142 < /dev/null
	if [ $? -eq 0 ] && [ ! -f /etc/apt/apt.conf.d/00aptproxy ]; then
		echo 'Acquire::http::Proxy "'$HTP'";'  > /etc/apt/apt.conf.d/00aptproxy
		echo 'Acquire::https::Proxy "'$HTP'";' >> /etc/apt/apt.conf.d/00aptproxy
		echo 'Acquire::ftp::Proxy "'$FTP'";' >> /etc/apt/apt.conf.d/00aptproxy
	fi
else # DEVE SER UM HOST KVM REAL
	nc -w 1 -v $APTCACHER $CACHEPORT < /dev/null
	if [ $? -eq 0 ]; then
		# Define as variaveis para acessar o AptCacherNG, conforme dados da conexão ativa obtidos em om.ips
		echo 'Acquire::http::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' > /etc/apt/apt.conf.d/00aptproxy
		echo 'Acquire::https::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' >> /etc/apt/apt.conf.d/00aptproxy
		echo 'Acquire::ftp::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' >> /etc/apt/apt.conf.d/00aptproxy
	else
		echo 'Acquire::http::Proxy "'$HTP'";'  > /etc/apt/apt.conf.d/00aptproxy
		echo 'Acquire::https::Proxy "'$HTP'";' >> /etc/apt/apt.conf.d/00aptproxy
		echo 'Acquire::ftp::Proxy "'$FTP'";' >> /etc/apt/apt.conf.d/00aptproxy
	fi
fi
cat /etc/apt/apt.conf.d/00aptproxy
