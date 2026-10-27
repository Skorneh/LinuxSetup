# ~/.bashrc — managed by the LinuxSetup repo (dotfiles/bash/.bashrc).
# Edit this file and the change is already in the repo, ready to commit.

# Only run for interactive shells.
[[ $- != *i* ]] && return

# Our own tools (force-quit, power-menu, rice-theme…) live here.
PATH="$HOME/.local/bin:$PATH"

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize

PS1='\[\e[1;34m\]\u@\h\[\e[0m\] \[\e[1;32m\]\w\[\e[0m\] \$ '

alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'

# System updates (official repos + AUR).
alias update='paru -Syu'
# Remove packages nothing depends on anymore.
alias cleanup='pacman -Qdtq | sudo pacman -Rns -'
# Show installed packages that aren't in the repo's package lists yet.
alias pkgcheck='~/LinuxSetup/scripts/check-packages.sh'
