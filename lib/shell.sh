# ~/lib/shell.sh

# Are running an interactive session?
is_interactive () {
	case "${-}" in
	  *i*) ;;
		  *) return;;
	esac
}

# Are we running a login shell?
is_login_shell () {
  [ "${SHLVL}" = 1 ]
}

# Are we running a zsh shell?
is_zsh () {
	[ "${ZSH_VERSION}" ]
}

# Are we running a bash shell?
is_bash () {
  [ "${BASH_VERSION}" ]
}
