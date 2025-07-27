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
# Script acionado pelo menu para instalar/executar o Assinador Certillion do CFM
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
# echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"

if [ "$(id -u)" = "1000" ] || [ "$(id -u)" = "0" ] ; then
	zenity   --warning --text="O Certillion não será instalado no usuário administrador ou root. \n \nCrie um novo usuário convencional para instalar." --width=450 --height=100 --timeout=15
	exit
else
	if [ ! -d $HOME/signer-certillion ]; then
		zenity   --warning --text="1 - O download da aplicação pode demorar;\n \n2 - Esta janela será fechada em 30s para iniciar o download;\n \n3 - Na próxima janela, clique no botão OK após o download ser concluído;\n \n4 - Selecione as opções quando solicitado e; \n \n5 - Prossiga até finalizar a instalação. " --width=650 --height=150 --timeout=30
		if [ ! -f  /tmp/Assinador-Certillion-1.7.3.run  ]; then
			wget https://download.certillion.com/signer/installer/linux/Assinador-Certillion-1.7.3.run  -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# a \2\/s, EM \3/' | zenity --progress --title="Baixando..."

			RUNNING=0
			while [ $RUNNING -eq 0 ]
			do
			if [ -z "$(pidof zenity)" ]
			then
			pkill wget
			RUNNING=1
			fi
			done
		fi
		if [ ! -d $HOME/signer-certillion ]; then
			mkdir -p $HOME/signer-certillion
		fi
		chmod +x /tmp/Assinador-Certillion-1.7.3.run
		exec /tmp/Assinador-Certillion-1.7.3.run
		cp $HOME/.local/share/applications/Certillion.desktop $HOME/"Área de Trabalho"/Certillion.desktop
		chmod +x $HOME/"Área de Trabalho"/Certillion.desktop
	fi
	#exec "$HOME/
fi
