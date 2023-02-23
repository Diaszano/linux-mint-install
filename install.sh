#!/usr/bin/env bash
# Ping Location
IP_PING=8.8.8.8

# Colors
RED='\e[1;91m'
BLUE='\e[1;34m'
GREEN='\e[1;92m'
ORANGE='\e[1;33m'
NORMAL='\e[0m'
YELLOW='\e[1;93m'


# List of apps
# System
SYSTEM_APPS=(
    git
    htop
    curl 
    wget
    gnupg
    bashtop
    prelink 
    preload
    gnupg-agent 
    lsb-release
    ca-certificates 
    apt-transport-https 
    software-properties-common
)
# Flatpak
FLATPAK_APPS=(
    com.google.Chrome
    com.spotify.Client
    org.telegram.desktop
    com.bitwarden.desktop
    com.sublimetext.three
    com.discordapp.Discord
    rest.insomnia.Insomnia
    com.getpostman.Postman
    com.belmoussaoui.Decoder
    com.github.calo001.fondo
    io.dbeaver.DBeaverCommunity
    com.belmoussaoui.Authenticator
    com.github.muriloventuroso.easyssh
    io.github.mimbrero.WhatsAppDesktop
)

checkInternet(){
if ! ping -c 1 $IP_PING -q &> /dev/null; then
  echo -e "${RED}[ERROR] - Tu não estás conctado a internet.${NORMAL}"
  exit 1
else
  echo -e "${GREEN}[INFO] - Internet conectada.${NORMAL}"
fi
}

update(){
    sudo apt update -y
    flatpak update -y
}

upgrade(){
    sudo apt upgrade -y
}

system_clean(){
    echo -e "${GREEN}[INFO] - Limpando ${NORMAL}"

    update
    sudo apt autoclean -y
    sudo apt autoremove -y

    echo -e "${GREEN}[INFO] - Limpo ${NORMAL}"
}

fullUpdate(){
    echo -e "${GREEN}[INFO] - Atualizando ${NORMAL}"
    update
    upgrade
    echo -e "${GREEN}[INFO] - Atualizado ${NORMAL}"
}

installApt(){
    echo -e "${GREEN}[INFO] - Baixando os aplicativos via APT${NORMAL}"

    for app in ${SYSTEM_APPS[@]}; do
        if ! dpkg -l | grep -q $app; then
            fullUpdate
            sudo apt install "$app" -y
            echo -e "${GREEN}[INFO] - Foi instalado o programa $app.${NORMAL}"
        else
            echo -e "${ORANGE}[INFO] - Já está instalado o programa $app.${NORMAL}"
        fi
    done

    echo -e "${GREEN}[INFO] - Baixado todos os aplicativos via APT${NORMAL}"

}

installFlatPaks(){
    echo -e "${GREEN}[INFO] - Baixando os aplicativos via FlatPak${NORMAL}"
    for app in ${FLATPAK_APPS[@]}; do
        if ! flatpak list | grep -q $app; then
            fullUpdate
            flatpak install flathub "$app" -y
            echo -e "${GREEN}[INFO] - Foi instalado o programa $app.${NORMAL}"
        else
            echo -e "${ORANGE}[INFO] - Já está instalado o programa $app.${NORMAL}"
        fi
    done

    echo -e "${GREEN}[INFO] - Baixado todos os aplicativos via  FlatPak${NORMAL}"
}

installDocker(){
    if ! dpkg -l | grep -q 'docker'; then
        echo -e "${GREEN}[INFO] - Instalando o dockerk${NORMAL}"

        fullUpdate
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable"
        fullUpdate
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

        echo -e "${GREEN}[INFO] - Docker Instalado${NORMAL}"
    else
        echo -e "${ORANGE}[INFO] - O docker já está instalado.${NORMAL}"
    fi

}

installVscode(){
    if ! dpkg -l | grep -q 'code'; then
        echo -e "${GREEN}[INFO] - Instalando o VScode${NORMAL}"

        fullUpdate
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        fullUpdate
        sudo apt install code -y

        echo -e "${GREEN}[INFO] - VScode Instalado${NORMAL}"
    else
        echo -e "${ORANGE}[INFO] - O VScode já está instalado.${NORMAL}"
    fi

}

installPHP(){
    if ! dpkg -l | grep -q 'php'; then
        echo -e "${GREEN}[INFO] - Instalando o PHP${NORMAL}"

        fullUpdate
        sudo add-apt-repository ppa:ondrej/php -y
        fullUpdate
        sudo apt install php8.1 -y
        sudo apt install php8.1-{gd,zip,mysql,oauth,yaml,fpm,mbstring,memcache} -y

        echo -e "${GREEN}[INFO] - PHP Instalado${NORMAL}"
    else
        echo -e "${ORANGE}[INFO] - O PHP já está instalado.${NORMAL}"
    fi
}

configurationPrelink(){
    echo -e "${GREEN}[INFO] - Configurando o prelink${NORMAL}"

    sudo prelink -amR
    sudo sed -i 's/PRELINKING=unknown/PRELINKING=yes/g' /etc/default/prelink
    sudo /etc/cron.daily/prelink
    sudo echo 'DPkg::Post-Invoke {"echo Estamos carregando o Prelink, aguarde um momento…;/etc/cron.daily/prelink";};' >> /etc/apt/apt.conf.d/70debconf

    echo -e "${GREEN}[INFO] - Foi configurado o prelink${NORMAL}"
}

main(){
    echo -e "${BLUE}Olá, nós agora iremos fazer as instalações no seu computador!${NORMAL}"
    echo -e "${BLUE}Mas antes checaremos se tu estás conectado na internet!${NORMAL}"
    checkInternet
    echo -e "${BLUE}Agora faremos as instalações dos teus aplicativos!${NORMAL}"
    installApt
    installDocker
    installVscode
    installPHP
    installFlatPaks
    echo -e "${BLUE}Faremos agora as configurações necessárias!${NORMAL}"
    configurationPrelink
    echo -e "${BLUE}Por fim a limpagem do sistema!${NORMAL}"
    system_clean
    echo -e "${YELLOW}Tchau e até logo!${NORMAL}"
}

main