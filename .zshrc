# Set language locale
export LANG=en_US.UTF-8

# Path to python local site-packages.
export PATH=$PATH:$HOME/.local/bin

# Path to Flutter.
export PATH=$PATH:$HOME/flutter/bin

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# ZSH theme.
ZSH_THEME="af-magic"

# Plugins for ZSH. Warning: Too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
    autoswitch_virtualenv
)

# Load oh-my-zsh.
source $ZSH/oh-my-zsh.sh

# Load completions for zsh.
autoload -U compinit && compinit

# Show files/folders vertically and produce a colored output.
alias ls="ls -pA --group-directories-first --color=always"

# Always prompt before removing the file.
alias rm="rm -i"

# Autostart daemon before GPIO test.
alias gpiotest="sudo pigpiod && source $HOME/gpiotest"
