#!/bin/sh

LSD_VERSION="0.20.1"
K9S_VERSION="0.25.18"
ASDF_VERSION="0.8.1"

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

    sudo apt install -y https://github.com/Peltoche/lsd/releases/download/v${LSD_VERSION}/lsd-musl_${LSD_VERSION}_amd64.deb

    curl -s -L https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz -o - | tar -zxf - k9s
    sudo chown root:root k9s
    sudo mv k9s /usr/local/bin/k9s
fi

sudo apt install -y build-essential libffi-dev make libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

sudo git clone https://github.com/asdf-vm/asdf.git /usr/local/opt/asdf --branch v${ASDF_VERSION}
/usr/local/opt/asdf/bin/asdf plugin add java https://github.com/halcyon/asdf-java.git
/usr/local/opt/asdf/bin/asdf plugin add maven https://github.com/halcyon/asdf-maven.git
/usr/local/opt/asdf/bin/asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
/usr/local/opt/asdf/bin/asdf plugin add python https://github.com/danhper/asdf-python.git
/usr/local/opt/asdf/bin/asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
/usr/local/opt/asdf/bin/asdf plugin add terraform https://github.com/Banno/asdf-hashicorp.git
/usr/local/opt/asdf/bin/asdf install

cat $HOME/.tool-versions | while read line
do
   /usr/local/opt/asdf/bin/asdf global $line
done
