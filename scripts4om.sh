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
#    PARTE INTEGRANTE DO SCRIPT CUSTOM.SH. CARACTERIZA A INSTALAÇÃO PARA AS ESPECIFICAÇÕES  
#        DE USO ORGANIZACIONAL CORPORATIVO BASEADO NAS INFORMAÇÕES DO ARQUIVO om.ips
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
#| echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"
#  CARREGA VARIAVEIS DO SO 
. /etc/os-release
curdir=$PWD
cp -f om.ips /etc/om.ips 
chmod 755 /etc/om.ips 

# Variável que define a versão do sistema operacional a partir da variavel de ambiente 
VSO=$VERSION_CODENAME

# carrega variaveis especificas do PERFIL da LAN
if [ ! -f /etc/om.ips  ]; then
	cp -f om.ips /etc/om.ips
	chmod 755 /etc/om.ips
fi
. /etc/om.ips

if [ ! -f /etc/skel/CARREGAdriverTOKEN.sh ]; then
	cp -f CARREGAdriverTOKEN.sh /etc/skel/CARREGAdriverTOKEN.sh
fi

if [ -f /usr/bin/xfce4-session ]; then
	# "↓↓↓↓↓↓↓↓↓ DEFINE AS CONFIG PADRONIZADA PARA NOVOS USUARIOS"
	mkdir -p /etc/skel/.config/
	mkdir -p /etc/skel/.config/xfce4/
	mkdir -p /etc/skel/.config/xfce4/xfconf/
	mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
fi

# "↓↓↓↓↓↓↓↓↓ REPROGRAMA A CONFIGURAÇÃO PADRONIZADA DO DESKTOP XFCE PARA AMBIENTE CORPORATIVO"
if [ ! -f /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml ]  && [ -f /usr/bin/xfce4-session ]; then
	echo '<?xml version="1.0" encoding="UTF-8"?>' > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '<channel name="xfce4-power-manager" version="1.0">' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '  <property name="xfce4-power-manager" type="empty">' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="power-button-action" type="uint" value="3"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="lock-screen-suspend-hibernate" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="logind-handle-lid-switch" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="blank-on-ac" type="int" value="0"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="blank-on-battery" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="dpms-enabled" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="dpms-on-ac-sleep" type="uint" value="0"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="dpms-on-ac-off" type="uint" value="15"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="dpms-on-battery-sleep" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="dpms-on-battery-off" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="show-panel-label" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="inactivity-sleep-mode-on-ac" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="inactivity-sleep-mode-on-battery" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="lid-action-on-ac" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="lid-action-on-battery" type="empty"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="show-tray-icon" type="bool" value="false"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="presentation-mode" type="bool" value="false"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="brightness-switch-restore-on-exit" type="int" value="1"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '    <property name="brightness-switch" type="int" value="0"/>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '  </property>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	echo '</channel>' >> /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
	chmod 755 /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
fi

# "↓↓↓↓↓↓↓↓↓ APLICA CONFIGURAÇÕES ESPECIAIS DE SEGURANÇA, SFC"
echo "localhost" > /etc/hostname
grep -v "sshd" /etc/hosts.allow > /tmp/tmphostfile && mv /tmp/tmphostfile /etc/hosts.allow
grep -v "sshd" /etc/hosts.deny > /tmp/tmphostfile && mv /tmp/tmphostfile /etc/hosts.deny
echo "$hostsallow0" >> /etc/hosts.allow
echo "$hostsallow1" >> /etc/hosts.allow
echo "$hostsallow2" >> /etc/hosts.allow
echo "$hostsallow3" >> /etc/hosts.allow
echo "$hostsdeny" >> /etc/hosts.deny

# Ativa as ferramentas do perfil corporativo
# recupera o nome do usuario administrador
USERADM=`grep '^sudo:.*$' /etc/group | cut -d: -f4`
if [ ! -f /home/$USERADM/"Área de Trabalho"/7-AdicionanovousuarioComum.pdf ]; then 
	mkdir -p /etc/skel/"Área de Trabalho"/
fi
cp -f *.pdf /home/$USERADM/"Área de Trabalho"/  
chattr +i   /home/$USERADM/"Área de Trabalho"/*.pdf
cp -f /tmp/cache/*.png /home/$USERADM/"Área de Trabalho"/  
chattr +i   /home/$USERADM/"Área de Trabalho"/Ass*.png

if [ ! -z "$siscofis" ]; then
	if [ ! -f /etc/antivirus.tar ]; then
		# COPIA A SOLUÇÃO DE SEGURANÇA CORPORATIVA PARA INSTALAÇÃO AUTOMATICA 
		if [ -f /home/$USERADM/KSEzorin.sh ] || [ -f /tmp/cache/antivirus.tar ]; then
			cp -f /tmp/cache/antivirus.tar /etc/
			cp -f /home/$USERADM/KSEzorin.sh /etc/
			chmod +x /etc/KSEzorin.sh
		fi
	fi
 	rm -rf /home/$USERADM/.var/*; rm -rf /home/$USERADM/.weasis/*

	# "↓↓↓↓↓↓↓↓↓ COPIA O SCRIPT spice QUE ABRE DESKTOPS REMOTOS OBTIDO EM HTTPS://GITLAB.COM/-/SNIPPETS/32412"
	cp -f spice /bin/spice
	chmod 755 /bin/spice
	chmod +x /bin/spice

	echo "America/Belem" > /etc/timezone

	apt install curl wget -y
	apt-get install gnupg2  -y	
else
	rm -f /bin/spice
	chattr -i /home/$USERADM/"Área de Trabalho"/*.pdf
	rm -f /home/$USERADM/"Área de Trabalho"/*.pdf
	cp -f LeiaMe.pdf /etc/skel/"Área de Trabalho"/LeiaMe.pdf
	chattr +i        /etc/skel/"Área de Trabalho"/LeiaMe.pdf
	cp -f LeiaMe.pdf /home/$USERADM/"Área de Trabalho"/LeiaMe.pdf
	chattr +i        /home/$USERADM/"Área de Trabalho"/LeiaMe.pdf
	if [ -f /etc/antivirus.tar ]; then
		rm -f /etc/siscofis.sh
		rm -f /etc/cfgwine.sh
		rm -f /etc/KSEzorin.sh
		rm -f /etc/antivirus.tar
		rm -f /usr/share/applications/SIGH.desktop
		rm -f /usr/share/applications/SiscofisOM.desktop
	fi
fi

if [ -f /usr/bin/xfce4-session ]; then
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/blueman.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/blueman.desktop
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/com.zorin.desktop.agent-geoclue2-daemon.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/com.zorin.desktop.agent-geoclue2-daemon.desktop
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/geoclue-demo-agent.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/geoclue-demo-agent.desktop
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/hplip-systray.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/hplip-systray.desktop
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/SACMonitor.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/SACMonitor.desktop
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/xfce4-screensaver.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/xfce4-screensaver.desktop
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/hplip-systray.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/hplip-systray.desktop
	echo '[Desktop Entry]' > /etc/skel/.config/autostart/SACMonitor.desktop
	echo 'Hidden=true'    >> /etc/skel/.config/autostart/SACMonitor.desktop
fi

# "↓↓↓↓↓↓↓↓↓ COPIA E/OU EXECUÇÃO DOS ARQUIVOS PARA /ETC"

cp -f aptcacher.sh /etc/aptcacher.sh
chmod 755 /etc/aptcacher.sh
chmod +x /etc/aptcacher.sh

cp -f serproass.sh /etc/serproass.sh
chmod 755 /etc/serproass.sh
chmod +x /etc/serproass.sh

cp -f clean.sh /etc/clean.sh
chmod 755 /etc/clean.sh
chmod +x clean.sh

cp -f baixacertproxy.sh  /etc/baixacertproxy.sh
chmod 755 /etc/baixacertproxy.sh
chmod +x /etc/baixacertproxy.sh

cp -f firefox-stable.sh /etc/firefox-stable.sh
chmod 755 /etc/firefox-stable.sh
chmod +x /etc/firefox-stable.sh
sh -x firefox-stable.sh 

cp -f latest-firefoxesr.sh /etc/latest-firefoxesr.sh
chmod 755 /etc/latest-firefoxesr.sh
chmod +x /etc/latest-firefoxesr.sh
sh -x /etc/latest-firefoxesr.sh 
if [ ! -d /opt/firefox/ ]; then
	sleep 60
	sh -x /etc/latest-firefoxesr.sh 
fi

# " APLICA A PERSONALIZAÇÃO CORPORATIVA AO MOZILLA STANDARD, se a variável site diferente de https://www.google.com.br"
# ver https://www.codeproject.com/Tips/5356799/How-to-Place-Mozilla-Firefox-Browser-under-Lockdow
#if [ $site != "https://www.google.com.br" ]; then
#	if [ ! -d /usr/lib/firefox/distribution/ ]; then
#						       mkdir /usr/lib/firefox/distribution/
#	else
#						       rm -f /usr/lib/firefox/distribution/policies.json
#	fi
#	echo "{"                                           > /usr/lib/firefox/distribution/policies.json
#	echo '  "policies": {'                            >> /usr/lib/firefox/distribution/policies.json
#	echo '    "Homepage": {'                          >> /usr/lib/firefox/distribution/policies.json
#	echo '      "StartPage": "homepage",'             >> /usr/lib/firefox/distribution/policies.json
#	echo '      "URL": "'$site'"'                     >> /usr/lib/firefox/distribution/policies.json
#	echo '    },'                                     >> /usr/lib/firefox/distribution/policies.json
#	echo '    "Proxy": {'                             >> /usr/lib/firefox/distribution/policies.json
#	echo '      "AutoConfigURL": "'$proxyct'",'       >> /usr/lib/firefox/distribution/policies.json
#	echo '      "AutoLogin": true,'                   >> /usr/lib/firefox/distribution/policies.json
#	echo '      "SOCKSVersion": 4,'                   >> /usr/lib/firefox/distribution/policies.json
#	echo '      "Mode": "none",'                      >> /usr/lib/firefox/distribution/policies.json
#	echo '      "UseHTTPProxyForAllProtocols": true,' >> /usr/lib/firefox/distribution/policies.json
#	echo '      "UseProxyForDNS": false'              >> /usr/lib/firefox/distribution/policies.json
#	echo '    },'                                     >> /usr/lib/firefox/distribution/policies.json
#	echo '      "browser.sessionstore.interval": { '  >> /usr/lib/firefox/distribution/policies.json
#	echo '        "Value": "3600000"'                 >> /usr/lib/firefox/distribution/policies.json
#	echo '      },'                                   >> /usr/lib/firefox/distribution/policies.json
#	echo '    "Certificates": '                       >> /usr/lib/firefox/distribution/policies.json
#	echo '     { '                                    >> /usr/lib/firefox/distribution/policies.json
#	echo '     "ImportEnterpriseRoots": true '        >> /usr/lib/firefox/distribution/policies.json
#	echo '     }, '                                   >> /usr/lib/firefox/distribution/policies.json
#	echo '    "RequestedLocales": ['                  >> /usr/lib/firefox/distribution/policies.json
#	echo '      "",'                                  >> /usr/lib/firefox/distribution/policies.json
#	echo '      "pt-BR"'                              >> /usr/lib/firefox/distribution/policies.json
#	echo '    ]'                                      >> /usr/lib/firefox/distribution/policies.json
#	echo '  }'                                        >> /usr/lib/firefox/distribution/policies.json
#	echo '}'                                          >> /usr/lib/firefox/distribution/policies.json
#						   chmod 755 /usr/lib/firefox/distribution/policies.json
#fi
#              APLICA A CONFIGURAÇÃO ACIMA PARA O FIREFOX ATUALIZADO VIA BINARIO QUE SUBSTITUI A VERSÃO SNAP PADRÃO QUE IMPEDE A CUSTOMIZAÇÃO 
#if [ -d /OPT/firefox/distribution/ ]; then
#	ln -sf /usr/lib/firefox/distribution/policies.json /OPT/firefox/distribution/
#fi

if [ ! -z "$siscofis" ]; then
	# Cria o lançador de execução SISCOFIS
	echo '[Desktop Entry]' > /usr/share/applications/SiscofisOM.desktop
	echo 'Name=SiscofisOM' >> /usr/share/applications/SiscofisOM.desktop
	echo 'Exec=bash /etc/siscofis.sh' >> /usr/share/applications/SiscofisOM.desktop
	echo 'Type=Application' >> /usr/share/applications/SiscofisOM.desktop
	echo 'Categories=Office;' >> /usr/share/applications/SiscofisOM.desktop
	echo 'Icon=/usr/share/icons/eb.png' >> /usr/share/applications/SiscofisOM.desktop
	chmod  755 /usr/share/applications/SiscofisOM.desktop
	chmod  +x /usr/share/applications/SiscofisOM.desktop
	if [ ! -f /etc/siscofis.sh ] && [ -f siscofis.sh ]; then
		cp siscofis.sh /etc/siscofis.sh
		chmod +x /etc/siscofis.sh
	fi
	if [ ! -f /usr/share/icons/eb.png ] && [ -f eb.png ]; then
		cp -f eb.png /usr/share/icons/eb.png
		chmod 755 /usr/share/icons/eb.png
	fi
	if [ ! -f /etc/cfgwine.sh ] && [ -f cfgwine.sh ]; then
		cp -f cfgwine.sh /etc/cfgwine.sh
		chmod +x /etc/cfgwine.sh
	fi
	if [ -f /tmp/cache/wine.zip ] && [ ! -f /etc/wine.zip ]; then 
		cp -f /tmp/cache/wine.zip /etc/wine.zip
	fi
fi

# Cria o lançador de execução unica para habilitar os drivers dos tokens ALLADYN, SAFENET E GD para novos usuarios normais
echo '[Desktop Entry]' > /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
echo 'Type=Application' >> /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
echo 'Exec=/usr/bin/zorin-tokens-autostart' >> /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
echo 'Hidden=false' >> /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
echo 'NoDisplay=true' >> /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
echo 'Name=Carrega drivers dos tokens para os navegadores' >> /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
echo 'Comment=Habilita o reconhecimento de tokens.' >> /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
chmod 755 /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
chmod +x /etc/skel/.config/autostart/zorin-tokens-autostart.desktop
cp -f zorin-tokens-autostart /usr/bin/zorin-tokens-autostart
chmod 755 /usr/bin/zorin-tokens-autostart
chmod +x /usr/bin/zorin-tokens-autostart

# Cria o lançador de instalação para novos usuários do BonitaStudioComunitty
echo '[Desktop Entry]' > /usr/share/applications/InstaladordoBonita.desktop
echo 'Name=Bonita [Instalar/executar]' >> /usr/share/applications/InstaladordoBonita.desktop
echo 'Exec=/bin/bash /etc/bscautostart.sh' >> /usr/share/applications/InstaladordoBonita.desktop
echo 'Type=Application' >> /usr/share/applications/InstaladordoBonita.desktop
echo 'StartupNotify=true' >> /usr/share/applications/InstaladordoBonita.desktop
echo "Comment=diagramação, modelagem, processos, notação, BPMN, diagramas, fluxo, objetos,conexão, raias, artefatos, Business, Process, Notation" >> /usr/share/applications/InstaladordoBonita.desktop
echo 'Encoding=UTF-8' >> /usr/share/applications/InstaladordoBonita.desktop
echo 'Icon=./BonitaStudioCommunity/bonitasoft-icon-128-128-transparent.png' >> /usr/share/applications/InstaladordoBonita.desktop
echo 'Categories=System;' >> /usr/share/applications/InstaladordoBonita.desktop
chmod  755 /usr/share/applications/InstaladordoBonita.desktop
chmod  +x  /usr/share/applications/InstaladordoBonita.desktop
cp -f bscautostart.sh /etc/bscautostart.sh
chmod 755 /etc/bscautostart.sh
chmod +x /etc/bscautostart.sh

# Cria o lançador de instalação do Assinador do Serpro
echo '[Desktop Entry]' > /usr/share/applications/InstaladorAssinadorSepro.desktop
echo 'Name=Instala Assinador Serpro' >> /usr/share/applications/InstaladorAssinadorSepro.desktop
echo 'Exec=/bin/bash /etc/serproass.sh' >> /usr/share/applications/InstaladorAssinadorSepro.desktop
echo 'Type=Application' >> /usr/share/applications/InstaladorAssinadorSepro.desktop
echo "Comment=serpro, assinatura, digital, certificado, validação, ICP-Brasil, criptografia, segurança, eletrônica" >> /usr/share/applications/InstaladorAssinadorSepro.desktop
echo 'Encoding=UTF-8' >> /usr/share/applications/InstaladorAssinadorSepro.desktop
echo 'Categories=System;' >> /usr/share/applications/InstaladorAssinadorSepro.desktop
chmod  755 /usr/share/applications/InstaladorAssinadorSepro.desktop
chmod  +x  /usr/share/applications/InstaladorAssinadorSepro.desktop
cp -f serproass.sh /etc/serproass.sh
chmod 755 /etc/serproass.sh

# Cria o lançador de instalação do Assinador do CERTILLION
echo '[Desktop Entry]' > /usr/share/applications/InstaladorCertillion.desktop
echo 'Name=Instala Assinador Certillion' >> /usr/share/applications/InstaladorCertillion.desktop
echo "Comment=CFM, farmácia, receita, receituário, assinatura, certificado, validação, ICP-Brasil, criptografia, segurança, eletrônica" >> /usr/share/applications/InstaladorCertillion.desktop
echo 'Exec=/bin/bash /etc/certillion.sh' >> /usr/share/applications/InstaladorCertillion.desktop
echo 'Type=Application' >> /usr/share/applications/InstaladorCertillion.desktop
echo 'Encoding=UTF-8' >> /usr/share/applications/InstaladorCertillion.desktop
echo 'Categories=System;' >> /usr/share/applications/InstaladorCertillion.desktop
chmod  755 /usr/share/applications/InstaladorCertillion.desktop
chmod  +x  /usr/share/applications/InstaladorCertillion.desktop
cp -f certillion.sh /etc/certillion.sh
chmod 755 /etc/certillion.sh

# Cria o lançador de instalação do Assinador do PJE Office
echo '[Desktop Entry]' > /usr/share/applications/InstaladorPJE.desktop
echo 'Name=Instala Assinador PJE Office' >> /usr/share/applications/InstaladorPJE.desktop
echo 'Exec=/bin/bash /etc/pjeoffice.sh' >> /usr/share/applications/InstaladorPJE.desktop
echo "Comment=pje, Processo, Judicial, PJeOffice, assinatura, digital, certificado, PKCS11, PJe Mobile, TRT, CNJ" >> /usr/share/applications/InstaladorPJE.desktop
echo 'Type=Application' >> /usr/share/applications/InstaladorPJE.desktop
echo 'Encoding=UTF-8' >> /usr/share/applications/InstaladorPJE.desktop
echo 'Categories=System;' >> /usr/share/applications/InstaladorPJE.desktop
chmod 755 /usr/share/applications/InstaladorPJE.desktop
chmod +x  /usr/share/applications/InstaladorPJE.desktop
cp -f pjeoffice.sh /etc/pjeoffice.sh
chmod 755 /etc/pjeoffice.sh

# "↓↓↓↓↓↓↓↓↓ REMOVE CHAVES DE CONEXÕES ANTIGAS"
if [ -d .ssh/ ]; then
	rm -rf .ssh/
fi

if [ -d /root/.ssh/ ]; then
	rm -rf /root/.ssh/
fi

# TRADUÇÃO DA DESCRIÇÃO DO RECOLL
sed -i 's/Comment=Find documents by specifying search terms/Comment=Localiza termos nos documentos/g' /usr/share/applications/recoll-searchgui.desktop
sed -i 's/GenericName=Local Text Search/GenericName=Procura sequencias nos documentos/g' /usr/share/applications/recoll-searchgui.desktop
sed -i 's/Name=Recoll/Name=Procurar termos/g' /usr/share/applications/recoll-searchgui.desktop
chmod 644 /usr/share/applications/recoll-searchgui.desktop
chmod +x /usr/share/applications/recoll-searchgui.desktop

#echo " o SCRIPT tokenGD.sh DEVE SER INSTALADO APOS O APT AUTOREMOVE, apt-get --fix-broken install e DEBORPHAN "
#echo "  tokenGD.sh instala os drivers do token GD BURTI para ativar o uso no site compras GOV de licitações"
sh -x tokenGD.sh 

# "↓↓↓↓↓↓↓↓↓ INSTALA O DRIVER PARA O TOKEN SAFENET"
if [ -f safenet.sh ]; then
	sh -x safenet.sh 
fi
dpkg --configure -a
apt-get clean; apt-get autoremove -y
apt-get install opensc  -y

#  COPIA PARA /BIN O SCRIPT CARREGAdriverTOKEN.sh
cp -f CARREGAdriverTOKEN.sh /bin/CARREGAdriverTOKEN.sh
chmod 755 /bin/CARREGAdriverTOKEN.sh
chmod +x /bin/CARREGAdriverTOKEN.sh
ln -sf /bin/CARREGAdriverTOKEN.sh /bin/CARREGAdriverTOKEN
ln -sf /bin/CARREGAdriverTOKEN.sh /bin/carregadrivertoken
ln -sf /bin/CARREGAdriverTOKEN.sh /bin/carregadrivertokens

ln -sf /bin/CARREGAdriverTOKEN.sh /bin/CARREGAdriverTOKEN.sh
ln -sf /bin/CARREGAdriverTOKEN.sh /bin/carregadrivertoken.sh
ln -sf /bin/CARREGAdriverTOKEN.sh /bin/carregadrivertokens.sh
