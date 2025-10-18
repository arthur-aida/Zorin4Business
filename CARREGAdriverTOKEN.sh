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
# Script acionado no primeiro login de novos usuários. Ativa os drivers dos tokens no espaço do usuário convencional.
# Cria uma tarefa de limpeza no crontab do usuario convencional.
#-------------------------------------------------------------------------------------------------------------------------------
## Partes deste script são adaptações de fontes disponíveis na internet. 
# Objetivo: preparar os sabores de ?BUNTU e DEBIAN para uso corporativo
# Compilado por arthur.aida@gmail.com
# Arquivos correlacionados em https://drive.google.com/drive/folders/1JU3TpAYm3-7nUWTZ0rGMWjidQbHo_jak?usp=sharing
# https://drive.google.com/drive/folders/187bEL4f0feeYIpuYWtGfd2QIl8orTylp
# Os links dos arquivos citados neste script podem ficar desatualizados. EM CASO DE ERROS PESQUISE O NOVO LINK E ATUALIZE NO SCRIPT.
#

if [ -f /usr/bin/pkcs11-register ]; then
	/usr/bin/pkcs11-register --module=/usr/lib/libeToken.so
	/usr/bin/pkcs11-register --module=/usr/lib/libeTPkcs11.so
	/usr/bin/pkcs11-register --module=/usr/lib/libaetpkss.so
	/usr/bin/pkcs11-register --module=/usr/lib/libIDPrimePKCS11.so
	/usr/bin/pkcs11-register --module=/usr/lib/libDXSafePKCS11.x64.so

#	zenity   --warning --text="TOKENS habilitados! \n O Mozilla reconhecerá tokens GD GEMALTO, SAFENET e novo ALLADIN." --width=450 --height=100
else
	zenity   --warning --text="Instale a aplicação OPENSC para carregar os DRIVERS dos TOKENS! Informe o administrador para que o instale-o." --width=450 --height=100
fi

# Cria uma tarefa de limpeza para o usuário não root, caso não exista ainda
crontab -l > /tmp/TstCRON
isInFile=$(cat /tmp/TstCRON | grep -c "etc/clean.sh")
if [ $isInFile -eq 0 ]; then
	(crontab -l ; echo "20 13 20 */2 * root /etc/clean.sh") | crontab -
fi
rm -f /tmp/TstCRON

