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
# Remove arquivos inúteis dos usuários root e de novos usuários criados 
#--------------------------------------------------------------------------
#
# Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.

dia=$(date +%d)
if [ $dia = "20" ]; then
	bleachbit --clean adobe_reader.cache adobe_reader.mru adobe_reader.tmp brave.cache brave.cookies brave.dom brave.form_history brave.history brave.search_engines brave.session brave.site_preferences brave.sync brave.vacuum chromium.cache chromium.cookies chromium.dom chromium.search_engines chromium.session chromium.sync chromium.vacuum deepscan.backup deepscan.ds_store deepscan.thumbs_db deepscan.tmp epiphany.cache epiphany.cookies epiphany.dom epiphany.places evolution.cache exaile.cache exaile.downloaded_podcasts exaile.log filezilla.mru firefox.backup firefox.cache firefox.cookies firefox.crash_reports firefox.dom firefox.forms firefox.session_restore firefox.vacuum flash.cache flash.cookies gedit.recent_documents gftp.cache gftp.logs gimp.tmp google_chrome.cache google_chrome.cookies google_chrome.dom google_chrome.history google_chrome.search_engines google_chrome.session google_chrome.sync google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history gwenview.recent_documents hexchat.logs kde.cache kde.recent_documents kde.tmp libreoffice.history links2.history microsoft_edge.cache microsoft_edge.cookies microsoft_edge.dom microsoft_edge.search_engines microsoft_edge.session microsoft_edge.sync microsoft_edge.vacuum midnightcommander.history miro.cache miro.logs nautilus.history nexuiz.cache octave.history openofficeorg.cache openofficeorg.recent_documents opera.cache opera.cookies opera.dom opera.form_history opera.history opera.session opera.vacuum palemoon.backup palemoon.cache palemoon.cookies palemoon.crash_reports palemoon.dom palemoon.forms palemoon.session_restore palemoon.site_preferences palemoon.url_history palemoon.vacuum pidgin.cache pidgin.logs realplayer.cookies realplayer.history realplayer.logs rhythmbox.cache rhythmbox.history screenlets.logs seamonkey.cache seamonkey.chat_logs seamonkey.cookies seamonkey.download_history seamonkey.history skype.chat_logs skype.installers slack.cache slack.cookies slack.history slack.vacuum sqlite3.history thumbnails.cache thunderbird.cache thunderbird.cookies thunderbird.index thunderbird.sessionjson thunderbird.vacuum transmission.blocklists transmission.history transmission.torrents vlc.memory_dump vlc.mru wine.tmp winetricks.temporary_files x11.debug_logs xine.cache zoom.cache zoom.logs zoom.recordings system.tmp system.trash 
	echo "BLEACHBIT executado." > /tmp/cleansh
fi
