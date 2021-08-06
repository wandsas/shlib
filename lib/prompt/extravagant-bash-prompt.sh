# Extravagant bash prompt

# http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
extravagant_bash_prompt () {
    if tput setaf 1 &> /dev/null; then
        tput sgr0
        if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
            MAGENTA=$(tput setaf 9)
            ORANGE=$(tput setaf 172)
            GREEN=$(tput setaf 190)
            PURPLE=$(tput setaf 141)
            WHITE=$(tput setaf 256)
        else
            MAGENTA=$(tput setaf 5)
            ORANGE=$(tput setaf 4)
            GREEN=$(tput setaf 2)
            PURPLE=$(tput setaf 1)
            WHITE=$(tput setaf 7)
        fi
        BOLD=$(tput bold)
        RESET=$(tput sgr0)
    else
        MAGENTA="\033[1;31m"
        ORANGE="\033[1;33m"
        GREEN="\033[1;32m"
        PURPLE="\033[1;35m"
        WHITE="\033[1;37m"
        BOLD=""
        RESET="\033[m"
    fi

    PS1="\[${BOLD}${MAGENTA}\]\u \[${WHITE}\]at \[${ORANGE}\]\h \[${WHITE}\]in \[${GREEN}\]\w\[${WHITE}\]\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" on\")\[${PURPLE}\]\$(__git_ps1 \" (%s)\")\[${WHITE}\]\n» \[${RESET}\]"

    unset MAGENTA ORANGE GREEN PURPLE WHITE BOLD RESET
}

PROMPT_COMMAND="extravagant_bash_prompt; $PROMPT_COMMAND"
