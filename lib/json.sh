#!/bin/sh

# Get json value by key
#
function get_value {
  echo "$1" | jq ".$2"
}
