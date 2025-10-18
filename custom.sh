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
# Script de customização original.
#--------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#  1- Este é o script principal acionado por run.sh e deve ser executado após a instalação do S.O. com as devidas atualizações e alterações caso a caso;
#  2- Da execução do conjunto de scripts é possível gerar uma IMAGEM DA CUSTOMIZAÇÃO DO SO atualizada para replicação;
#  3- Consulte links na internet para gerar uma imagem via Clonezilla;
#     - Adotou-se o CLONEZILLA para gerar imagens do SO customizado e gravados num repositório para replicações;
#     - A VM deve ser provisionada com um HD de 74 GiB (formatado será 80 GB);
#     - Para usar o KVM-Linux e provisionar THIN STORAGEs com tamanho fixo veja:
#       https://serverfault.com/questions/731417/how-do-you-create-a-qcow2-file-that-is-small-yet-commodious-on-a-linux-server
#  4- Aplicações corporativas podem ser incluidas condicionalmente através de outros scripts;
#  Coletânea de scripts disponiveis em https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
#  Execute no terminal como root #./run.sh  1 para uso domestico ou #sh +x run.sh 3 para uso corporativo

# "#########                             DEFINIÇÃO de VARIAVEIS da CUSTOMIZAÇÃO e dos ENDEREÇOS IP ESPECIFICOS"
# "↓↓↓↓↓↓↓↓↓ ATENÇÃO         TODOS SCRIPTS DEVEM ESTAR ARMAZENADOS NA PASTA DO USUARIO administrador "
curdir=$PWD
#echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"

# carrega variaveis especificas do S.O.
. /etc/os-release

# carrega variaveis especificas do PERFIL da LAN
if [ ! -f /etc/om.ips  ]; then
	cp -f om.ips /etc/om.ips 
	chmod 755 /etc/om.ips 
fi
. /etc/om.ips 

# CRIA A PASTA PARA ARQUIVAR CÓPIAS DOS SCRIPTS EM /etc/skel/custom, JUNTAMENTE COM A LISTA PRÉ E PÓS EXECUÇÃO, PARA AUDITORIA"
if [ -d /etc/skel/custom/ ]; then
	rm -Rf /etc/skel/custom/
fi
mkdir  /etc/skel/custom/
cd /tmp

#  ADICIONA A ARQUITETURA 32BITS PARA A FUNCIONAMENTO DO WINE
dpkg --add-architecture i386

nome="recoll-backports/recoll-1.15-on"
add-apt-repository ppa:$nome -y

# HABILITA RESPOSTA PARA A INSTALAÇÃO AUTOMÁTICA DE NOVAS FONTES TRUETYPE
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

apt-get reinstall fwupd -y

# ATUALIZA O SISTEMA OPERACIONAL
apt update && apt full-upgrade -y ; apt --fix-broken install -y; apt autoremove -y

# REMOVE O ACNG PARA IMPORTAÇÃO DAS CHAVES SEM O PROXY  
if [ -f /etc/apt/apt.conf.d/00aptproxy ]; then
	rm -f /etc/apt/apt.conf.d/00aptproxy
fi

# " INSTALA E TRAVA A VERSÃO wine-stable=4.0.4 PARA APLICAÇÕES CORPORATIVAS LEGADAS NO ZORIN OS"
VerWine=`wine --version`
if [ "$VerWine" != "wine-4.0.4" ] && [ ! -z "$siscofis" ] &&  [ "$PRETTY_NAME" = "Zorin OS 16.3" ] ; then
	wget -qO- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
	wget -nc https://dl.winehq.org/wine-builds/winehq.key
	mv -f winehq.key /usr/share/keyrings/winehq-archive.key
	apt remove wine* -y
	apt-add-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'; apt update
	apt install winehq-stable=4.0.4~focal wine-stable=4.0.4~focal wine-stable-amd64=4.0.4~focal wine-stable-i386:i386=4.0.4~focal -y
	apt-mark hold winehq-stable wine-stable wine-stable-amd64 wine-stable-i386:i386
	apt-get install --assume-yes winetricks
fi

# REATIVA O ACNG PÓS IMPORTAÇÃO DAS CHAVES  
if [ ! -f /etc/apt/apt.conf.d/00aptproxy ]; then
	sh -x $curdir/acngonoff.sh 
fi


# REATUALIZA O SISTEMA OPERACIONAL COM O ACNG
apt update && apt full-upgrade -y ; apt --fix-broken install -y; apt autoremove -y

# "↓↓↓↓↓↓↓↓↓ CUSTOMIZAÇÃO PARA ADEQUAÇÃO ÀS EXIGENCIAS DAS POLITICAS DE SEGURANÇA  #### REMOVER APLICAÇÕES CONTRAPRODUCENTES OU DE ALTO RISCO"

# "↓↓↓↓↓↓↓↓↓ RECURSOS PARA GERENCIAMENTO DE IMPRESSORAS HP. IMPRESSORAS ANTIGAS NECESSITAM LIGAÇÃO DIRETA A INTERNET"
apt install hplip hplip-gui hplip-data hplip-doc hpijs-ppds libsane-hpaio printer-driver-hpcups printer-driver-hpijs -y
# https://www.lojamundi.com.br/download/servidor-de-impressao-cups-com-cubieboard2/servidor-de-impressao-cups-com-cubieboard2.pdf

# "↓↓↓↓↓↓↓↓↓ ALGUMAS IMPRESSORAS BROTHERS E HP ANTIGAS NECESSITAM LIGAÇÃO DIRETA A INTERNET"
# "↓↓↓↓↓↓↓↓↓  BAIXE E DESCOMPRIMA LINUX-BRPRINTER-INSTALLER-2.X.Y-Z.GZ EM /TMP E EXECUTE A LINHA ABAIXO NO TERMINAL O MODELO ESPECIFICO"
# "↓↓↓↓↓↓↓↓↓ REQUISITOS PARA O DRIVER DAS IMPRESSORAS BROTHER"
apt-get install  --assume-yes lib32gcc1 lib32stdc++6 libc6-i386 libusb-0.1-4
# https://support.brother.com/g/b/downloadend.aspx?c=us&lang=en&prod=hll2300d_us_eu_as&os=128&dlid=dlf006893_000&flang=4&type3=625
# lembrete para intalação de impressoras brother
# bash linux-brprinter-installer-2.x.y-z MFC-J880DW ou DCP-8085DN ou MFC-L6702DW

#requisitos gerenciamento de impressoras EPSON. ver http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX
# INSTALAR IMPRESSORAS EPSONS COM DRIVER epson-inkjet-printer-escpr 
# ATUALIZAR O FIRMWARE DAS IMPRESSORA PARA QUE ARQUIVOS COLORIDOS E PDF SEJAM IMPRESSOS CORRETAMENTE"
# https://download.ebz.epson.net/dsc/search/01/search/searchModule
apt-get install lsb -y

apt install libcupsimage2 -y
apt-key adv --keyserver.ubuntu.com --recv-keys 8AA65D56

nome="epson-inkjet-printer-escpr"
pacote=$(dpkg --get-selections | grep "$nome" )
if [ ! -n "$pacote" ]; then
	rm -f /tmp/epsonscan2-bundle.tar.gz
	if [  -f /tmp/cache/epsonscan2-bundle.tar.gz ]; then 
		cp -f /tmp/cache/epsonscan2-bundle.tar.gz /tmp/epsonscan2-bundle.tar.gz
	else
		wget https://download3.ebz.epson.net/dsc/f/03/00/16/14/38/7b1780ace96e2c6033bbb667c7f3ed281e4e9f38/epsonscan2-bundle-6.7.70.0.x86_64.deb.tar.gz -P /tmp/ -O /tmp/epsonscan2-bundle.tar.gz
	fi
	if [  -f /tmp/cache/epson-inkjet-printer-escpr.deb ]; then 
		cp -f /tmp/cache/epson-inkjet-printer-escpr.deb /tmp/epson-inkjet-printer-escpr.deb
	else
		wget https://download3.ebz.epson.net/dsc/f/03/00/16/65/04/32d8b35d3868ac14fe4f67e297e6ddf5aa2e27cf/epson-inkjet-printer-escpr2_1.2.26-1_amd64.deb -P /tmp/ -O /tmp/epson-inkjet-printer-escpr.deb
	fi

	if [  -f /tmp/cache/epson-printer-utility_1.1.3-1_amd64.deb ]; then 
		cp -f /tmp/cache/epson-printer-utility_1.1.3-1_amd64.deb /tmp/epson-printer-utility_1.1.3-1_amd64.deb
	else
		wget https://download3.ebz.epson.net/dsc/f/03/00/15/43/23/b85f4cf2956db3dd768468b418b964045c047b2c/epson-printer-utility_1.1.3-1_amd64.deb -P /tmp/ -O /tmp/epson-printer-utility_1.1.3-1_amd64.deb
	fi

	dpkg -i /tmp/epson-*.deb
	apt-get -f install -y
	tar -xvzf  /tmp/epsonscan2-bundle.tar.gz -C /tmp/
	# NOME DO PACOTE EXTRAÍDO
	NAMEE='epsonscan2-bundle-6.7.70.0.x86_64.deb'
	mv /tmp/${NAMEE} /tmp/epsonscan2-bundle
	cd /tmp/epsonscan2-bundle
	sh ./install.sh
	apt-get -f install -y
	cd /tmp
	rm -f /tmp/epson-*.deb
	rm -rdf /tmp/epsonscan2-bundle/*
fi

# "↓↓↓↓↓↓↓↓↓ FERRAMENTAS PRE-CUSTOM"
apt-get install flatpak -y
apt-get install --assume-yes unrar rar unace p7zip p7zip-full python3-pyudev

# " UTILITÁRIOS DE APOIO A ESCANEAMENTO E ARQUIVAMENTO DIGITAL"
apt-get install --assume-yes pdfsam simple-scan tesseract-ocr tesseract-ocr-por -y
#apt-get install --assume-yes gimagereader imagemagick  
# "↓↓↓↓↓↓↓↓↓ UTILITÁRIO DE LOCALIZAR PARTES DE UM TEXTO"
apt-get install --assume-yes recoll
# "↓↓↓↓↓↓↓↓↓ apoio aos serviços de impressão e arquivos na rede Windows"
apt-get install --assume-yes python3-smbc
# "↓↓↓↓↓↓↓↓↓ Checagem de arquivos"
apt-get install --assume-yes meld
# "↓↓↓↓↓↓↓↓↓ CAMADA DE APOIO AOS TOKENS"
apt-get install --assume-yes libccid pcscd libpcsclite1 pcsc-tools seahorse
# "↓↓↓↓↓↓↓↓↓ FERRAMENTAS ESPECIAIS PARA O ADMINISTRADOR"
apt-get install --assume-yes git python3-pip python3-wxgtk4.0 grub2-common grub-pc-bin
# "↓↓↓↓↓↓↓↓↓ UTILITÁRIO DE PARTICIONAMENTO"
apt-get install --assume-yes gparted
# "↓↓↓↓↓↓↓↓↓ UTILITÁRIO DE VISUALIZAÇÃO DO HW"
apt-get install --assume-yes hardinfo
# "↓↓↓↓↓↓↓↓↓ DRIVERS DO ANDROID, IMPRESSORAS e IOS"
apt-get install --assume-yes adb printer-driver-cups-pdf ideviceinstaller libimobiledevice-utils  ifuse usbmuxd uxplay
# "↓↓↓↓↓↓↓↓↓ FERRAMENTA DE SEGURANCA PARA A ESTACAO"
apt-get install --assume-yes fail2ban
# "↓↓↓↓↓↓↓↓↓ ferramentas para uso de backup externo"
apt-get install --assume-yes openssh-server sshfs
# "↓↓↓↓↓↓↓↓↓ MONITORAMENTO DO HD"
rm -f /etc/default/smartmontools
apt-get install --assume-yes  gsmartcontrol smart-notifier
# "↓↓↓↓↓↓↓↓↓ INSTALA O KVM-LINUX PARA SUPORTAR A VIRTUALIZAÇÃO"
# apt-get install --assume-yes qemu-system-x86-64 qemu qemu-kvm qemu-utils virt-manager virt-viewer libvirt-daemon spice-vdagent spice-webdavd

# "↓↓↓↓↓↓↓↓↓ INSTALA/ATUALIZA/REMOVE PACOTES PREVIAMENTE BAIXADOS"
apt remove parole -y
apt-get autoremove -y
if [  -f /tmp/*.deb ]; then 
	dpkg -i --force-all /tmp/*.deb
fi
apt-get -f install --yes
apt-get --fix-broken install
apt-get -f install --yes
dpkg --configure -a

# "↓↓↓↓↓↓↓↓↓ RECURSOS INCORPORADOS A PEDIDO PARA USO NO LIBREOFFICE"
if [ ! -f /usr/lib/libreoffice/share/wordbook/Quimica.dic ]; then
   wget https://wiki.documentfoundation.org/images/d/db/Quimica.zip -P /tmp/
   unzip -qo /tmp/Quimica.zip -d /usr/lib/libreoffice/share/wordbook/
fi
if [ ! -f /usr/lib/libreoffice/share/wordbook/militar.dic ]; then
   wget https://wiki.documentfoundation.org/images/3/3a/Militar.zip -P /tmp/
   unzip -o /tmp/Militar.zip -d /usr/lib/libreoffice/share/wordbook/
fi
if [ ! -f /usr/lib/libreoffice/share/wordbook/Microbiologia.dic ]; then
   wget https://wiki.documentfoundation.org/images/f/f1/Microbiologia.zip -P /tmp/
   unzip -o /tmp/Microbiologia.zip -d /usr/lib/libreoffice/share/wordbook/
fi
if [ ! -f /usr/lib/libreoffice/share/wordbook/DicEletro.dic ]; then
   wget https://wiki.documentfoundation.org/images/a/a2/DicEletro.zip -P /tmp/
   unzip -o /tmp/DicEletro.zip -d /usr/lib/libreoffice/share/wordbook/
fi
if [ ! -f /usr/lib/libreoffice/share/wordbook/DicJuridico.dic ]; then
   wget https://wiki.documentfoundation.org/images/6/65/DicJuridico.zip -P /tmp/
   unzip -o /tmp/DicJuridico.zip -d /usr/lib/libreoffice/share/wordbook/
fi

# "↓↓↓↓↓↓↓↓↓ CONFIGURA O SMARTMONTOOLS PARA MONITORAMENTO DO SDA E SDB "
echo 'enable_smart="/dev/sda /dev/sdb"' > /etc/default/smartmontools
echo 'start_smartd=yes' >> /etc/default/smartmontools
echo 'smartd_opts="--interval=7200"' >> /etc/default/smartmontools

# "↓↓↓↓↓↓↓↓↓ Desativa a descoberta e instalação automática de impressoras de rede"
sed -i 's/BrowseLocalProtocols dnssd/BrowseLocalProtocols none/g'        /etc/cups/cups-browsed.conf
sed -i 's/BrowseLocalProtocols dnssd/BrowseLocalProtocols none/g'        /etc/cups/cupsd.conf
sed -i 's/BrowseRemoteProtocols dnssd/BrowseRemoteProtocols none/g'      /etc/cups/cups-browsed.conf
sed -i 's/# BrowseLocalProtocols /BrowseLocalProtocols /g'                /etc/cups/cups-browsed.conf
sed -i 's/Browsing On/Browsing Off/g'                                     /etc/cups/cupsd.conf

# "↓↓↓↓↓↓↓↓↓  DEPENDENCIAS DO ENDPOINT"
apt-get install --assume-yes libfontconfig1 libfreetype6 libice6 libsm6 libx11-6 libx11-xcb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render0 libxcb-render-util0 libxcb-shape0 libxcb-shm0 libxcb1 libxcb-sync1 libxcb-xfixes0 libxcb-xkb1 libxi6 libxml2 libxcb-xinerama0 wget

# "↓↓↓↓↓↓↓↓↓ A SEÇÃO ABAIXO CRIA UM SCRIPT PARA REABILITAR IMPRESSORAS PAUSADAS VIA INSERÇÃO DE UM JOB NO /ETC/CRONTAB"
if [ ! -f /etc/enableprinter.sh ]; then
	echo "#!/bin/bash" >  /etc/enableprinter.sh
	echo "enable_cmd="'`'"whereis -b cupsenable | awk '{ print "'$2'" }'"'`'  >> /etc/enableprinter.sh
	echo "DISABLED="'"''$(lpstat -t | awk ' "'"'/desabilitada/ { print '""'$2'"" "}')"'"' >> /etc/enableprinter.sh
	echo "for PRINT in "'$DISABLED'"; do" >> /etc/enableprinter.sh
	echo "	control=1" >> /etc/enableprinter.sh
	echo "	"'$enable_cmd $PRINT' >> /etc/enableprinter.sh
	echo "done;" >> /etc/enableprinter.sh
	chmod +x /etc/enableprinter.sh
	echo '#' >> /etc/crontab

	echo '#Reabilita impressoras pausadas a cada 5 minutos' >> /etc/crontab
	echo '*/5 * * * * root  /etc/enableprinter.sh' >> /etc/crontab
	echo '#' >> /etc/crontab
	
	echo '# busca as atualizações 1h depos do boot no provedor' >> /etc/crontab
	echo '@reboot root /bin/sleep 600 && sh /etc/aptcacher.sh' >> /etc/crontab
	echo '#'  >> /etc/crontab

	echo '# O aptcacher.sh baixa tudo. A cada 2d, as 12:20 executa o upgrade para minimizar falhas durante o boot, reboot ou reset ' >> /etc/crontab
	echo '20 12 */2 * * root apt update && apt full-upgrade -y && dpkg --configure -a && apt-get autoremove -y && apt clean && bash /etc/hookjava1.8.sh' >> /etc/crontab
	echo '#'  >> /etc/crontab

	echo '# A cada 63 dias é realizado uma limpeza do sistema' >> /etc/crontab
	echo '40 12 */63 * * root /etc/clean.sh' >> /etc/crontab
fi

# "↓↓↓↓↓↓↓↓↓ REMOVENDO ARQUIVOS DESNECESSÁRIOS..."
rm -f /etc/skel/*.1
rm -f /etc/skel/*.2
rm -f /etc/skel/custom/*.1
rm -f /etc/skel/custom/*.2

nome="vlc"
pacote=$(dpkg --get-selections | grep "$nome" )
if [ ! -n "$pacote" ]; then
	apt install --install-recommends vlc -y
fi

# Identifica se o pacote  esta em cache. Se não busca na internet para instalar ou atualizar
if [  -f /tmp/cache/bleachbit*.deb ]; then 
	cp -f /tmp/cache/bleachbit*.deb /tmp/bleachbit*.deb
else
	# Variável que define a versão do sistema operacional a partir da variavel de ambiente 
	VSO=$VERSION_CODENAME
	
	if [ $VSO = "bullseye" ]; then
		wget https://download.bleachbit.org/bleachbit_5.0.0-0_all_debian11.deb -P /tmp/
	fi
	if [ $VSO = "bionic" ] || [ $VSO = "focal" ] || [ $VSO = "una" ] || [ $VSO = "elsie" ]; then
		wget https://download.bleachbit.org/bleachbit_5.0.0-0_all_ubuntu2004.deb -P /tmp/
	fi
	if [ $VSO = "jammy" ] || [ $VSO = "victoria" ] || [ $VSO = "faye" ] || [ $VSO = "virginia" ]; then
		wget https://download.bleachbit.org/bleachbit_5.0.0-0_all_ubuntu2204.deb  -P /tmp/
	fi
	if [ $VSO = "bookworm" ]; then
		wget https://download.bleachbit.org/bleachbit_5.0.0-0_all_debian12.deb -P /tmp/
	fi
fi
dpkg -i --force-all /tmp/bleachbit*.deb
rm /tmp/bleachbit*.deb

# https://www.vivaolinux.com.br/topico/Sed-Awk-ER-Manipulacao-de-Textos-Strings/Como-inserir-um-texto-num-lugar-especifico-de-um-aquivo-pela-linha-de-comando
# APLICA-SE SOMENTE AO SERVIDOR PULSE AUDIO. É IGNORADO NOUTRAS SERVIDORES DE SOM
if [ ! -f /etc/pulse/default.pa.bak ]; then
	cp -f /etc/pulse/default.pa /etc/pulse/default.pa.bak
	sed -i '/load-module module-filter-apply/a load-module module-echo-cancel aec_args="analog_gain_control=0 digital_gain_control=0" source_name=noiseless' /etc/pulse/default.pa
	sed -i '/#set-default-source input/a set-default-source noiseless' /etc/pulse/default.pa
fi

dpkg --configure -a
apt -f install -y
apt autoremove -y
exit

# NOTAS DIVERSAS
# Para sincronizar todos os arquivos da pasta /home/confdoc/ de uma estação remota com o IP 192.168.1.111
# Execute o comando abaixo no shell da estação com o novo HD, logado no usuário que será proprietário dos arquivos.
#O ARGUMENTO PASTA DE ORIGEM  NO MEIO  DA LINHA DE COMANDO DEVE TER A "/" COMO ÚLTIMO CARACTERE
#O ARGUMENTO PASTA DE DESTINO NO FINAL DA LINHA DE COMANDO NÃO DEVE TERMINAR SEM A "/"
####rsync -avz ubuntu@192.168.1.111:/home/ubuntu/ /home/novousuariofinal

# Execute o comando abaixo no terminal da estação antiga para enviar todo o conteúdo da pasta do usuário antigo para o novo HD em uma estação remota
#O ARGUMENTO PASTA DE ORIGEM  NO MEIO  DA LINHA DE COMANDO DEVE TER A "/" COMO ÚLTIMO CARACTERE
#O ARGUMENTO PASTA DE DESTINO NO FINAL DA LINHA DE COMANDO NÃO DEVE TERMINAR SEM A "/"
####rsync -avz /home/antigousuariofinal/ novousuariofinal@10.0.0.10:/home/novousuariofinal

# Para descobrir se a CPU tem suporte a virtualização, independente da BIOS
####grep --color -E "vmx|svm" /proc/cpuinfo

#lista se o pacote vlc esta instalado via snap
#snap list | grep "vlc"

# LIMPEZA DO CACHE NO USUARIO LOGADO
####find ~/.cache/thumbnails -type f -name "*.png" -exec shred -f -u -z -n 1 {} \;

#Isso excluirá tudo em seu .cache que foi acessado pela última vez há mais de um ano
####find ~/.cache/ -type f -atime +365 -delete

#fornecer uma lista com os tamanhos de cada pasta em .cache
####du ~/.cache > cachefolders_size
####du -h -s --one-file-system $dir/* $dir/.[A-Za-z0-9]* | sort -rn | head
####du -h -s  /home/*  | sort -rn | head
#https://askubuntu.com/questions/102046/is-it-okay-to-delete-the-cache-folder

####rdfind -dryrun true -makehardlinks true ./

# criar o storage para a VM KVM em modelo de thin provisioning, ou uso conforme demanda similar ao modelo VDI
####qemu-img create -f qcow2 vm/vm`date +%s`.qcow2 74G

# criação de VM com suporte UEFI. Também pode ser criado um modelo no gerenciador de VM, marcar para editar o hardware e alterar de BIOS para UEFI.
####sudo virt-install --name UBUNTU --os-type=Linux --os-variant=archlinux --vcpu=2  --ram=4096  --disk path=/home/useradm/kvm/Artix.img,size=1 --graphics spice  --network network=default --boot uefi

# comando systemd-analyze pode ser usado para determinar estatísticas de desempenho de inicialização do sistema
####sudo systemd-analyze critical-chain

#  Mostrar quais unidades levaram mais tempo durante a inicialização
####sudo systemd-analyze blame

#listagem de usuarios 
####while IFS=: read -r f1 f2 f3 f4 f5 f6 f7
####do
	####if [ $f3 -gt "999" ] && [ $f3 -lt "2000"  ]; then
	####	echo $f1
	####fi
####done < /etc/passwd
