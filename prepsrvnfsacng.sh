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
#-------------------------------------------------------------------------------------------------------------------------------------
#  Configura uma estação ou notebook com requisitos necessários para o  Clonezilla gerar imagens de auto re-instalação com ISO's
#  Base: KVM-linux e ferramentras do ssh; Gerenciamento e otimizadores de download: apt-cacher-NG e NFS-server para o cache do flatpak 
#-------------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
if [ ! -f /etc/om.ips ]; then
	cp -f om.ips /etc/
	if [ -f hgu.ips ]; then
		cp -f hgu.ips /etc/om.ips
	else
		cp -f gac.ips /etc/om.ips
	fi
fi
. /etc/om.ips

apt install apt-cacher-ng -y
systemctl start apt-cacher-ng && systemctl enable apt-cacher-ng
sh acng.sh

nome="nfs-kernel-server"
apt-get install --assume-yes $nome
apt-get install --assume-yes qemu-system-x86-64 qemu qemu-kvm qemu-utils virt-manager virt-viewer libvirt-daemon spice-vdagent spice-webdavd

nome="openssh-sftp-server"
pacote=$(dpkg --get-selections | grep "$nome" )
if [ -n "$pacote" ]; then
     	echo "PACOTE  $nome JÁ INSTALADO"
else
	apt-get install --assume-yes openssh-sftp-server
fi

					# Recupera o gateway default para verificar o ambiente de execução
GW=`route -n | awk '$1 == "0.0.0.0" {print $2}'`

# Recupera o endereço IP servidor KVM do host, SFC
I_P=`ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
O1=`echo $I_P | cut -d . -f 1`
O2=`echo $I_P | cut -d . -f 2`
O3=`echo $I_P | cut -d . -f 3`
O4="1"
GW_K=$O1"."$O2"."$O3"."$O4

# Definição das configurações do NFS 
echo "" > /etc/exports
if [ $GW!=$GW_K ]; then 
	# Define os 3 octetos iniciais da rede quando for executado no host REAL com GW da LAN diferente do gateway do KVM  
	O1=`echo $GW | cut -d . -f 1`
	O2=`echo $GW | cut -d . -f 2`
	O3=`echo $GW | cut -d . -f 3`
	LA_N=$O1"."$O2"."$O3".0/22"
	#Configura o compartilhamento com a subrede da LAN somente leitura
	echo "/partimag $LA_N(ro,sync,no_subtree_check)" >> /etc/exports
fi

if [ $GW_K = $I_P ]; then 
	# Define os 3 octetos iniciais da rede do KVM-Linux quando for executado no host REAL com GW_K igual ao IP do KVM server  
	O1=`echo $I_P | cut -d . -f 1`
	O2=`echo $I_P | cut -d . -f 2`
	O3=`echo $I_P | cut -d . -f 3`
	LA_N=$O1"."$O2"."$O3".0/24"
	# Configura o compartilhamento com a subrede do KVM como escrita
	echo "/partimag $LA_N(rw,sync,no_subtree_check)" >> /etc/exports
fi

if [ ! -d /partimag ]; then
	mkdir -p /partimag
	mkdir -p /partimag/cache
	mkdir -p /partimag/flatcache
fi
chown -R nobody:nogroup /partimag
chmod 775 /partimag

#https://unix.stackexchange.com/questions/646224/nfs-share-umask
setfacl -m d:u:65534:rwx,d:g:65534:rwx,d:m::rx,d:o::rx  /partimag/

exportfs -a; exportfs -r

sh flatcache.sh
