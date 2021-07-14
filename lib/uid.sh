# ~/lib/uid.sh

# Check if user has root permissions.
uid_root () {
  if [ `id -u` != 0 ]; then
    echo "Not root; aborting." >&2
    exit 1
  fi
}

# Check if current user has no root permissions.
uid_not_root () {
  if [ `id -u` = 0 ]; then
    echo "Must not be root; aborting." >&2
    exit 1
  fi
}
