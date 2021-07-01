# ~/lib/shell.sh

### Shell Utility functions ###

# @Test if we are running an interactive session
is_interactive () {
	case "${-}" in
	  *i*) ;;
		  *) return;;
	esac
}

# @Test if we are running a login shell
is_login_shell () {
  [ "$SHLVL" = 1 ]
}

# @Test if we are running a zsh shell
is_zsh () {
	[ -n "$ZSH_VERSION" ]
}

# @Test if we are running a bash shell
is_bash () {
  [ -n $BASH_VERSION ]
}
