#!/bin/bash

##### AC Defesa - 29/05/2024 #####



# Verifica se o usuário é root
if [ "$(id -u)" -eq 0 ]; then

	# Criando diretório sdk-desktop

	if [ -d "/opt/sdk-desktop" ]; then
	    echo "O diretório /opt/sdk-desktop existe."
	else
	    mkdir /opt/sdk-desktop
	fi

	# Copiando arquivos 

	cp ./files/sdk-desktop-1.0.36.jar /opt/sdk-desktop/
	cp ./files/favicon.png /opt/sdk-desktop/
	cp -r ./files/jre/ /opt/sdk-desktop/
	cp ./files/sdk-desktop.sh /usr/local/bin/

	# Variáveis de configuração
	SERVICE_NAME="sdk-desktop"
	SCRIPT_PATH="/usr/local/bin/sdk-desktop.sh"
	DESCRIPTION="Serviço para aplicações web baseados no sdk-desktop da AC Defesa (E-Sec)."
	chmod +x "$SCRIPT_PATH"
	export SCRIPT_PATH

	# Verificar se o script existe

	if [ ! -f "$SCRIPT_PATH" ]; then
	    echo "Erro: O script $SCRIPT_PATH não foi encontrado."
	    exit 1
	fi

	# Ajustar permissões do script para garantir que qualquer usuário possa executá-lo

	sudo chmod +x "$SCRIPT_PATH"

	# Indentificando usuário que fará uso do SDK-Desktop

	echo "Usuários em /home:"
	USERS=()
	INDEX=1

	for USER in /home/*; do
	    if [ -d "$USER" ]; then
		USER_NAME=$(basename "$USER")
		echo "$INDEX. $USER_NAME"
		USERS+=("$USER_NAME")
		((INDEX++))
	    fi
	done

	# Solicita ao usuário que escolha um número
	read -p "Digite o número do usuário desejado: " USER_NUMBER

	# Verifica se o número é válido
	if [[ $USER_NUMBER -gt 0 && $USER_NUMBER -le ${#USERS[@]} ]]; then
	    SELECTED_USER=${USERS[$((USER_NUMBER - 1))]}
	    echo "Você selecionou o usuário: $SELECTED_USER"
	    export SELECTED_USER
	else
	    echo "Número inválido. Saindo..."
	    exit 1
	fi

	# Criar arquivo para execução do serviço

	# Caminho para o arquivo .desktop
	DESKTOP_FILE="/home/$SELECTED_USER/.local/share/applications/sdk-desktop.desktop"

	# Conteúdo do arquivo .desktop
	DESKTOP_CONTENT="[Desktop Entry]
	Name=SDK Desktop
	Comment=Start SDK Desktop Script
	Exec=/usr/local/bin/sdk-desktop.sh
	Icon=/opt/sdk-desktop/favicon.png
	Terminal=true
	Type=Application
	Categories=Utility;"

	# Cria o diretório de destino se não existir
	mkdir -p "$(dirname "$DESKTOP_FILE")"

	# Escreve o conteúdo no arquivo .desktop
	echo "$DESKTOP_CONTENT" > "$DESKTOP_FILE"

	# Define permissões apropriadas para o arquivo .desktop
	chmod 644 "$DESKTOP_FILE"
	chown "$SELECTED_USER" "$DESKTOP_FILE"

	echo "Arquivo sdk-desktop.desktop criado em $DESKTOP_FILE"

	echo "Para iniciar, basta procurar pelo SDK-Desktop no seu Menu de Aplicativos."
	echo "Será aberto um terminal. Enquanto estiver aberta a seção, o SDK-Desktop estará funcionando. Para pará-lo, basta fechar o terminal."
	echo "Para o perfeito funcionamento do SDK-Desktop, instalar o certificado que se encontra na pasta do seu usuário em sdk-web no seu navegador."
	echo "Fim!"

else
    echo "Execute como sudo ou usuário root!"
fi

