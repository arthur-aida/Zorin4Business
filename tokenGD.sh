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
# ######### ESTE SCRIPT INSTALA OS DRIVERS PARA O TOKEN GD SAFESIGN.
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#
# referencias pesquisadas
# https://diadialinux.wordpress.com/2021/03/30/instalacao-do-token-starsign-gd-no-ubuntu-20-04-e-18-04/
# https://safesign.gdamericadosul.com.br/download
# https://igormcoelho.medium.com/usando-token-de-e-cpf-no-gnu-linux-para-assinaturas-digitais-e-servi%C3%A7os-diversos-a47a7d489df0"
# https://github.com/LudovicRousseau/CCID"
# https://diadialinux.wordpress.com/2021/03/30/instalacao-do-token-starsign-gd-no-ubuntu-20-04-e-18-04/"

#echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"
rm  /tmp/*.deb

#  CARREGA VARIAVEIS DO SO 
. /etc/os-release

# carrega variaveis especificas do PERFIL da LAN
. /etc/om.ips

# Variável que define a versão do sistema operacional a partir da variavel de ambiente 
VSO=$VERSION_CODENAME

nome="safesignidentityclient"
pacote=$(dpkg --get-selections | grep "$nome" )
echo "Instalação do Token G&D"
if [ ! -n "$pacote" ]; then
	cd /tmp
	if [ $VSO = "bionic" ]; then
		wget http://ftp.br.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_amd64.deb -P /tmp/
		wget https://storage.digiforte.com.br/libpng12-0_1.2.50-2%2Bdeb8u3_amd64.deb -P /tmp/
		wget http://us.archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-0v5_3.0.4+dfsg-3_amd64.deb
		wget https://safesign.gdamericadosul.com.br/content/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub1804_x86_64.rar -P /tmp/
		unrar e /tmp/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub1804_x86_64.rar
		apt-get install --assume-yes multiarch-support
		dpkg -i /tmp/libpng12-0_1.2.50-2+deb8u3_amd64.deb
		dpkg -i /tmp/libpng12-0_1.2.50-2%2Bdeb8u3_amd64.deb
		dpkg -i /tmp/libwxgtk3.0-0v5_3.0.4+dfsg-3_amd64.deb
		dpkg -i /tmp/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub1804_x86_64.deb
	fi
	
	if [ $VSO = "focal" ] || [ $VSO = "una" ] || [ $VSO = "bullseye" ] || [ $VSO = "elsie" ] || [ $VSO = "bookworm" ] || [ $VSO = "una" ]  || [ $VSO = "uma" ] || [ $VSO = "ulyssa" ] || [ $VSO = "ulyana" ]; then
		wget http://us.archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-0v5_3.0.4+dfsg-3_amd64.deb
		dpkg -i /tmp/libwxgtk3.0-0v5_3.0.4+dfsg-3_amd64.deb
		rm -f /tmp/libwxgtk3.0-0v5_3.0.4+dfsg-3_amd64.deb
		wget https://safesign.gdamericadosul.com.br/content/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.rar  -P /tmp/
		unrar e /tmp/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.rar
		add-apt-repository ppa:linuxuprising/libpng12 -y ; apt update ; apt-get install --assume-yes libpng12-0 
		dpkg -i /tmp/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.deb
		rm -f /tmp/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.deb
	fi

	if [ $VSO = "jammy" ] || [ $VSO = "virginia" ] || [ $VSO = "victoria" ] || [ $VSO = "vera" ] || [ $VSO = "vanessa" ] || [ $VSO = "wilma" ]; then
        	if [ ! -f /tmp/SafeSign_IC_Standard_Linux_ub2204_3.8.0.0_AET.000.zip ]; then 
	        	wget https://safesign.gdamericadosul.com.br/content/SafeSign_IC_Standard_Linux_ub2204_3.8.0.0_AET.000.zip -P /tmp/
		fi
		unzip -qo /tmp/SafeSign_IC_Standard_Linux_ub2204_3.8.0.0_AET.000.zip -d /tmp/
		dpkg -i /tmp/SafeSign*.deb
	fi
fi

