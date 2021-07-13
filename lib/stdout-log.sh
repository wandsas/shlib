# ~/lib/stdout-log.sh

msg () {
    # bold/yellow
    printf "\033[1m\033[93m=>\033[m $@\n"
}

info () {
    # bold/cyan
    printf "\033[1m\033[96mINFO:\033[m $@\n"
}

warn () {
    # bold/cyan
    printf "\033[1m\033[96mWARNING:\033[m $@\n"
}

error () {
    # bold/red
    printf "\033[1m\033[31mERROR:\033[m $@\n"
}

die () {
    local ret="$?"; error "$@"; exit "$ret"
}
