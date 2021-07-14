# ~/lib/string.sh

# Return the length of a string.
strlen () {
    local length=$(echo "$1" | wc -c | sed -e 's/ *//')
    echo "$(expr $length - 1)"
}

# Check if first string is substring of the second one.
substring () {
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
