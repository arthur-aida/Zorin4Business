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
	if [ -f hgu.ips ]; then
		cp -f hgu.ips /etc/om.ips
	else
		cp -f gac.ips /etc/om.ips
	fi
fi
. /etc/om.ips

apt update
apt-get install  --reinstall --assume-yes apt-cacher-ng net-tools qemu-system-x86-64 qemu qemu-kvm qemu-utils virt-manager virt-viewer libvirt-daemon spice-vdagent spice-webdavd nfs-kernel-server libappindicator1 openssh-sftp-server openssh-server sshfs xterm flatpak nfs-common

systemctl restart libvirtd && systemctl restart virtqemud.socket && systemctl restart libvirtd.socket && systemctl status libvirtd
systemctl restart libvirtd && systemctl restart virtqemud.socket && systemctl restart libvirtd.socket && systemctl status libvirtd

# Recupera o gateway default para verificar o ambiente de execução
GW=`route -n | awk '$1 == "0.0.0.0" {print $2}'`

# Recupera o endereço IP do servidor KVM-linux do host, SFC
I_P=`ip addr show |grep "virbr0" |grep -v dynamic | grep "inet " | head -1|cut -d" " -f6`

if [ ! -d /partimag ]; then
	mkdir -p /partimag
	mkdir -p /partimag/cache
	mkdir -p /partimag/flatpakcache
fi

# Definição das redes permitidas do NFS
echo "" > /etc/exports
# Define os 3 octetos iniciais do gateway da rede
OG1=`echo $GW | cut -d . -f 1`
OG2=`echo $GW | cut -d . -f 2`
OG3=`echo $GW | cut -d . -f 3`
LA_N=$OG1"."$OG2"."$OG3".0/22"
# Habilita o compartilhamento com a rede da LAN somente leitura
echo "/partimag $LA_N(ro,sync,no_subtree_check)" >> /etc/exports

# Define os 3 octetos iniciais da rede do KVM-Linux 
if [ ! -z $I_P ]; then
	OK1=`echo $I_P | cut -d . -f 1`
	OK2=`echo $I_P | cut -d . -f 2`
	OK3=`echo $I_P | cut -d . -f 3`
	LA_N=$OK1"."$OK2"."$OK3".0/24"
	# Habilita o compartilhamento com a subrede do KVM como escrita
	echo "/partimag $LA_N(rw,sync,no_subtree_check)" >> /etc/exports
	# Define as variaveis para acessar o AptCacherNG na porta padrão no host do KVM, conforme dados da conexão ativa obtidos em I_P
	HTP="http://"$OK1"."$OK2"."$OK3".1:3142"
	FTP="ftp://"$OK1"."$OK2"."$OK3".1:3142"
	
	# Normalmente o IP do AptCacher no ambiente KVM do HW real está definido para o primeiro IP disponivel da rede KVM-linux server
	AC_NG=$OK1"."$OK2"."$OK3".1" # Em teoria = $GW
	if [ $OG1 = $OK1 ] && [ $OG2 = $OK2  ] && [ $OG3 = $OK3 ] ; then
		# Se o os 3 octetos são identicos deve ser uma VM executada dentro do KVM-linux
	
		nc -w 1 -v $AC_NG 3142 < /dev/null
		if [ $? -eq 0 ] && [ ! -f /etc/apt/apt.conf.d/00aptproxy ]; then
			echo 'Acquire::http::Proxy "'$HTP'";'  > /etc/apt/apt.conf.d/00aptproxy
			echo 'Acquire::https::Proxy "'$HTP'";' >> /etc/apt/apt.conf.d/00aptproxy
			echo 'Acquire::ftp::Proxy "'$FTP'";' >> /etc/apt/apt.conf.d/00aptproxy
		fi
	else
		# Define as variaveis para acessar o AptCacherNG, conforme dados da conexão ativa obtidos em om.ips
	
		nc -w 1 -v $APTCACHER $CACHEPORT < /dev/null
		if [ $? -eq 0 ]; then
			echo 'Acquire::http::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' > /etc/apt/apt.conf.d/00aptproxy
			echo 'Acquire::https::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' >> /etc/apt/apt.conf.d/00aptproxy
			echo 'Acquire::ftp::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' >> /etc/apt/apt.conf.d/00aptproxy
		else
			if [ $GW != $AC_NG ]; then
				echo 'Acquire::http::Proxy "'$HTP'";'  > /etc/apt/apt.conf.d/00aptproxy
				echo 'Acquire::https::Proxy "'$HTP'";' >> /etc/apt/apt.conf.d/00aptproxy
				echo 'Acquire::ftp::Proxy "'$FTP'";' >> /etc/apt/apt.conf.d/00aptproxy
			fi
		fi
	fi
fi

# Configurações para que qualquer rede do KVM-Linux acesse o APT-cacher-NG
echo 'CacheDir: /var/cache/apt-cacher-ng' > /etc/apt-cacher-ng/acng.conf
echo 'LogDir: /var/log/apt-cacher-ng' >> /etc/apt-cacher-ng/acng.conf
echo 'SupportDir: /usr/lib/apt-cacher-ng' >> /etc/apt-cacher-ng/acng.conf
echo 'Port:3142' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-debrep: file:deb_mirror*.gz /debian ; file:backends_debian' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-uburep: file:ubuntu_mirrors /ubuntu' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-klxrep: file:kali_mirrors /kali' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-cygwin: file:cygwin_mirrors /cygwin' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-sfnet:  file:sfnet_mirrors' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-alxrep: file:archlx_mirrors /archlinux # ; file:backend_archlx' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-fedora: file:fedora_mirrors' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-epel:   file:epel_mirrors' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-slrep:  file:sl_mirrors' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-gentoo: file:gentoo_mirrors.gz /gentoo' >> /etc/apt-cacher-ng/acng.conf
echo 'Remap-secdeb: security.debian.org security.debian.org/debian-security deb.debian.org/debian-security /debian-security cdn-fastly.deb.debian.org/debian-security' >> /etc/apt-cacher-ng/acng.conf
echo 'ReportPage: acng-report.html' >> /etc/apt-cacher-ng/acng.conf
echo 'ExThreshold: 4' >> /etc/apt-cacher-ng/acng.conf
echo 'FollowIndexFileRemoval: 1' >> /etc/apt-cacher-ng/acng.conf

# Copia arqquivos previamente baixados em outra instalação para acelerar a disponibilidade do cache
if [ -d /media/administrador/toshiba/partimag/apt-cacher-ng ]; then
	cp -f -R /media/administrador/toshiba/partimag/apt-cacher-ng/* /var/cache/apt-cacher-ng/
	chown -R apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng
fi
systemctl start apt-cacher-ng && systemctl enable apt-cacher-ng

if [ -d /media/administrador/toshiba/partimag/cache ]; then
	cp -f -R /media/administrador/toshiba/partimag/cache/* /partimag/cache/
fi

if [ -d /media/administrador/toshiba/partimag/flatpakcache ]; then
	cp -f -R /media/administrador/toshiba/partimag/flatpakcache /partimag/
fi

chown -R nobody:nogroup /partimag
chmod -R 775            /partimag
setfacl -m d:u:65534:rwx,d:g:65534:rwx,d:m::rx,d:o::rx  /partimag/
exportfs -a; exportfs -r

apt full-upgrade -y
