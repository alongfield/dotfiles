#!/bin/sh

LSD_VERSION="1.1.5"
K9S_VERSION="0.32.5"
ASDF_VERSION="0.14.1"
K8S_VERSION="1.30"

sudo echo Starting

for i in p10k.zsh tool-versions vim vimrc zlogin zlogout zpreztorc zprofile zshenv zshrc
do
  rm -f $HOME/.$i
  ln -s $HOME/dotfiles/$i $HOME/.$i
done

git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto

cd $HOME/.vim/plugged
git submodule update --recursive

if [[ "$OSTYPE" == "darwin"* ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  brew install berkeley-db coreutils curl docker fzf gcc git git-extras grep gnutls httpie jq lz4 lzo ncurses openssl openssl@1.1 screen sqlite tmux wget xz zsh
  brew install awscli bat dive docutils gh go groff htop helm iterm2 k9s lsd postman slack telnet the-unarchiver vim visual-studio-code vlc
  brew install font-awesome-terminal-fonts font-fira-code font-fira-code-nerd-font font-fira-mono font-fontawesome

  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write com.apple.screencapture disable-shadow -bool true
  defaults write NSGlobalDomain AppleFontSmoothing -int 2

  launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

  sudo git clone https://github.com/asdf-vm/asdf.git /usr/local/opt/asdf --branch v${ASDF_VERSION}
  sudo chmod +x /usr/local/opt/asdf/asdf.sh
fi

if [[ "$OSTYPE" == "linux-gnu" ]]
then
  if grep -q "ID=ubuntu" /etc/os-release
  then
    sudo apt install -y bat git wget curl jq apt-transport-https vim links ca-certificates
    sudo ln -s /usr/bin/batcat /usr/bin/bat

    sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
    sudo apt-add-repository https://cli.github.com/packages

    sudo apt update
    sudo apt install -y kubectl helm gh

    curl -fsSLo lsd.deb https://github.com/Peltoche/lsd/releases/download/${LSD_VERSION}/lsd-musl_${LSD_VERSION}_amd64.deb
    sudo apt install ./lsd.deb
    rm -f lsd.deb

    curl -s -L https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz -o - | tar -zxf - k9s
    sudo chown root:root k9s
    sudo mv k9s /usr/local/bin/k9s

    sudo apt install -y build-essential libffi-dev make libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip zsh vim

    sudo git clone https://github.com/asdf-vm/asdf.git /usr/local/opt/asdf --branch v${ASDF_VERSION}
    sudo chmod +x /usr/local/opt/asdf/asdf.sh
  fi

  if [ -e /usr/sbin/pacman ]
  then
    sudo pacman -Syu

    sudo pacman -S git
    git clone https://aur.archlinux.org/yay-git.git $HOME/yay-git
    cd $HOME/yay-git
    makepkg -si

    sudo pacman -S base-devel
    yay -S less asdf-vm bat lsd jq yq helm k9s krew-bin kubectl links net-tools openssh p7zip unzip awesome-terminal-fonts wget curl zsh vim inetutils net-tools github-cli

    sudo mkdir -p /usr/local/opt
    sudo ln -s /opt/asdf-vm /usr/local/opt/asdf
    sudo chown root:root /usr/local/opt /usr/local/opt/asdf
  fi
fi

kubectl krew install modify-secret tail

mkdir -p $HOME/.config/k9s
ln -s $HOME/dotfiles/k9s/plugins.yaml $HOME/.config/k9s/plugins.yaml

/usr/local/opt/asdf/bin/asdf plugin add awscli https://github.com/MetricMike/asdf-awscli.git
/usr/local/opt/asdf/bin/asdf plugin add istioctl https://github.com/virtualstaticvoid/asdf-istioctl.git
/usr/local/opt/asdf/bin/asdf plugin add java https://github.com/halcyon/asdf-java.git
/usr/local/opt/asdf/bin/asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
/usr/local/opt/asdf/bin/asdf plugin add maven https://github.com/halcyon/asdf-maven.git
/usr/local/opt/asdf/bin/asdf plugin add mc https://github.com/penpyt/asdf-mc.git
/usr/local/opt/asdf/bin/asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
/usr/local/opt/asdf/bin/asdf plugin add python https://github.com/danhper/asdf-python.git
/usr/local/opt/asdf/bin/asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
/usr/local/opt/asdf/bin/asdf plugin add rust https://github.com/code-lever/asdf-rust.git
/usr/local/opt/asdf/bin/asdf plugin add terraform https://github.com/Banno/asdf-hashicorp.git
/usr/local/opt/asdf/bin/asdf install
