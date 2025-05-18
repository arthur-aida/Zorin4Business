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
# Este script cria um gancho para que APPLETS JAVA sejam executados pela versão específica /usr/local/jre1.8.0_221/ 
#-------------------------------------------------------------------------------------------------------------------------------
# Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#
# 
echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"
echo "[Desktop Entry]" > /usr/share/applications/icedtea-netx-javaws.desktop
echo "Name=IcedTea Web Start" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "GenericName=Java Web Start" >> /usr/share/applications/icedtea-netx-javaws.desktop 
echo "Comment=IcedTea Application Launcher" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Exec=/usr/local/jre1.8.0_221/bin/javaws %u" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Icon=javaws" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Terminal=false" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Type=Application" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "NoDisplay=true" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "Categories=Settings;Utility;Qt;" >> /usr/share/applications/icedtea-netx-javaws.desktop
echo "MimeType=application/x-java-jnlp-file;x-scheme-handler/jnlp;x-scheme-handler/jnlps" >> /usr/share/applications/icedtea-netx-javaws.desktop
chmod 644 /usr/share/applications/icedtea-netx-javaws.desktop
chmod +x /usr/share/applications/icedtea-netx-javaws.desktop

