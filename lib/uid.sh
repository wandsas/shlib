# ~/lib/uid.sh

### User Verification Tests ### 

# @Test for root permissions
# @Exit when failed
uid_root () {
  if [ `id -u` != 0 ]; then
    echo "Not root; aborting." >&2
    exit 1
  fi
}

# @Test if user is not root
# @Exit when failed
uid_non_root () {
  if [ `id -u` = 0 ]; then
    echo "Must not be root; aborting." >&2
    exit 1
  fi
}
