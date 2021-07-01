# ~/lib/string.sh

### String/Parser functions ###

strlen () {
    local length=$(echo "$1" | wc -c | sed -e 's/ *//')
    echo "$(expr $length - 1)"
}

string_in_file () {
	case "$(cat $2)" in
		*$1*) return 0;;
		   *) return 1;;
	esac
}

string_in_string () {
	case "$2" in
		*$1*) return 0;;
		   *) return 1;;
	esac
}

upper () {
  tr '[:lower:]' '[:upper:]' <<< "$@"
}

lower () {
  tr '[:upper:]' '[:lower:]' <<< "$@"
}

trim () {
  sed -r 's/^\s*(\S)|(\S*)\s*$/\1\2/g' <<< "$@"
}
