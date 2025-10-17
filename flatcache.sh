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

if [ ! -f /etc/om.ips  ]; then
	cp -f hgu.ips /etc/om.ips
fi
. /etc/om.ips

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

NFS_S=$OI1"."$OI2"."$OI3".1"
nc -w 1 -v $NFS_S 2049 < /dev/null # TESTA SE O SERVIDOR NFS ESTÁ ATIVO
if [ $? -eq 0 ]; then
	#usuariofp=`grep '^sudo:.*$' /etc/group | cut -d: -f4`
	#Pasta do usuário onde é compartilhado e armazenado o cache dos pacotes flatpak no servidor com endereco KVMIP
	/bin/mount -t nfs $NFS_S:/partimag/flatpakcache/ /mnt
	# confirmação visual
	ls -last /mnt

	if [ ! -d /tmp/cache/  ]; then
		mkdir /tmp/cache/
	fi
	/bin/mount -t nfs $NFS_S:/partimag/cache/ /tmp/cache/
	# COPIA A SOLUÇÃO DE SEGURANÇA CORPORATIVA PARA INSTALAÇÃO AUTOMATICA 
	if [ ! -f /etc/KSEzorin.sh ]; then
		cp -f /tmp/cache/klnagent64*.deb /etc/
		cp -f /tmp/cache/kesl_12*.deb /etc/
		cp -f /tmp/cache/kesl-gui_12*.deb /etc/
		cp -f /tmp/cache/KSEzorin.sh /etc/KSEzorin.sh
		sync
		chmod +x /etc/KSEzorin.sh
	fi
	
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

# Se a variavel site está definida no arquivo om.ips, definir-se-á diretivas durante a customização
if  [ $site = "https://www.google.com.br" ]; then
	# remove software corporativo para adequação ao uso domestico 
	flatpak uninstall --system app/br.app.pw3270.terminal io.github.nroduit.Weasis -y
fi

if  [ $site != "https://www.google.com.br" ]; then
	# remove software domestico para adequação ao uso corporativo 
	flatpak uninstall  --system org.onlyoffice.desktopeditors -y
fi


