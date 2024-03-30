# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Load ZSH autocompletes
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# asdf tool version manager
. /usr/local/opt/asdf/asdf.sh

# use the correct editor
alias vi='vim'
export EDITOR=vim
export VISUAL=vim

# modern spins of classic tools
alias ls='lsd'
alias cat='bat'

# kubernetes convenience aliases
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/go/bin:$PATH"

alias k='kubectl'
alias kg='k get'
alias kd='k describe'
alias kns='k config set-context $(kubectl config current-context) --namespace '
alias kgp='kg pods'
alias kdp='kd pod'
alias kexec='k exec -ti '
alias kgn='kg nodes'
alias klog='k logs'
alias kdebug='k run debug --image ubuntu:latest -ti --rm=true'

# Drift kubernetes envs
alias kqaloam='k config use-context qa-loam'
alias kqam='k config use-context qa-messaging'
alias kqa='k config use-context qa-main'
alias kqacentral='k config use-context qa-central'

alias kprodm='k config use-context prod-messaging'
alias kprod='k config use-context prod-main'
alias kprodcentral='k config use-context prod-central'

alias kops='k config use-context ops-main'

alias k9s='k9s --namespace $(kubectl config view --minify -o jsonpath='{..namespace}')'

# If we're on Linux then create clipboard aliases
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  function pbcopy() {
    if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ] || uname -r | grep -qi "microsoft"; then
      tee <&0 | clip.exe
    else
      xclip -selection clipboard
    fi
  }

  function pbpaste() {
    if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ] || uname -r | grep -qi "microsoft"; then
      powershell.exe -noprofile -command "Get-Clipboard"
    else
      xclip -selection clipboard -o
    fi
  }
fi

# Drift credstash implementation
function update_credstash {
  # ops account
  if [ `aws --version|cut -f2 -d/|cut -f1 -d.` -ge 2 ]
  then
    aws --profile ops --region us-east-1 ecr get-login-password | docker login --username AWS --password-stdin 227298829890.dkr.ecr.us-east-1.amazonaws.com
  else
    $(aws --profile ops --region us-east-1 ecr get-login | sed 's/-e none //') 2>&1 | grep -v 'password-stdin'
  fi
  local img="227298829890.dkr.ecr.us-east-1.amazonaws.com/credstash"

  docker pull "${img}"
  docker tag "${img}" credstash:latest
}

function credstash {
  docker run -it --rm -v "$HOME/.aws/credentials:/root/.aws/credentials" credstash "$@"
}

# iTerm2 integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [ -e /usr/local/bin/fixdns.sh ]; then sudo /usr/local/bin/fixdns.sh; fi

if [[ $(pwd) != "$HOME" ]]
then
    cd $HOME
fi

# powerleve10k setup
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
