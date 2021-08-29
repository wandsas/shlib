# stdout-log.sh

msg () {
    # bold/black
    printf "\033[1m\033[90m=>\033[m $@\n"
}

boldtext () {
    # bold
    printf "\033[1m$@\033[m\n"
}

info () {
    # bold/black
    printf "\033[1m\033[90mINFO:\033[m $@\n"
}

warn () {
    # bold/orange
    printf "\033[1m\033[92mWARNING:\033[m $@\n"
}

error () {
    # bold/red
    printf "\033[1m\033[31mERROR:\033[m $@\n"
}

die () {
    local ret="$?"; error "$@"; exit "$ret"
}
