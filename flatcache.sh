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
# Este script tenta buscar em cache arquivos flatpak armazenados no host para otimizar o download
# #-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing

# echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"
apt install flatpak nfs-common -y

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ -f om.ips  ]; then
	. ./om.ips
else
	. /etc/om.ips
fi
# recupera o endereço IP local
HOSTIP=`ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
I_P=$HOSTIP

#extrai os 3 PRIMEIROS OCTETOS do endereço IP
O1=`echo $I_P | cut -d . -f 1`
O2=`echo $I_P | cut -d . -f 2`
O3=`echo $I_P | cut -d . -f 3`

# define o NETWORK com base nos OCTETOS
LA_N=$O1"."$O2"."$O3".0/24"

KVM122="192.168.122.0/24"
KVM123="192.168.123.0/24"

if [ $LA_N = $KVM122 ]  ; then
	KVMIP=$O1"."$O2"."$O3".1"
fi
if [ $LA_N = $KVM123 ]  ; then
	KVMIP=$O1"."$O2"."$O3".1"
fi

# TESTA SE O SERVIDOR NFS ESTÁ ATIVO
nc -w 1 -v $KVMIP 2049 < /dev/null 
if [ $? -eq 0 ]; then
	#usuariofp=`grep '^sudo:.*$' /etc/group | cut -d: -f4`
	#usuariofp="adminstrador"
	#Pasta do usuário onde é compartilhado e armazenado o cache dos pacotes flatpak no servidor com endereco KVMIP
	/bin/mount -t nfs $KVMIP:/partimag/flatpakcache/ /mnt
	# confirmação visual
	ls -last /mnt

	# redefine o link original do cache
	flatpak remote-modify --collection-id=org.flathub.Stable flathub
	
	# Lista de pacotes flatpak instalados do cache. Náo instalar o bleachbit em formato flatpak
	flatpak install --sideload-repo=/mnt/.ostree/repo app/com.google.Chrome app/com.microsoft.Edge org.keepassxc.KeePassXC app/com.obsproject.Studio io.github.nroduit.Weasis app/br.app.pw3270.terminal app/org.jitsi.jitsi-meet org.onlyoffice.desktopeditors -y
	
	# sincroniza para a pasta da rede os arquivo que podem ficar em cache
	flatpak create-usb --allow-partial /mnt app/com.google.Chrome
	flatpak create-usb --allow-partial /mnt app/com.microsoft.Edge
	flatpak create-usb --allow-partial /mnt org.keepassxc.KeePassXC
	flatpak create-usb --allow-partial /mnt com.obsproject.Studio
	flatpak create-usb --allow-partial /mnt io.github.nroduit.Weasis
	flatpak create-usb --allow-partial /mnt br.app.pw3270.terminal
	flatpak create-usb --allow-partial /mnt app/org.jitsi.jitsi-meet
	flatpak create-usb --allow-partial /mnt org.onlyoffice.desktopeditors 
else
	# Lista de pacotes flatpak instalados fora do cache. Náo instalar o bleachbit em formato flatpak
	flatpak install flathub app/com.google.Chrome app/com.microsoft.Edge org.keepassxc.KeePassXC app/com.obsproject.Studio io.github.nroduit.Weasis app/br.app.pw3270.terminal app/org.jitsi.jitsi-meet org.onlyoffice.desktopeditors -y
fi

# a variavel site está definida no arquivo om.ips e dá diretivas durante a customização
echo $site
if  [ $site = "https://www.google.com.br" ]; then
	# remove software corporativo para adequação ao uso domestico 
	flatpak uninstall --system app/br.app.pw3270.terminal io.github.nroduit.Weasis -y
fi

if  [ $site != "https://www.google.com.br" ]; then
	# remove software domestico para adequação ao uso corporativo 
	flatpak uninstall  --system org.onlyoffice.desktopeditors -y
fi
if [ ! -d /tmp/cache/  ]; then
	mkdir /tmp/cache/
fi
/bin/mount -t nfs $KVMIP:/partimag/cache/ /tmp/cache/
cp -f /tmp/cache/* /tmp/
