#!/bin/bash
# latest-firefox
# Contributer: drgibbon (thanks!)

# This script will find the latest Firefox binary package, download it
# and repackage it into Slackware format.

# I don't use Firefox for regular browsing but it is handy for
# comparative tests against Vivaldi. :P

# Copyright 2018 Ruari Oedegaard, Oslo, Norway
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# ADAPTED BY ARTHUR.AIDA@GMAIL.COM

# Check if the user asked for auto-install

#echo "Chamada do script: "$(basename $0) "-----------------------------------------------------------------------------------------------------------"
if [ "$1" = "-i" -o "$1" = "--install" ]; then
  if [ "$UID" = "0" ]; then
    AUTO_INSTALL=Y
  else
    echo "You must be root to auto-install, $1 ignored!" >&2
    AUTO_INSTALL=N
  fi
else
  AUTO_INSTALL=N
fi

# Use the architecture of the current machine or whatever the user has
# set externally
ARCH=${ARCH:-$(uname -m)}

if [ "$ARCH" = "x86_64" ]; then
  LIBDIRSUFFIX="64"
elif [[ "$ARCH" = i?86 ]]; then
  ARCH=i686
  LIBDIRSUFFIX=""
else
  echo "The architecture $ARCH is not supported." >&2
  exit 
fi

# Set to esr or beta to track ESR and beta channels instead of regular Firefox # Set to LATEST channels instead of regular Firefox
FFESR=${FFESR:-N}
FFCHANNEL=latest
if [ "$FFCHANNEL" = "latest" ]; then
  FFCHANNEL=latest
fi
# This defines the language of the downloaded package
FFLANG=${FFLANG:-pt-BR}

# Work out the latest stable Firefox if VERSION is unset
VERSION=${VERSION:-$(wget --spider -S --max-redirect 0 "https://download.mozilla.org/?product=firefox-${FFCHANNEL}&os=linux${LIBDIRSUFFIX}&lang=${FFLANG}" 2>&1 | sed -n '/Location: /{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')}

# Error out if $VERSION is unset, e.g. because previous command failed
if [ -z $VERSION ]; then
  echo "Could not work out the latest version; exiting" >&2
  exit 1
fi

#
nome="firefox"
pacote=$(snap list | grep "$nome" )
if [ -n "$pacote" ]; then
	snap remove firefox -y
fi
pacote=$(flatpak list | grep "$nome" )
if [ -n "$pacote" ]; then
	flatpak uninstall  org.mozilla.firefox -y
fi
pacote=$(dpkg --get-selections | grep "$nome" )
if [ -n "$pacote" ]; then
	apt purge "$nome" -y
fi

if [ -f /OPT/firefox/application.ini ]; then
	grep "Version" /OPT/firefox/application.ini > /tmp/mzlff.sta
	verf2=$(awk -F= '{if(NR==1)print $2}' /tmp/mzlff.sta)
	if [ "$verf2" = "$VERSION" ] ; then
		echo ">>>>>> ... O  Firefox $verf2 está atualizado."
		exit 0
	fi
	echo ">>>>>> OK! Atualizando o Firefox de $verf2 para $VERSION"
fi

if [ ! -d /OPT/firefox ]; then
	mkdir /OPT
fi
FIREFOXPKG="https://download.mozilla.org/?product=firefox-${VERSION}&os=linux${LIBDIRSUFFIX}&lang=${FFLANG}"
wget "$FIREFOXPKG" -O /tmp/firefox.tar.xz
tar -xf /tmp/firefox.tar.xz --overwrite-dir  -C /OPT
ln -sf /OPT/firefox/firefox /usr/bin/firefox

# "↓↓↓↓↓↓↓↓↓ RECRIA O LINK PARA A BIBLIOTECA DE CARREGAMENTO DINÂMICO DOS CERTIFICADOS PARA O FIREFOX"
if [ -f /OPT/firefox/libnssckbi.so ]; then
	filename=/OPT/firefox/libnssckbi.so
	file_size=`du -k "$filename" | cut -f1`
	if [ $file_size != 0 ]; then
		rm  -f $filename
		ln -sf /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-trust.so /OPT/firefox/libnssckbi.so
	fi
fi

# "↓↓↓↓↓↓↓↓↓ RECONFIGURAÇÃO DO LINK PARA EXECUTAR O FIREFOX BINARIO ATUALIZADO"
echo "[Desktop Entry]" > /usr/share/applications/firefox.desktop
echo "Version=$VERSION" >> /usr/share/applications/firefox.desktop
echo "Encoding=UTF-8" >> /usr/share/applications/firefox.desktop
echo "Name=Navegador Firefox" >> /usr/share/applications/firefox.desktop
echo "Comment=Navegador da internet" >> /usr/share/applications/firefox.desktop
echo "Exec=/usr/bin/firefox %u" >> /usr/share/applications/firefox.desktop
echo "Icon=firefox" >> /usr/share/applications/firefox.desktop
echo "Type=Application" >> /usr/share/applications/firefox.desktop
echo "Categories=Network" >> /usr/share/applications/firefox.desktop
chmod 644 /usr/share/applications/firefox.desktop
chmod +x /usr/share/applications/firefox.desktop

exit
