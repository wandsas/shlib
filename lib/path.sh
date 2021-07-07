# ~/lib/path.sh

# Append element at the end of the path
appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

# Prepend element before the rest of the path
prependpath () {
  case ":$PATH:" in
    *":$1:"*) ;;
           *) PATH="$1${PATH:+:$PATH}";;
  esac
}

# Red Hat path helper function
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

# Remove element from PATH
pathremove () {
    if [[ -n "$ZSH_VERSION" ]]; then
	    path=(${path#$1})
	else
        PATH=$(echo ${PATH} | sed -e 's;:\?$%{1};;' -e 's;${1}:\?;;')
    fi
}

# Convert path from relative to absolut
relative2absolut () {
  echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

# print directories in $PATH, one per line
print_path () {
    local -a dirs
    IFS=: read -ra dirs <<< "$PATH"
    for dir in "${dirs[@]}"; do
        printf '%s\n' "$dir"
    done
}

# Binary checker helper
check_bin () {
    type -P ${1} &>/dev/null || return
}
