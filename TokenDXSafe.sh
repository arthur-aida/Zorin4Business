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
# Este script instala o driver do token DXToken compilado pelo site acdefesa. O driver original de www.dexon.ind.br/downloads/ não funciona. 
# #-------------------------------------------------------------------------------------------------------------------------------
# 
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp

if [ ! -f /etc/Dexon/DXSafe/libDXSafePKCS11.x64.so ]; then 
	apt install net-tools cifs-utils curl git pcsc-tools pcscd cpuidtool libpcsclite-dev flex build-essential libusb-1.0-0-dev mlocate -y
	apt update && apt full-upgrade -y ; apt --fix-broken install -y

	apt-get install --reinstall pkg-config cmake-data --assume-yes
	apt --fix-broken install

	wget https://repositorio-acp.acdefesa.mil.br/Drivers_Token/Dexon/Ubuntu/Drive_Ubuntu_22_04_install.zip -O /tmp/DX_Ubuntu_22.04_LTS.zip
	unzip -o -d /tmp /tmp/DX_Ubuntu_22.04_LTS.zip
	zenity   --warning --text="Será instalado o driver do DXToken compilado pelo site acdefesa. O original de www.dexon.ind.br/downloads/ não funciona." --width=650 --height=150
	bash /tmp/instala_drive_DXSAFE_2_0_2.sh
	apt --fix-broken install

	cp -f /etc/Dexon/DXSafe/libDXSafePKCS11.x32.so /usr/lib/libDXSafePKCS11.x32.so
	cp -f /etc/Dexon/DXSafe/libDXSafePKCS11.x64.so /usr/lib/libDXSafePKCS11.x64.so
				
	chmod 755 /usr/lib/libDXSafePKCS11*
fi
