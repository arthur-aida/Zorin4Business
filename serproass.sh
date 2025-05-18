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
#   Este script instala/atualiza o assinador do serpro.
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"

nome="assinador-serpro"
pacote=$(dpkg --get-selections | grep "$nome" )
if [ ! -n "$pacote" ]; then
	if [ "$(id -u)" = "0" ]; then
		wget -qO- https://assinadorserpro.estaleiro.serpro.gov.br/repository/AssinadorSERPROpublic.asc | tee /etc/apt/trusted.gpg.d/AssinadorSERPROpublic.asc
		add-apt-repository 'deb https://assinadorserpro.estaleiro.serpro.gov.br/repository/ universal stable' -y  
		apt update 
		apt install assinador-serpro -y 
		apt --fix-broken install -y 
		rm -f  /usr/share/applications/InstaladorAssinadorSepro.desktop
	fi
	if [ "$(id -u)" != "0" ]; then
		zenity   --warning --text="Solicite ao Administrador que execute, como root, num terminal <bash serproass.sh> para instalá-lo." --width=450 --height=100 --timeout=15
		exit
	fi
else
		zenity   --warning --text="Na barra de localização do menu, digite: Assinador Serpro " --width=450 --height=100 --timeout=15
fi
