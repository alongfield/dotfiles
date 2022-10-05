#!/bin/sh

LSD_VERSION="0.23.1"
K9S_VERSION="0.26.6"
ASDF_VERSION="0.10.2"

sudo echo Starting

for i in p10k.zsh tool-versions vim vimrc zlogin zlogout zpreztorc zprofile zshenv zshrc
do
    rm -f $HOME/.$i
    ln -s $HOME/dotfiles/$i $HOME/.$i
done

git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto

cd $HOME/.vim/plugged
git submodule update --recursive

if [ `lsb_release -i -s` = "Ubuntu" ]
then
    sudo apt install -y bat git wget curl jq apt-transport-https vim links ca-certificates
    sudo ln -s /usr/bin/batcat /usr/bin/bat

    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

    sudo apt update
    sudo apt install -y kubectl helm

    curl -fsSLo lsd.deb https://github.com/Peltoche/lsd/releases/download/${LSD_VERSION}/lsd-musl_${LSD_VERSION}_amd64.deb
    sudo apt install ./lsd.deb
    rm -f lsd.deb

    curl -s -L https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz -o - | tar -zxf - k9s
    sudo chown root:root k9s
    sudo mv k9s /usr/local/bin/k9s

    sudo apt install -y build-essential libffi-dev make libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip zsh vim

    sudo git clone https://github.com/asdf-vm/asdf.git /usr/local/opt/asdf --branch v${ASDF_VERSION}
fi

if [ -e /usr/sbin/pacman ]
then
    pacman -Syu

    pacman -S git
    git clone https://aur.archlinux.org/yay-git.git $HOME/yay-git
    cd $HOME/yay-git
    makepkg -si

    sudo pacman -S base-devel
    yay -S asdf-vm bat lsd jq yq helm k9s krew-bin kubectl links net-tools openssh p7zip unzip awesome-terminal-fonts wget curl zsh vim inetutils net-tools

    sudo mkdir -p /usr/local/opt
    sudo ln -s /opt/asdf-vm /usr/local/opt/asdf
    sudo chown root:root /usr/local/opt /usr/local/opt/asdf
fi

/usr/local/opt/asdf/bin/asdf plugin add awscli https://github.com/MetricMike/asdf-awscli.git
/usr/local/opt/asdf/bin/asdf plugin add java https://github.com/halcyon/asdf-java.git
/usr/local/opt/asdf/bin/asdf plugin add maven https://github.com/halcyon/asdf-maven.git
/usr/local/opt/asdf/bin/asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
/usr/local/opt/asdf/bin/asdf plugin add python https://github.com/danhper/asdf-python.git
/usr/local/opt/asdf/bin/asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
/usr/local/opt/asdf/bin/asdf plugin add terraform https://github.com/Banno/asdf-hashicorp.git
/usr/local/opt/asdf/bin/asdf install
