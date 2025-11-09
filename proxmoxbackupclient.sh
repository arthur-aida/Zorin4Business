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
#------------------------------------------------------------------------------------------------------------------------------
# Este script instala e configura o cliente de backup para o servidor PBS.
# Cria uma máscara em /home/.pxarexclude para applicar nos arquivos
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
# deb [arch=amd64 trusted=true] http://download.proxmox.com/debian/pve bullseye pve-no-subscription

#echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"
# CARREGA VARIAVEIS DE SISTEMA
. /etc/os-release
# A DEFINIR
pbscli=" "

# RECUPERA O NOME DO USUARIO ADMINISTRADOR
USERADM=`grep '^sudo:.*$' /etc/group | cut -d: -f4`

if [ ! -f /usr/bin/proxmox-backup-client ]; then
	wget https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg
	wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
	wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
	wget https://enterprise.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg
	sha512sum /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg
	sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
	sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
	sha512sum /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg

	grep -q "pbs-client" /etc/apt/sources.list
	if [ $? = 1 ]; then
		pbscli="no"
	fi
	if [ "$pbscli" = "no" ]; then 
		# ALTERAR SOMENTE APÓS TESTE DE RETROCOMPATIBILIDADE NA PLATAFORMA 22.04, 20.04 e 18.04
		echo "deb [arch=amd64 trusted=true] http://download.proxmox.com/debian/pbs-client bullseye main" | tee /etc/apt/sources.list.d/pbsclient.list
		echo "deb [arch=amd64 trusted=true] http://download.proxmox.com/debian/pve bullseye pve-no-subscription" | tee /etc/apt/sources.list.d/pvenosub.list
	fi
	apt-get update
	rm -f /etc/default/smartmontools
	apt-get install --install-recommends  --assume-yes proxmox-backup-client smartmontools

	# CRIA O ARQUIVO /home/.pxarexclude PARA EXCLUIR PASTAS E ARQUIVOS ESPECIFICOS e MANTER .config e .mozilla"
	# A ORDEM DA SEQUENCIA DAS LINHAS ALTERA OS RESULTADOS"
	echo "lost+found/" >  /home/.pxarexclude
	echo "**/$USERADM/" >> /home/.pxarexclude
	echo "**/custom/" >> /home/.pxarexclude
#	echo "**/Downloads/" >> /home/.pxarexclude
	echo "**/Modelos/" >> /home/.pxarexclude
	echo "**/PDF/" >> /home/.pxarexclude
	echo "**/Público/" >> /home/.pxarexclude
	echo "**/snap/" >> /home/.pxarexclude
	echo "**/Templates/" >> /home/.pxarexclude
	echo "**/*boletim_interno*" >> /home/.pxarexclude
	echo "**/*.desktop" >> /home/.pxarexclude
	echo "**/*HOD*" >> /home/.pxarexclude
	echo "**/.~*.*" >> /home/.pxarexclude
	echo "**/*.old" >> /home/.pxarexclude
	echo "**/*.7[zZ]" >> /home/.pxarexclude
	echo "**/*.[aA][aA]*" >> /home/.pxarexclude
	echo "**/*.[aA][cC]*" >> /home/.pxarexclude
	echo "**/*.[aA][rR][jJ]" >> /home/.pxarexclude
	echo "**/*.[aA][vV]*" >> /home/.pxarexclude
	echo "**/*.[bB][zZ]2" >> /home/.pxarexclude
	echo "**/*.[cC][rR][tT]" >> /home/.pxarexclude
	echo "**/*.[dD][vV][iI]*" >> /home/.pxarexclude
	echo "**/*.[eE][xX][eE]" >> /home/.pxarexclude
	echo "**/*.[fF][lL]?" >> /home/.pxarexclude
	echo "**/*.[gG][zZ]" >> /home/.pxarexclude
	echo "**/*.[iI][sS][oO]" >> /home/.pxarexclude
	echo "**/*.[mM][pP]*" >> /home/.pxarexclude
	echo "**/*.[mM][oO][vV]*" >> /home/.pxarexclude
	echo "**/*.[mM[kK]*" >> /home/.pxarexclude
	echo "**/*.[mM][sS][iI]" >> /home/.pxarexclude
	echo "**/*.[oO][lL][dD]" >> /home/.pxarexclude
	echo "**/*.[rR][mM]*" >> /home/.pxarexclude
	echo "**/*.[rR][aA][rR]" >> /home/.pxarexclude
	echo "**/*.[tT][gG][zZ]" >> /home/.pxarexclude
	echo "**/*.[wW][eE][bB][mM]*" >> /home/.pxarexclude
	echo "**/*.[wW][aA][vV]*" >> /home/.pxarexclude
	echo "**/*.[wW][mM]*" >> /home/.pxarexclude
	echo "**/*.[wW][eE][bB][mM]*" >> /home/.pxarexclude
	echo "**/*.[zZ]" >> /home/.pxarexclude
	echo "**/*.[zZ][iI][pP]" >> /home/.pxarexclude
	echo "**/.[A-Z]*" >> /home/.pxarexclude
	echo "**/.[a-z]*" >> /home/.pxarexclude
	echo "**/.[0-9]*" >> /home/.pxarexclude

	# CRIA O ARQUIVO /home/.pxarexclude PARA MANTER AS PASTAS .config e .mozilla"
	echo "!**/.config/" >> /home/.pxarexclude
	echo "!**/.mozilla/" >> /home/.pxarexclude
fi
#######################################################################

# comando para ser executado a partir do crontab da estação ou acionado remotamente no crontab do PBS em loop para todos os IPs
# proxmox-backup-client backup $HOSTNAME.pxar:/home --repository adm@pbs@pbsall:DADOS --backup-id `ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`

# dentro do PBS gerar a chave para enviar para as estações
#ssh-keygen -t rsa
# envia a chave publica para as estaçoes 192.168.0.X permitindo a execução remota do script /root/backup.sh nas estações linux
#ssh-copy-id root@192.168.0.X

#https://www.youtube.com/watch?v=if1T6HIas9w
#outras facilidades  https://forum.proxmox.com/threads/how-to-automate-backup-process.74253/

#rdfind -dryrun true -makehardlinks true ./


