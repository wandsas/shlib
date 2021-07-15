# ~/lib/json.sh

# Get json value by key
get_value () {
  echo "$1" | jq ".$2"
}
