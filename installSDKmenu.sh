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
# Este script instala o plugin do assinador SDK-Desktop
#--------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
. /etc/os-release
. /etc/om.ips
. /$HOME/.config/user-dirs.dirs

if [ -z "$(groups $(whoami) | grep sudo)" ]; then
	zenity   --warning --text="Este usuário não possui as permissões de [sudo] para executar este procedimento. \n\nPreferencialmente crie um usuário, adicione-o ao grupo sudo e logue-se para que \n\nseja criado a respectiva área de trabalho. Para executar isto, abra o Desktop do \n\nadministrador  e crie o novo usuario. A seguir abra um terminal para adicionar o  \n\nnovo usuário ao grupo sudo digitando o comando a seguir no terminal: \n\nsudo usermod -aG sudo NOMEDOUSARIO"
	exit
fi

# variavel que armazena a versão do sistema operacional
VSO=$VERSION_CODENAME
sudo rm -f *.zip
sudo rm -Rf /tmp/SDKv136-wJava

# CÓDIGO ADAPTADO PARA SIMULAR O UBUNTU NA INSTALAÇÃO COM ZORIN OS
if [ ID != 'ubuntu' ]; then
	#Reconfigura o parametro para reconhecer a distribuição como Ubuntu e liberar a instalação do ACDEFESA
	if [ $VSO = "bionic" ]; then
		UBUNTU_VERSION="18"
	fi
	if [ $VSO = "focal" ] || [ $VSO = "una" ] || [ $VSO = "bullseye" ] || [ $VSO = "elsie" ] || [ $VSO = "bookworm" ] || [ $VSO = "uma" ] || [ $VSO = "ulyssa" ] || [ $VSO = "ulyana" ]; then
		UBUNTU_VERSION="20"
	fi
	if [ $VSO = "jammy" ] || [ $VSO = "virginia" ] || [ $VSO = "victoria" ]; then
		UBUNTU_VERSION="22"
	fi
	export UBUNTU_VERSION
fi
##########################################################################################################################################################

# variavel que armazena o caminho deste script
local=`pwd`

# Requisitos para reconhecer os dispositivos criptográficos
apt-get -y install gnutls-bin pcscd libccid libjbig0 libpcsclite1 unrar opensc opensc-pkcs11 unrar-free libwxbase3.0-0v5 libwxgtk3.0-gtk3-0v5 libnss3-tools --fix-missing 

if [ ! -z "$siscofis" ]; then
	if [ -f $local/cache/SDKv136-wJava.zip ]; then
		cp -f $local/cache/SDKv136-wJava.zip /tmp/
	else
		# fontes alternativas caso fiquem indisponíveis
		SITE1="repositorio.acdefesa.mil.br/Sdk/Ubuntu/SDKv136-wJava.zip"
		SITE2="repositorio-acp.acdefesa.mil.br/Sdk/Ubuntu/SDKv136-wJava.zip"
		wget -c "$SITE1" -P /tmp/
	fi
	unzip -qo /tmp/SDKv136-wJava.zip -d /tmp/
	cd /tmp/SDKv136-wJava/
	bash sdk-desktop-install.sh
	if [ ! -f ~/"Área de Trabalho"/AdicionarCertificadoMozilla.mp4 ]; then
		ln -sf /var/local/AdicionarCertificadoMozilla.mp4 ~/"Área de Trabalho"/AdicionarCertificadoMozilla.mp4
	fi
fi
apt --fix-broken install -y

# CORREÇÕES PARA EXECUÇÃO. O ORIGINAL PARA O UBUNTU NÃO FUNCIONA
chmod -R g+x,o+x /usr/local/bin/
chmod -R g+x,o+x /opt/sdk-desktop/
chmod g+x,o+x /usr/local/bin/sdk-desktop.sh

zenity   --warning --text="Procure por SDK-Desktop no Menu de Aplicativos. Será aberto\n\num terminal(forneça a senha na primeira execução) e mantenha-o aberto para que o \n\nplugin funcione em conjunto com o Mozilla-ESR. Feche o terminal para finalizá-lo. \n\nConfira se o certificado do usuário SDK-Desktop-CA.crt, está instalado no navegador.\n\nO vídeo AdicionarCertificadoMozilla.mp4 exibe como instalar o certificado." --width=450 --height=100



