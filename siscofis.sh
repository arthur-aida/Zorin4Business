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
# AUTOMATIZA o processo de re/instalação e re/configuração do ambiente wine 32bits via extração do arquivo wine.zip
# ATUALIZAR o executável a partir da intranet via wget, quando for disponibilizado uma atualização
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#

#  CARREGA VARIAVEIS DO SO 
. /etc/os-release

# carrega variaveis especificas do PERFIL da LAN
. /etc/om.ips

# se o usuario for root ou administrador cancela a execução
if [ "$(id -u)" = "1000" ] || [ "$(id -u)" = "0" ]; then
	zenity   --warning --text="Executar o Siscofis no usuário administrador é um risco. Informe ao administrador." --width=450 --height=100
	exit
fi

TMPDIR="/tmp/SISCOFIS/"
DTL="$TMPDIR""siscofis.lock"
if [ ! -d $TMPDIR ]; then
	mkdir -p $TMPDIR
fi
if [ ! -f $DTL"_"$(id -un) ]; then
	touch $DTL"_"$(id -un)
	notify-send --urgency=normal --icon=wine --app-name=fish --expire-time=15000  "Verificando a disponibilidade do ambiente" " Aguarde a exibição da interface do SiscofisOM"
else
	zenity   --warning --text="Existe uma sessão aberta ou a aplicação foi terminada sem o logoff, neste caso reinicie o computador." --width=450 --height=100
	rm  -f $DTL"_"$(id -un)
	exit
fi

VerWine=`wine --version`
if [ "$VerWine" != "wine-4.0.4" ]; then
		zenity   --warning --text="As versões do Zorin OS 16 e 17 exige a versão wine-4.0.X, leia o arquivo 16to17.pdf" --width=450 --height=100
		rm  -f $DTL"_"$(id -un)
		exit
fi

nc -w 2 -v $siscofis 3050 < /dev/null
if [ $? -eq 1 ]; then
	zenity   --warning --text="Siscofis INDISPONÍVEL! \n \n A depreciação pode estar em execução!\n\n Consulte o administrador do Siscofis." --width=450 --height=100
	rm  -f $DTL"_"$(id -un)
	exit
fi

if [ ! -f /usr/bin/wine ] ; then
	zenity   --warning --text="O ambiente de execução não está instalado neste computador! \n \nSolicite ao administrador que instale-o." --width=450 --height=100
	rm  -f $DTL"_"$(id -un)
	exit
fi

if [ ! -d $HOME/.wine/drive_c/SimatexOm ]; then
	rm -rf $HOME/.wine
	rm -f $HOME/.config/menus/applications-merged/wine*
	rm -rf $HOME/.local/share/applications/wine
	rm -f $HOME/.local/share/desktop-directories/wine*
	rm -f $HOME/.local/share/icons/????_*.xpm
	rm -f /tmp/wine.zip
	sh /etc/cfgwine.sh
fi

nc -w 2 -v $sigh 80 < /dev/null
if [ $? -eq 0 ] &&  [ ! -f /tmp/SiscofisOm.new ]; then
	wget  http://$sigh/sigh/SimatexOm.exe -O /tmp/SimatexOm.new
	
	md5sum "/tmp/SimatexOm.new" | awk '{print $1}' > /tmp/SISCOFIS/sumnew
	md5sum "$HOME/.wine/drive_c/SimatexOm/SimatexOm.exe" | awk '{print $1}' > /tmp/SISCOFIS/sumwin

	file1=/tmp/SISCOFIS/sumnew
	file2=/tmp/SISCOFIS/sumwin

	if ! cmp --silent "$file1" "$file2"; then
		cp -f /tmp/SimatexOm.new $HOME/.wine/drive_c/SimatexOm/SimatexOm.exe
	fi
else
	zenity   --warning --text="Servidor de atualização na intranet indisponível..." --width=450 --height=100
	notify-send " ... o acesso poderá ser negado na verificação da versão do Siscofis..."
fi

wine $HOME/.wine/drive_c/SimatexOm/SimatexOm.exe

notify-send " Liberando a sessão ..."
rm  -f $DTL"_"$(id -un)

