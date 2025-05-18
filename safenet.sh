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
# Este script instala os drivers para os tokens ALLADIN e SAFENET 5100/5110.
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# 	Referencias consultadas pelas diferentes versões de HARDWARE
# https://github.com/OpenSC/OpenSC/issues/461
# https://igormcoelho.medium.com/usando-token-de-e-cpf-no-gnu-linux-para-assinaturas-digitais-e-servi%C3%A7os-diversos-a47a7d489df0
# https://support.globalsign.com/search?query=safenet
# https://support.globalsign.com/code-signing/safenet-drivers#Linux%20Ubuntu
# https://rogerkrolow.blogspot.com/2018/07/instalacao-etoken-pro-no-ubuntu-1804.html
# https://knowledge.digicert.com/generalinformation/INFO1982.html
# https://certillion.com/index.html
# https://www.linuxmint.com.br/discussion/51779/token-safenet-5100-acessar-pagina-que-o-certificado
# https://diadialinux.wordpress.com/2021/04/12/instalacao-do-token-safenet-5110-ubuntu-20-04/
# https://igormcoelho.medium.com/usando-token-de-e-cpf-no-gnu-linux-para-assinaturas-digitais-e-servi%C3%A7os-diversos-a47a7d489df0
# https://linuxkamarada.com/pt/2018/04/16/configurando-certificado-digital-no-linux-opensuse/#.ZBGrl9LMK00
# https://unix.stackexchange.com/questions/707998/using-a3-token-safenet-5100-in-ubuntu
# https://github.com/LudovicRousseau/CCID
# https://unix.stackexchange.com/questions/707998/using-a3-token-safenet-5100-in-ubuntu
# https://knowledge.digicert.com/general-information/how-to-download-safenet-authentication-client
# https://www.signasafe.com.br/download/safenet-9-0-debian-e-ubuntu-linux-32-e-64-bits/
# https://github.com/opensc/opensc/wiki/aladdin-etoken-pro
# https://uni-tuebingen.de/fileadmin/Uni_Tuebingen/Einrichtungen/ZDV/Dokumente/Software/CA-SW/PKIClient3.65DokuLinux.pdf
# https://qualitycert.com.br/suporte/

# echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"

# carrega variaveis especificas do PERFIL da LAN
. /etc/os-release

# Variável que define a versão do sistema operacional a partir da variavel de ambiente
VSO=$VERSION_CODENAME
if [ ! -f /usr/bin/SACMonitor ]; then
	cd /tmp
	apt-get install openpace libaec-dev zlib1g-dev -y
	apt install pcscd libccid libjbig0 libpcsclite1 opensc-pkcs11 -y
	if [ $VSO = "bionic" ] || [ $VSO = "focal" ] || [ $VSO = "bullseye" ] || [ $VSO = "una" ] || [ $VSO = "elsie" ]; then
		wget https://www.globalsign.com/en/safenet-drivers/USB/10.8/Safenet-Ubuntu-2004.zip -P /tmp/
		unzip -o /tmp/Safenet-Ubuntu-2004.zip -d /tmp/
		dpkg -i /tmp/Ubuntu-2004/safenetauthenticationclient_*.deb
	fi
	if [ $VSO = "jammy" ] || [ $VSO = "victoria" ] || [ $VSO = "faye" ] || [ $VSO = "bookworm" ] || [ $VSO = "virginia" ]; then
		if [ ! -f /tmp/GlobalSign-SAC-Ubuntu-2204.zip ]; then 
			wget https://www.globalsign.com/en/safenet-drivers/USB/10.8/GlobalSign-SAC-Ubuntu-2204.zip  -P /tmp/
		fi
		# 24.04 wget https://www.digicert.com/StaticFiles/Linux_SAC_10.9_GA.zip?
		# https://www.digicert.com/StaticFiles/Linux_SAC_10_8_R1_GA.zip
		unzip -o /tmp/GlobalSign-SAC-Ubuntu-2204.zip -d /tmp/
		dpkg -i /tmp/Ubuntu-2204/safenetauthenticationclient_*.deb
	fi
fi


