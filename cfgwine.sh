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
# Script que restaura e pré-configura o PREFIXO do wine 4.0.4 para aplicações 32bits legadas do Windows
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
# carregamento das variáveis de ambiente de cada perfil organizacional
. /etc/os-release
. /etc/om.ips
. /$HOME/.config/user-dirs.dirs

VerWine=`wine --version`
if [ "$VerWine" = "wine-4.0.4" ]; then
 	if [ -f /etc/wine.zip ]; then
		unzip -o -d $HOME /etc/wine.zip
	else
		# 'Testa a disponibilidade da INTRANET CORPORATIVA para obter o prefixo preconfigurado para execução do wine'
		nc -w 2 -v $sigh 80 < /dev/null
	 	if [ $? -eq 0 ]; then
			notify-send --urgency=critical --icon=wine --app-name=fish --expire-time=30000  "Baixando o ambiente do Siscofis" "Aguarde a exibição da interface do SiscofisOM"
			wget http://$sigh/sigh/wine.zip -O /tmp/wine.zip 
			unzip -o -d $HOME /tmp/wine.zip
		else
			zenity   --warning --text="SERVIDOR DO AMBIENTE INDISPONÍVEL! \n\n Consulte o administrador do SISCOFIS." --width=450 --height=100
			exit
		fi
	fi

fi


# "↓↓↓↓↓↓↓↓↓ REMOVE A LINHA CONTENDO QUE A CONFIGURAÇÃO ANTIGA NO ARQUIVO INI
grep -v "NomeServidor=" $HOME/.wine/drive_c/SimatexOm/SimatexOm.ini > /tmp/tmpfile

#  ANEXA AO ARQUIVO .INI O IP OBTIDO DE /etc/om.ips RECONFIGURANDO O ACESSO NO ARQUIVO TEMPORÁRIO
echo "NomeServidor=$siscofis" >> /tmp/tmpfile
rm -f $HOME/.wine/drive_c/SimatexOm/SimatexOm.ini
mv -f /tmp/tmpfile $HOME/.wine/drive_c/SimatexOm/SimatexOm.ini

# REMOVE O LANÇADOR ANTIGO E PREPARA NOVO LANÇADOR AO USUÁRIO ATUAL
if [ -f $HOME/.wine/drive_c/SimatexOm/SimatexOm.ini ]; then 
	if [ -f "$XDG_DESKTOP_DIR"/SiscofisOM.desktop ]; then
		rm -f "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	fi 
	
	# Cria o ícone de execução SISCOFIS no Desktop do usuário 
	echo '[Desktop Entry]' >  "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	echo 'Name=SiscofisOM' >> "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	echo 'Exec=bash /etc/siscofis.sh' >> "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	echo 'Type=Application' >> "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	echo 'Categories=Office;' >> "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	echo 'Terminal=true' >> "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	echo 'Icon='$HOME'/.wine/drive_c/SimatexOm/eb.png' >> "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	chmod  755 "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
	chmod  +x "$XDG_DESKTOP_DIR"/SiscofisOM.desktop
fi


