#!/bin/bash
# latest-firefox Version
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

# Set to esr or beta to track ESR and beta channels instead of regular Firefox
FFESR=${FFESR:-N}
FFCHANNEL=esr
if [ "$FFCHANNEL" = "esr" ]; then
  FFCHANNEL=esr-latest
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
if [ -f /opt/firefox/application.ini ]; then
	grep "Version" /opt/firefox/application.ini > /tmp/mzlff.esr
	verf2=$(awk -F= '{if(NR==1)print $2}' /tmp/mzlff.esr)"esr"
	if [ "$verf2" = "$VERSION" ] ; then
		echo ">>>>>> ... O  Firefox $verf2 está atualizado."
		exit 0
	fi
	echo ">>>>>> OK! Atualizando o Firefox de $verf2 para $VERSION"
fi

if [ ! -d /opt/ ]; then
	mkdir /opt/
fi

FIREFOXPKG="https://download.mozilla.org/?product=firefox-${VERSION}&os=linux${LIBDIRSUFFIX}&lang=${FFLANG}"
wget "$FIREFOXPKG" -O /tmp/firefox-esr.tar.xz
tar -xf /tmp/firefox-esr.tar.xz --overwrite-dir  -C /opt
ln -sf /opt/firefox/firefox /usr/bin/firefox-esr

#  RECRIA O LINK PARA A BIBLIOTECA DE CARREGAMENTO DINÂMICO DOS CERTIFICADOS PARA O FIREFOX-ESR
if [ -f /opt/firefox/libnssckbi.so ]; then
	filename=/opt/firefox/libnssckbi.so
	file_size=`du -k "$filename" | cut -f1`
	if [ $file_size != 0 ]; then
		rm  -f /opt/firefox/libnssckbi.so
		ln -sf /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-trust.so /opt/firefox/libnssckbi.so
	fi
fi

#  RECONFIGURAÇÃO DO LINK PARA EXECUTAR O FIREFOX-ESR
echo "[Desktop Entry]" > /usr/share/applications/firefox-esr.desktop
echo "Version=$VERSION" >> /usr/share/applications/firefox-esr.desktop
echo "Encoding=UTF-8" >> /usr/share/applications/firefox-esr.desktop
echo "Name=Mozilla-ESR HOD" >> /usr/share/applications/firefox-esr.desktop
echo "Comment=Suporta applets JAVA, tokens Safenet, StartSign, Aladdin e DXToken " >> /usr/share/applications/firefox-esr.desktop
echo "Exec=/usr/bin/firefox-esr https://hod.serpro.gov.br" >> /usr/share/applications/firefox-esr.desktop
echo "Icon=/OPT/firefox/icons/updater.png" >> /usr/share/applications/firefox-esr.desktop
echo "Type=Application" >> /usr/share/applications/firefox-esr.desktop
echo "Categories=Network" >> /usr/share/applications/firefox-esr.desktop
chmod 644 /usr/share/applications/firefox-esr.desktop
chmod +x /usr/share/applications/firefox-esr.desktop

# (re)cria o gancho/lançador para executar APPLETS java FIREFOX ESR
sh /etc/hookjava1.8.sh

