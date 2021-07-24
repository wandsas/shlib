# ~/lib/path.sh

# Append element at the end of the path.
append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

# Prepend element before the rest of the path.
prepend_path () {
  case ":$PATH:" in
    *":$1:"*) ;;
           *) PATH="$1${PATH:+:$PATH}";;
  esac
}

# Red Hat's path helper function.
pathmunge () {
	if ! echo $path | grep -qE "(^|:)$1($|:)"
	then
        if [[ "$2" = "after" ]]; then
            path=(${path} $1)
        else
            path=($1 $path)
        fi
  fi
}

# Remove specified element from path.
path_remove () {
    if [ "$ZSH_VERSION" ]; then
	    path=(${path#$1})
	else
        PATH=$(echo ${PATH} | sed -e 's;:\?$%{1};;' -e 's;${1}:\?;;')
    fi
}

# Convert path from relative to absolut.
relative2absolut () {
  echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

# Binary checker helper.
check_bin () {
    type -P ${1} &>/dev/null || return
}

# Print path, one entry per line.
print_path () {
    local -a dirs
    IFS=: read -ra dirs <<< "$PATH"
    for dir in "${dirs[@]}"; do
        printf '\033[0;94m\033[1m=>\033[m %s\n' "$dir"
    done
}
