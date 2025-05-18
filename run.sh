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
# Este é o script principal. Prepara o S.O. com foco para uso em ambiente do governo federal do Brasil
# Os scripts em sua maioria são autônomos e podem ser executados no terminal separadamente via sudo su
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
# #-------------------------------------------------------------------------------------------------------------------------------
## Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp

# CAMINHO DA LOCALIZAÇÃO DESTE SCRIPT 
curdir=$PWD

# TESTA SE FOI PASSADO O PARAMETRO
if [ "$#" = "0" ]; then
	clear
	echo "DESCRIPTION"
	echo "		Este script necessita de um dos números abaixo para customizar o seu linux de acordo com os perfis abaixo:"
	echo
	echo " 		1 - doméstico ou escritório móvel"
	echo " 		2 - rede corporativa"
	echo " 		3 - instituições de saúde"
	echo
	echo " 		OPÇOES VÁLIDAS# bash $0 1, bash $0 2 ou bash $0 3"
	echo
	echo "		Nenhum argumento passado na linha de comando. Deixe um espaço e informe  < 1, 2 ou 3 > após# bash $0 "
	exit
fi

# TESTA SE FOI PASSADO ALGUM PARAMETRO INVÁLIDO
if [ "$1" != "1" ] && [ "$1" != "2" ] && [ "$1" != "3" ]; then
	clear
	echo "		Você executou# bash $0 $1 "
	echo 
	echo "		Opção inválida. Opções < 1, 2 ou 3 >"
	exit
fi
echo

# FOI PASSADO ALGUM PARAMETRO VÁLIDO 
if [ "$1" = "1" ]; then
	echo "		->Customização para uso doméstico ou escritório móvel adicionado dos cerficados GOV/ITI com  bash $0 $1"
	cp -f adv.ips om.ips
	cp -f om.ips /etc/om.ips 
elif [ "$1" = "2" ]; then
	echo "		->Customização para uso em rede corporativa adicionado dos cerficados GOV/ITI com  bash $0 $1"
	cp -f gac.ips om.ips
	cp -f om.ips /etc/om.ips 
elif [ "$1" = "3" ]; then
	echo "		->Customização para uso em instituições de saúde adicionado dos cerficados GOV/ITI com  bash $0 $1"
	cp -f hgu.ips om.ips
	cp -f om.ips /etc/om.ips 
fi
echo ; echo "CTRL + C"
echo "		interrompe o script";
echo; echo

#  LISTAGEM DE SOFTWARE DA INSTALAÇÃO ORIGINAL
mkdir -p /etc/skel/custom/
grep -i "install" /var/log/dpkg.log > /etc/skel/custom/lista_software.txt.ori
cp -f cache/* /tmp/

#  ARMAZENA OS SCRIPTS PARA AUDITORIA
zip -v scriptscustom.zip  *.sh *.ips crontab hosts spice zorin* export*  >/dev/null

#if [ ! -f /etc/apt/sourceslist.ori.br ]; then
#	cp -f /etc/apt/sources.list /etc/apt/sourceslist.ori.br
	sed -i 's/br./us./g' /etc/apt/sources.list
#fi
sed -i 's/deb cdrom/#deb cdrom/g' /etc/apt/sources.list

chmod 755 /etc/om.ips 
. /etc/om.ips 
rm -f /tmp/*.deb
. /etc/os-release

UBUNTU_CODENAME_NO_SUPPORT="noble"
VERSION_CODENAME_NO_SUPPORT="xia"
VSO=$VERSION_CODENAME
VSU=$UBUNTU_CODENAME

if [ $VSO = $VERSION_CODENAME_NO_SUPPORT ] || [ $VSU = $UBUNTU_CODENAME_NO_SUPPORT ]; then
	zenity   --warning --text="Suporte de drivers até o UBUNTU 22.04. Aguarde o fabricante fornecer os drivers.\n \n Os scripts ainda não dão suporte ao UBUNTU versão $UBUNTU_CODENAME ou ao LINUXMINT derivado do $VERSION_CODENAME \n \n Revise os seguintes arquivos: aptcacher.sh baixacertproxy.sh cfgwine.sh custom.sh instalakesl.sh\n \n installSDKmenu.sh proxmoxbackupclient.sh safenet.sh scripts4om.sh siscofis.sh tokenGD.sh zorin-tokens-autostart." --width=550 --height=200
	exit
fi

gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/oracle-jdk11-installer.gpg --keyserver keyserver.ubuntu.com --recv-keys EA8CACC073C3DB2A
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-jdk11-installer.gpg] https://ppa.launchpadcontent.net/linuxuprising/java/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/oracle-jdk11-installer.list > /dev/null

sh -x acngonoff.sh
apt purge 
apt update
apt install --assume-yes libappindicator1 openssh-server sshfs xterm
dpkg --configure -a 
apt -f install -y 

# INSTALA O SUPORTE AO FLATPAK E ATIVA O CACHE
if [ -f flatcache.sh ]; then
	sh -x flatcache.sh
fi

curl -fsS https://dl.brave.com/install.sh | sh

# ">>>>>>CONFIGURAÇÃO PARA QUE O SIAFI FUNCIONE NO FIREFOX COM O JAVA CORRETO"
if [ ! -f /usr/local/jre1.8.0_221/release ]; then
	if [ ! -f /tmp/jre-8u221-linux-x64.tar.gz ]; then 
		wget https://javadl.oracle.com/webapps/download/AutoDL?BundleId=239848_230deb18db3e4014bb8e3e8324f81b43 -P /tmp/
		mv /tmp/AutoDL?BundleId=239848_230deb18db3e4014bb8e3e8324f81b43 /tmp/jre-8u221-linux-x64.tar.gz
	fi
	tar -C /usr/local/ -xvzf /tmp/jre-8u221-linux-x64.tar.gz
	if [ -f /usr/share/applications/icedtea-netx-javaws ] && [ ! -f /usr/share/applications/icedtea-netx-javaws.old ]; then
		mv /usr/share/applications/icedtea-netx-javaws.desktop /usr/share/applications/icedtea-netx-javaws.old
	fi
	
	apt-get -y install icedtea-netx
	# cria o lançador para executar APPLETS java. Chamado por aptcacher.sh tambem
	cp -f hookjava1.8.sh /etc/hookjava1.8.sh
	sh -x /etc/hookjava1.8.sh
	
fi

# REMOVE REPOSITORIO SEM CHAVE
if [ -f /etc/apt/sources.list.d/home:PerryWerneck:pw3270.list ]; then
	rm -f /etc/apt/sources.list.d/home:PerryWerneck:pw3270.*
fi

# HABILITA O APT-CACHER-NG CORPORATIVO E ATUALIZA, SE ACESSIVEL OU REMOVE-O SE NÃO
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

# "CUSTOMIZAÇÃO   PREPARATÓRIA"
sh -x custom.sh 

# "REQUISITO PARA ATENDER O ARQUIVAMENTO DIGITAL"
apt install tesseract-ocr tesseract-ocr-por gscan2pdf -y

# "REQUISITO PARA GERENCIAMENTO DE VM EM KVM LINUX REMOTOS"
apt install  ssh-askpass-gnome -y 

dpkg --configure -a
apt -f install -y

#echo oracle-java15-installer shared/accepted-oracle-license-v1-2 select true | /usr/bin/debconf-set-selections
apt-get install --assume-yes openjdk-8-jre-headless icedtea-netx
apt-get install --assume-yes openjdk-11-jre-headless icedtea-netx

# ADICIONA AO path O javaws, PERMITINDO A EXECUÇÃO DE applets java 
VARPATH="export PATH=$PATH:/usr/local/jre1.8.0_221/bin/"
sed -i "3i $VARPATH" /etc/profile

# BAIXA E CARREGA OS CERTIFICADOS ICPBRASIL
if [ -f certgovbr.sh ]; then
	chmod -x certgovbr.sh 
	sh -x certgovbr.sh 
fi

#  BAIXA E CARREGA O CERTIFICADO DO PROXY
if [ -f baixacertproxy.sh ]; then
	chmod +x baixacertproxy.sh
	sh -x baixacertproxy.sh 
fi

# INSTALA O CLIENTE DE BACKUP REMOTO
if [ -f proxmoxbackupclient.sh ]  && [ $site != "https://www.google.com.br" ]; then
	chmod +x proxmoxbackupclient.sh
	sh -x proxmoxbackupclient.sh 
fi

# DESATIVAR AUTOSTART DE APPS NO DESKTOP XFCE PARA USUÁRIO ADMIN
if [ -f /usr/bin/xfce4-session ]; then
	USERADM=`grep '^sudo:.*$' /etc/group | cut -d: -f4`
	echo ">>>>>> Desativa aplicações/extensões iniciados no login do Desktop XFCE"
	echo "[Desktop Entry]" >  /home/$USERADM/.config/autostart/hplip-systray.desktop
	echo "Hidden=true" >>     /home/$USERADM/.config/autostart/hplip-systray.desktop
	echo "[Desktop Entry]" >  /home/$USERADM/.config/autostart/blueman.desktop
	echo "Hidden=true" >>     /home/$USERADM/.config/autostart/blueman.desktop
	echo "[Desktop Entry]" >  /home/$USERADM/.config/autostart/geoclue-demo-agent.desktop
	echo "Hidden=true" >>     /home/$USERADM/.config/autostart/geoclue-demo-agent.desktop
	echo "[Desktop Entry]" >  /home/$USERADM/.config/autostart/com.zorin.desktop.agent-geoclue2-daemon.desktop
	echo "Hidden=true" >>     /home/$USERADM/.config/autostart/com.zorin.desktop.agent-geoclue2-daemon.desktop
	echo '[Desktop Entry]' >  /home/$USERADM/.config/autostart/SACMonitor.desktop
	echo 'Hidden=true' >>     /home/$USERADM/.config/autostart/SACMonitor.desktop
	echo '[Desktop Entry]' >  /home/$USERADM/.config/autostart/xfce4-screensaver.desktop
	echo 'Hidden=true' >>     /home/$USERADM/.config/autostart/xfce4-screensaver.desktop
fi

if [ -d /etc/skel/custom/Templates/ ]; then
	rm -Rf /etc/skel/custom/Templates
fi

nome="warsaw"
pacote=$(dpkg --get-selections | grep "$nome" )
if [ ! -n "$pacote" ]; then
	if [ -f cache/cef.deb ]; then 
		cp -f cache/cef.deb /tmp/cef.deb
	else	
		wget https://cloud.gastecnologia.com.br/cef/warsaw/install/GBPCEFwr64.deb -O /tmp/cef.deb
	fi
	dpkg -i /tmp/cef.deb

	#wget https://cloud.gastecnologia.com.br/bb/downloads/ws/warsaw_setup64.deb  -O /tmp/bb.deb
	# dpkg -i /tmp/bb.deb
fi

apt remove --purge -y
apt full-upgrade -y
dpkg --configure -a
apt-get -f install --yes
fc-cache -f -v

#  AJUSTE CORPORATIVO crontab, hostname, hosts, hosts.deny/allow.
if [  -f scripts4om.sh ]; then
	chmod +x scripts4om.sh
	sh -x scripts4om.sh 
fi
if [ -f cache/setup-deb-64.deb ]; then 
	cp -f cache/setup-deb-64.deb /tmp/setup-deb-64.deb
fi
if [ ! -f /tmp/setup-deb-64.deb ]; then 
	wget https://get.webpkiplugin.com/Downloads/1730900328577/setup-deb-64  -O /tmp/setup-deb-64.deb  
fi

dpkg -i /tmp/setup-deb-64.deb 
apt install brave-browser zorin-connect -y

sh -x TokenDXSafe.sh 

apt autoremove -y
apt clean
apt purge

ls -la /mnt 
umount /mnt 
rm -Rf /mnt/ 
mkdir /mnt/
chmod 755 /mnt/
if [ -d $curdir/cache/ ]; then 
	rm -rf $curdir/cache/
fi

# Redefine as imagens de fundo para o Desktop corporativo substituindo o padrão
# Renomeia as imagens originais e copia uma nova imagem com o nome da original em /usr/share/gnome-background-properties/ 
# Mantem as definições de /usr/share/gnome-background-properties/zorin-default-wallpapers.xml
if [ -f Fundo.jpg ] && [ ! -f /usr/share/backgrounds/Zorinori.jpg ]; then
	mv -f /usr/share/backgrounds/Zorin.jpg /usr/share/backgrounds/Zorinori.jpg
	mv -f Fundo.jpg /usr/share/backgrounds/Zorin.jpg
fi
if [ -f Fundo-Dark.jpg ] && [ ! -f /usr/share/backgrounds/Zorin-Darkori.jpg ]; then
	mv -f /usr/share/backgrounds/Zorin-Dark.jpg /usr/share/backgrounds/Zorin-Darkori.jpg
	cp Zorin.jpg /usr/share/backgrounds/Zorin-Dark.jpg
fi

cp -f scriptscustom.zip /etc/skel/custom/scriptscustom
rm -f scriptscustom.zip

# "↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓LISTA DE PACOTES PARA AUDITORIA FUTURA↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓"
grep -i "install" /var/log/dpkg.log > /etc/skel/custom/list_softw_script.txt.custom


flatpak uninstall --unused -y

if [ -f /etc/apt/apt.conf.d/00aptproxy ]; then
	rm -f /etc/apt/apt.conf.d/00aptproxy
fi

