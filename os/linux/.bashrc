alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

eval "$(starship init bash)"