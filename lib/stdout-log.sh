# ~/lib/stdout-log.sh

### Standard logging utility functions ###

#black="\033[0;90m"
red="\033[0;91m"
green="\033[0;92m"
yellow="\033[0;93m"
blue="\033[0;94m"
#magenta="\033[0;95m"
#cyan="\033[0;96m"
bold="\033[1m"
#underline="\033[4m"
reset="\033[m"

info () {
  printf "${bold}${yellow}INFO:${reset} ${bold}${@}${reset}\n" >&2
}

msg () {
  printf "${bold}${yellow}==>${reset} ${bold}${@}${reset}\n" >&2
}

success () {
  printf "${bold}${green}[${me}:ok]:${reset} ${bold}${@}${reset}\n" >&2
}

begin () {
  printf "${bold}${blue}[BEGIN]${reset} ${bold}${@}${reset}\n" >&2
}

end () {
  printf "${bold}${blue}END${reset} ${bold}${@}${reset}\n" >&2
}

warn () {
	printf "${yellow}WARN:${reset} ${bold}${@}${reset}\n" >&2
}

error () {
	printf "${red}ERROR:${reset} ${bold}${@}${reset}\n" >&2
}

# @Exit after error
die () {
    local ret="$?"; error "$@"; exit "$ret"
}
