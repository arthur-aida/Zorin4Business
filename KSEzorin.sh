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
# Este script é executado no primeiro boor condicionado a conectividade do DNS corporativo
#-------------------------------------------------------------------------------------------------------------------------------
# https://www.gnu.org/licenses/gpl-faq.en.html#GPLRequireSourcePostedPublic
# Partes deste script são adaptações de fontes disponíveis na internet. Objetivo preparar S.O. sabores ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
#

. /etc/os-release
. /etc/om.ips
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} = 'x86_64' ]; then
	# 64-bit stuff here
	nome="klnagent64"
else
	# 32-bit stuff here
	nome="klnagent"
fi
#  Aborta a instalação se pre-existe alguma instalação nos caminho especificados  
if [ -d /opt/kaspersky/kesl ] && [ -d /opt/kaspersky/$nome ] ; then
	exit
fi

# A seção abaixo do script foi adaptado do original para não exigir interferencia humana. 
# Será executado sequencialmente os passos 1, 2,. Os passos 4, 5, 6, 7, 8 são executados dentro do passo 2. Os passos 9 e 10 são para o log. 
#"1" "DESISNSTALAR ANTIVIRUS" \
#"2" "INSTALAR ANTIVÌRUS 64 BITS" \
#"4" "REINICIAR AGENTE DE REDE" \
#"5" "REINICIAR ANTIVÌRUS" \
#"6" "VERIFICAR CONEXÃO" \
#"7" "VERIFICAR STATUS AGENTE" \
#"8" "VERIFICAR STATUS ANTIVÌRUS" \
#"9" "VERIFICAR PROCESSOS" \
#"10" "VERIFICAR CHAVE" 3>&1 1>&2 2>&3)

#	1)
		systemctl list-units --type=service | grep kesl
		systemctl stop kesl.service
		#Remover os pacotes:
		dpkg --purge kesl-gui
		dpkg --purge kesl
		dpkg --purge klnagent64
		#Excluir diretÃ³rios relacionados ao kaspersky:
		rm -rf /opt/kaspersky/
		rm -rf /var/opt/kaspersky/
		rm -rf /var/log/kaspersky/
		rm -rf /etc/opt/kaspersky/
		rm -rf /var/run/kaspersky/
#	2)
		echo "[ Welcome to Kaspersky Endpoint Security auto install script ]"
		#### [ Check if curl is installed on the system ] ####
		if command -v curl &>/dev/null; then
			echo "- [OK] - curl is installed on the system"
		else
			echo "- [KO] - curl is requiered and not installed on this system"
		#      exit 0
		fi

		apt-get install libxcb-xinerama0 libxcb-icccm4 curl -y

		FACheck=$(grep -ir 'CONFIG_FANOTIFY=' /boot/config-$(uname -r))
		if [[ $FACheck == CONFIG_FANOTIFY=y ]]; then
			echo "- FANOTIFY enabled:" ${green}"OK"${reset}
			echo "==[ FANOTIFY check Output ]=="
		else
			echo "- " ${red}FANOTIFY disabled on this system${reset}
			if command -v yum &>/dev/null; then
				echo "- [OK] - yum is used by this system."
				yum -y install kernel-headers-$(uname -r) kernel-devel-$(uname -r) && yum -y groupinstall "Development Tools"
			elif
				command -v apt &>/dev/null
			then
				echo "- [OK] - apt is used by this system"
				apt -y install linux-headers-$(uname -r) && apt -y install build-essential
			fi
		fi

		TMP=/tmp/
		KASDIR="kaspersky"
		LOCAL=$(pwd)

		if [ -d $TMP$KASDIR ]; then
			echo "- Cleaning temporary installation directory, please wait..."
			rm -rf $TMP$KASDIR
			echo "- [Done] - Cleaning temporary installation directory"
			echo "-----------------------------------------------" && echo ""
		fi

# ---------------------------------------------------------------------------------------------------------------------------

		#### [ Package declaration deb based ] ####
		NAGENT_PKG_DEB="klnagent64_15.4.0-8873_amd64.deb"
		NAGENT_URL_DEB="https://arquivos.41ct.eb.mil.br/s/9IxIas4T5k5a1xR?path=%2FLinux%20Kaspersky%2FPacotes_Separados%2F64_BITs/$NAGENT_PKG_DEB"
		NAGENT_ANSWFILE="autoanswers.conf"

		KESL_PKG_DEB="kesl_12.3.0-1162_amd64.deb"
		KESL_URL_DEB="https://arquivos.41ct.eb.mil.br/s/9IxIas4T5k5a1xR?path=%2FLinux%20Kaspersky%2FPacotes_Separados%2F64_BITs/Linux/$KESL_PKG_DEB"
		KESL_ANSWFILE="kesl_autoanswers.conf"

		KESLGUI_PKG_DEB="kesl-gui_12.3.0-1162_amd64.deb"
		KESLGUI_URL_DEB="https://arquivos.41ct.eb.mil.br/s/9IxIas4T5k5a1xR?path=%2FLinux%20Kaspersky%2FPacotes_Separados%2F64_BITs/$KESLGUI_PKG_DEB"

# ---------------------------------------------------------------------------------------------------------------------------

		#### [ Kaspersky Security Center IP ] ####
		# /!\ This value need to be updated
		KSC_IP="10.89.36.34"
		KSC_DNS="srv-win-ksc.41ct.eb.mil.br"

# ---------------------------------------------------------------------------------------------------------------------------

		#### [ Kaspersky Endpoint Security for Linux installation ] ####

		if command -v dpkg &>/dev/null; then
			echo "- [INFO] - dpkg is used by this system"
			# Creating a temporary directory and moving to it
			mkdir -p $TMP$KASDIR

			tar -xvf antivirus.tar
			# Downloading installation packages
			echo "Downloading $NAGENT_PKG_DEB, please wait..."
		#	curl -sk --progress-bar --location $NAGENT_URL_DEB --output $TMP$KASDIR/$NAGENT_PKG_DEB
			mv $LOCAL/klnagent64_15.4.0-8873_amd64.deb $TMP$KASDIR/$NAGENT_PKG_DEB

			echo "[Done] - Downloading $NAGENT_PKG_DEB package." && echo ""

			echo "Downloading $KESL_PKG_DEB package, please wait..."
		#	curl -sk --progress-bar --location $KESL_URL_DEB --output $TMP$KASDIR/$KESL_PKG_DEB
			mv $LOCAL/kesl_12.3.0-1162_amd64.deb $TMP$KASDIR/$KESL_PKG_DEB


			echo "[Done] - Downloading $KESL_PKG_DEB package." && echo ""

			echo "Downloading $KESLGUI_PKG_DEB (KESL GUI) package, please wait..."
		#	curl -sk --progress-bar --location $KESLGUI_URL_DEB --output $TMP$KASDIR/$KESLGUI_PKG_DEB
			mv $LOCAL/kesl-gui_12.3.0-1162_amd64.deb $TMP$KASDIR/$KESLGUI_PKG_DEB

			echo "[Done] - Downloading $KESLGUI_PKG_DEB package." && echo ""

			cd $TMP$KASDIR

			#Creating an answers-file for Nagent into the temporary folder
			echo "KLNAGENT_SERVER=${KSC_IP}" >$TMP$KASDIR/$NAGENT_ANSWFILE
			echo "KLNAGENT_EULA=y" >>$TMP$KASDIR/$NAGENT_ANSWFILE
			echo "KLNAGENT_PORT=14000" >>$TMP$KASDIR/$NAGENT_ANSWFILE
			echo "KLNAGENT_SSLPORT=13000" >>$TMP$KASDIR/$NAGENT_ANSWFILE
			echo "KLNAGENT_USESSL=y" >>$TMP$KASDIR/$NAGENT_ANSWFILE
			echo "KLNAGENT_GW_MODE=1" >>$TMP$KASDIR/$NAGENT_ANSWFILE
			echo "EULA_ACCEPTED=y" >>$TMP$KASDIR/$NAGENT_ANSWFILE

			# temp export to perform silent Network agent installation
			export KLAUTOANSWERS=$TMP$KASDIR/$NAGENT_ANSWFILE

			#Checking if the products have been already installed, removing them
			if [[ $(dpkg -l | grep 'klnagent64' | wc -l) -gt 0 ]]; then
				echo "Network Agent has already been installed. Removing, please wait..."
				dpkg -P klnagent64
				echo "[Done] - Uninstalling Network Agent" && echo ""
			fi

			if [[ $(dpkg -l | grep 'kesl-gui' | wc -l) -gt 0 ]]; then
				echo "Kaspersky Endpoint Security for Linux (GUI) has already been installed. Removing, please wait..."
				dpkg -P kesl-gui
				echo "[Done] - Uninstalling Kaspersky Endpoint Security for Linux (GUI)" && echo ""
			fi

			if [[ $(dpkg -l | grep 'kesl' | wc -l) -gt 0 ]]; then
				echo "Kaspersky Endpoint Security for Linux has already been installed. Removing, please wait..."
				dpkg -P kesl
				echo "[Done] - Uninstalling Kasperky Endpoint Security for Linux" &
				echo ""
			fi

			#Installation of KNAgent
			echo "Installation of $NAGENT_PKG_DEB, please wait..."
			dpkg -i $NAGENT_PKG_DEB
			/opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl --auto
			echo "[Done] - Installation of $NAGENT_PKG_DEB" && echo ""

			#Creating an answers-file for KESL into the temporary folder
			echo "EULA_AGREED=yes" >$TMP$KASDIR/$KESL_ANSWFILE
			echo "PRIVACY_POLICY_AGREED=yes" >>$TMP$KASDIR/$KESL_ANSWFILE
			echo "USE_KSN=yes" >>$TMP$KASDIR/$KESL_ANSWFILE
			#optional setting echo "LOCALE" >> $TMP$KASDIR/$KESL_ANSWFILE
			#echo "INSTALL_LICENSE" >> $TMP$KASDIR/$KESL_ANSWFILE
			echo "UPDATER_SOURCE=SCServer" >>$TMP$KASDIR/$KESL_ANSWFILE #possible options: SCServer|KLServers
			#echo "PROXY_SERVER=no" >> $TMP$KASDIR/$KESL_ANSWFILE
			echo "UPDATE_EXECUTE=yes" >>$TMP$KASDIR/$KESL_ANSWFILE
			#echo "KERNEL_SRCS_INSTALL" >> $TMP$KASDIR/$KESL_ANSWFILE
			echo "USE_GUI=no" >>$TMP$KASDIR/$KESL_ANSWFILE
			echo "IMPORT_SETTINGS=no" >>$TMP$KASDIR/$KESL_ANSWFILE
			echo "GROUP_CLEAN=yes" >>$TMP$KASDIR/$KESL_ANSWFILE
			#optional setting echo "ScanMemoryLimit" >> $TMP$KASDIR/$KESL_ANSWFILE

			#Installation of KESL
			echo "Installation of $KESL_PKG_DEB, please wait..."
			dpkg -i $KESL_PKG_DEB
			/opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=$TMP$KASDIR/$KESL_ANSWFILE
			echo "[Done] - Installation of $KESL_PKG_DEB" && echo ""

			#Installation of KESL GUI
			echo "Installation of $KESLGUI_PKG_DEB (GUI), please wait..."
			dpkg -i $KESLGUI_PKG_DEB
			echo "[Done] - Installation of $KESLGUI_PKG_DEB (GUI)" && echo ""

			# restart KESL after complete installation
			#reboot em 5 min
			echo -e "\n\n\n#####################################################################\n\n\n"
			echo -e "*** ATENÇÃO O COMPUTADOR DEVE SER REINICIADO MANUALMENTE ***"
			echo -e "\n\n\n#####################################################################\n\n\n"
			echo "Restarting Agent and Kaspersky Endpoint Security for Linux!"
			systemctl restart klnagent64.service && systemctl restart kesl.service
			echo "[Done] - Restarting done!"
			echo "REINICIE SEU DISPOSITIVO"
		fi
#		echo "VERIFICAR PROCESSOS" 3>&1 1>&2 2>&3
#		/opt/kaspersky/kesl/bin/kesl-control --get-task-list 3>&1 1>&2 2>&3
#		echo "VERIFICAR CHAVE" 3>&1 1>&2 2>&3
#		/opt/kaspersky/kesl/bin/kesl-control -L --query 3>&1 1>&2 2>&3
		# exit program
		exit 

