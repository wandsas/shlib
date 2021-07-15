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

# Convert all chars to upper case.
upper () {
  tr '[:lower:]' '[:upper:]' <<< "$@"
}

# Convert all chars to lower case.
lower () {
  tr '[:upper:]' '[:lower:]' <<< "$@"
}

# Remove all leading whitespace.
trim () {
  sed -r 's/^\s*(\S)|(\S*)\s*$/\1\2/g' <<< "$@"
}
