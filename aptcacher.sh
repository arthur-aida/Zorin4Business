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
# Script é acionado pelo crontab. Se for informado um servidor aptcacher no arquivo .ips ativa-o  
# Baixa atualizações do sistema. Instala o AV se for o caso. Reconfigura o acesso ao java pelo mozilla ESR.
# Atualiza os certificados .GOV.BR. Ativa os recursos do TRIM no caso de armazenamento SSD
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
# Caso de falha de sincronização com os repositorios brasileiros ocorrido na operacinalização da fibra submarina entra o Brasil e Portugal.
# Remova a cerquilha da linha abaixo para redirecionar aos repositorios americanos, 
# sed -i 's/br./us./g' /etc/apt/sources.list

# Marcador de atualização inicial
echo "" >/tmp/$(date +%F_%H%M%S)".ini"

# "######### CARREGA VARIÁVEIS NO AMBIENTE DE EXECUÇÃO DO script"
. /etc/os-release

if [ -f /etc/om.ips  ]; then
	. /etc/om.ips
fi

# "↓↓↓↓↓↓↓↓↓ PROCESSA VARIÁVEIS DE AMBIENTE PARA AUXILIO DO PROCESSO"
onde=$(dirname $(readlink -f $0))
# Variavel que armazena o ID da distribuição via os-release
var2=$ID

# "↓↓↓↓↓↓↓↓↓ HABILITA O APT-CACHER-NG CORPORATIVO E ATUALIZA, SE ACESSIVEL E REMOVE-O SE NÃO"
nc -w 1 -v $APTCACHER $CACHEPORT < /dev/null
if [ $? -eq 0 ]; then
	echo 'Acquire::http::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' > /etc/apt/apt.conf.d/00aptproxy
	echo 'Acquire::https::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' >> /etc/apt/apt.conf.d/00aptproxy
	echo 'Acquire::ftp::Proxy "http://'$APTCACHER':'$CACHEPORT'/";' >> /etc/apt/apt.conf.d/00aptproxy
else
	if [ -f /etc/apt/apt.conf.d/00aptproxy ]; then
		rm -f /etc/apt/apt.conf.d/00aptproxy
	fi
fi

# Caso a chamada seja de uma VM do KVM, tenta ativar o ACNG
if [ ! -f /etc/apt/apt.conf.d/00aptproxy ]; then
	sh -x acngonoff.sh
fi

# "Se a conectividade até o servidor de atualização do pacote de segurança corporativo estiver operacional, prossegue com a instalação"
nc -w 2 -v $DNS 53 </dev/null
if [ $? -eq 0 ] && [ -f /etc/KSEzorin.sh ] ; then
	sh  /etc/KSEzorin.sh
fi

apt update
apt full-upgrade -dy

# Filtra as possíveis distros que aceitam  modificações por estes scripts
if [ $var2 = 'zorin' ] || [ $var2 = 'ubuntu' ] || [ $var2 = 'linuxmint' ]; then
	# " ↓↓↓↓↓↓↓↓↓ VERIFICA UPDATES DO MOZILLA"
	sh /etc/firefox-stable.sh
	sh /etc/latest-firefoxesr.sh
	
	# ' ↓↓↓↓↓↓↓↓↓ VERIFICA A VALIDADE DOS CERTIFICADOS GOV.BR COM MAIS DE 30 DIAS'
	baixar=`find /usr/local/share/ca-certificates/ -name 'CERTIFICADO' -mtime +30`
	if [ ! -z "$baixar" ]; then
		#  " ↓↓↓↓↓↓↓↓↓ ATUALIZANDO OS CERTIFICADOS E LINK DE CARREGAMENTO AUTOMÁTICO NO FIREFOX"
		sh /etc/certgovbr.sh
		sh /etc/baixacertproxy.sh 
		sh /etc/serproass.sh
	fi
	# "↓↓↓↓↓↓↓↓↓ DISPONIBILIZA AO USUARIO FINAL O LINK DOS CERTIFICADOS"
	if [ ! -d /etc/skel/custom/ca-certificates/ ]; then
		ln -s /usr/local/share/ca-certificates/ /etc/skel/custom/
	fi
fi

# Importa e atualiza a coleção de certificados para ser disponibilizados nos navegadores 
update-ca-certificates

# "↓↓↓↓↓↓↓↓↓ RECRIA O LANCADOR DE APPLETS JAVA APOS A ATUALIZAÇÃO, APONTANDO PARA O jre1.8.0_221"
echo "[Desktop Entry]" > /usr/share/applications/icedtea-netx-javaws.desktop
echo "Name=IcedTea Web Start" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "GenericName=Java Web Start" >> /usr/share/applications/icedtea-netx-javaws.desktop 
echo "Comment=IcedTea Application Launcher" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Exec=/usr/local/jre1.8.0_221/bin/javaws %u" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Icon=javaws" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Terminal=false" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Type=Application" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "NoDisplay=true" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Categories=Application;Network;" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "MimeType=application/x-java-jnlp-file;x-scheme-handler/jnlp;x-scheme-handler/jnlps" >> /usr/share/applications/icedtea-netx-javaws.desktop
chmod 644 /usr/share/applications/icedtea-netx-javaws.desktop
chmod +x /usr/share/applications/icedtea-netx-javaws.desktop

# Dispara atualizações de pacotes flatpak
flatpak update -y

# Marcador de atualização final
echo "" >/tmp/$(date +%F_%H%M%S)".fim"

# Habilita o TRIM se o armazenamento é um SSD e ativa os recursos ,noatime,nodiratime,discard no ponto de montagem
DRIVE=`lsblk -no pkname $(findmnt -n / | awk '{ print $2 }')`
if  ! grep "discard" /etc/fstab ; then
	if [ "$(cat /sys/block/$DRIVE/queue/rotational)" = 0 ]; then
		# is "SSD"
		#sed -i 's/errors=remount-ro /errors=remount-ro,noatime,nodiratime,discard /g' /etc/fstab
		#sed -i 's/sw /sw,noatime,nodiratime,discard /g' /etc/fstab
		
		# para os novos SSD é recomendado ativar o TRIM agendado no crontab. Isto pode estar habilitado por padrão
		
		systemctl enable fstrim.timer
		systemctl start fstrim.timer
	fi
fi


