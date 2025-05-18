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
# Executa a customização, calculando o tempo da execução e armazena o log da execução dos scripts em custom.log
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#

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

if [ "$1" != "1" ] && [ "$1" != "2" ] && [ "$1" != "3" ]; then
	clear
	echo "		Você executou# bash $0 $1 "
	echo 
	echo "		Opção inválida. Opções < 1, 2 ou 3 >"
	exit
fi

time ./run.sh $1 > custom.log 2>&1

USERADM=`grep '^sudo:.*$' /etc/group | cut -d: -f4`
if [ -d /home/$USERADM/"Área de Trabalho" ]; then
	mv -f custom.log /home/$USERADM/"Área de Trabalho"/custom.log
	#chattr +i /home/$USERADM/"Área de Trabalho"/custom.log
else
	mv -f custom.log /etc/skel/custom/custom.log
fi
