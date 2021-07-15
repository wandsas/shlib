# ~/lib/stdout-log.sh

msg () {
    # bold/yellow
    printf "\033[1m\033[93m=>\033[m %s\n" "$*"
}

info () {
    # bold/yellow
    printf "\033[1m\033[93mINFO:\033[m %s\n" "$*"
}

warning () {
    # bold/orange
    printf "\033[1m\033[94mWARNING:\033[m %s\n" "$*"
}

error () {
    # bold/red
    printf "\033[1m\033[31mERROR:\033[m %s\n" "$*"
}

die () {
    local ret="$?"; error "$*"; exit "$ret"
}
