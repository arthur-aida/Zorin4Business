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
# https://publicado.dexon.ind.br/DXSafe/Documentacao/DXSafe/DXSafe%20-%20Manual%20de%20Instala%C3%A7%C3%A3o%20-%20Ubuntu.pdf

if [ ! -f /etc/Dexon/DXSafe/libDXSafePKCS11.x64.so ]; then 
	apt update && apt full-upgrade -y ; apt --fix-broken install -y
	apt-get install --reinstall pkg-config cmake-data --assume-yes
	apt --fix-broken install

	apt install net-tools cifs-utils curl git pcsc-tools pcscd cpuidtool libpcsclite-dev flex build-essential libusb-1.0-0-dev mlocate opensc bzip2 -y
	updatedb && locate libusb.h
	pkg-config libusb-1.0 --libs –cflags
	wget https://ccid.apdu.fr/files/ccid-1.5.2.tar.bz2
	bunzip2 ccid-1.5.2.tar.bz2
	tar -xvf ccid-1.5.2.tar
	rm ccid-1.5.2.tar
	cd ccid-1.5.2	
	./configure
	make
	make install
	cd ..
	rm -Rf ccid-1.5.2
 	wget https://publicado.dexon.ind.br/DXSafe/Instaladores/DXSafe_2.x/2.0.2/DXSafeMiddleware_2.0.2_Linux_Ubuntu.22.04.deb
	dpkg -i DXSafeMiddleware_2.0.2_Linux_Ubuntu.22.04.deb
	rm -f DXSafeMiddleware_2.0.2_Linux_Ubuntu.22.04.deb
	apt --fix-broken install
	cp -f /etc/Dexon/DXSafe/libDXSafePKCS11.x32.so /usr/lib/libDXSafePKCS11.x32.so
	cp -f /etc/Dexon/DXSafe/libDXSafePKCS11.x64.so /usr/lib/libDXSafePKCS11.x64.so
	chmod 755 /usr/lib/libDXSafePKCS11*
fi
