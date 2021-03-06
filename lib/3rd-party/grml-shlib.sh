#!/bin/sh
# Filename:      grml-shlib.sh
# Purpose:       Shellscript library
# Authors:       grml-team (grml.org), (c) Michael Gebetsroither <gebi@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2.
################################################################################

# VARIABLES {{{
VERBOSE__=0
VERBOSE_TMP__=0

# FIXME maybe PROG_PATH__ for better error reporting?
PROG_NAME__=""    # initialised within init section

# directory for init scripts
INITD_DIR__="/etc/init.d/"

# >= level and the function will print the message
EPRINT__=1    # eprint (error print)
EEPRINT__=2   # 2print (intern error print)
DPRINT__=3    # dprint (debug print)

EXIT_FUNCTION__="_syslog"    # function to call upon die (can be set by user)

SYSLOG__="YES"

CMD_LINE__=""   # /proc/cmdline

LANG__="$LANG"
LC_ALL__="$LC_ALL"
LANGUAGE__="$LANGUAGE"
# }}}

# CONFIG FUNCTIONS  {{{

setProgName() { PROG_NAME__="$1"; }

setExitFunction() { EXIT_FUNCTION__="$1"; }

disableSyslog() { SYSLOG__="NO";  }
enableSyslog() { SYSLOG__="YES"; }

saveLang() { LANG__="$LANG"; LC_ALL__="$LC_ALL"; LANGUAGE__="$LANGUAGE"; }
restoreLang() { LANG="$LANG__"; LC_ALL="$LC_ALL__"; LANGUAGE="$LANGUAGE__"; }
setCLang() { saveLang; LANG="C"; LC_ALL="C"; LANGUAGE="C"; }
# }}}

# DEBUG FRAMEWORK  {{{

setVerbose()     { VERBOSE__=${1:-1}; }
unsetVerbose()   { VERBOSE_TMP__=$VERBOSE__; VERBOSE__=0; }
restoreVerbose() { VERBOSE__=$VERBOSE_TMP__; }
getVerbose()     { echo "$VERBOSE__"; }

setDebug()       { setVerbose "$DPRINT__"; }
unsetDebug()     { restoreVerbose; }

setExitFunction()    { EXIT_FUNCTION__="$1"; }
resetExitFunction()  { EXIT_FUNCTION__="_syslog"; }
# }}}

# ERROR REPORTING FUNCTIONS  {{{

# default print backend (there may be other functions)
vprint()
{
  local level_="$1"
  local type_="$2"
  local message_="$3"

  if [ "$VERBOSE__" -ge "$level_" -a -n "$message_" ]; then
    echo -n "$type_" >&2
    echo "$message_" >&2
  fi
}

# print error output
eprint()
{
  # FIXME vprint should be a var, because we want to call user-defined functions
  # global var (there should be a syslog, and vprint + syslog function)
  vprint $EPRINT__ "Error - " "$1"
}

# should be used for intern silentExecutes
eeprint()
{
  vprint $EEPRINT__ "  Error2 - " "$1"
}

# print debug output (function intern errors)
dprint()
{
  vprint $DPRINT__ "Debug - " "$1"
}

# for program notice messages
notice()
{
  vprint $EPRINT__ "Notice - " "$1"
}

die()
{
  local error_message_="$1"   # print this error message
  local exit_code_="$2"  # command exited with this exit code

  echo -n "PANIC: $error_message_" >&2
  if [ -n "$2" ]; then
    echo "; ret($exit_code_)" >&2
  else
    echo >&2
  fi

  if [ -n "$EXIT_FUNCTION__" ]; then
    $EXIT_FUNCTION__ "$error_message_" "$exit_code_" >&2
  fi
  kill $$
}

warn()
{
  local error_message_="$1"   # print this error message
  local exit_code_="$2"  # command exits with this exit code

  echo -n "WARN: $error_message_" >&2
  if [ -n "$exit_code_" ]; then
    echo "; ret($exit_code_)" >&2
  else
    echo >&2
  fi
}

_syslog()
{
  local message_="$1"   # error message
  local exit_code_="$2"

  if [ "$SYSLOG__" = "YES" ]; then
    if [ -n "$exit_code_" ]; then
      logger -p user.alert -t "$PROG_NAME__" -i "$message_ ret($exit_code_)" >&2
    else
      logger -p user.alert -t "$PROG_NAME__" -i "$message_" >&2
    fi
  fi
}

syslog()
{
  local message_="$1"   # error message
  local exit_code_="$2"

  if [ -n "$exit_code_" ]; then
    logger -p user.alert -t "$PROG_NAME__" -i "$message_ ret($exit_code_)" >&2
  else
    logger -p user.alert -t "$PROG_NAME__" -i "$message_" >&2
  fi
}

warnLog()
{
  local error_message_="$1"   # print this error message
  local exit_code_="$2"  # command exits with this exit code

  warn "$error_message_" "$exit_code_"
  syslog "$error_message_" "$exit_code_"
}
# }}}

# CORE FUNCTIONS {{{

##
# ATTENTION... THIS FUNCTION IS A BIG SECURITY HOLE
# this function will be changed in future release
##
# I don't want to write exit status control stuff every time
execute()
{
  local to_exec_="$1"   # command to execute
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"   # user supplied error message

  local ret_=''

  # NOT A GOOD IDEA
  eval "$to_exec_"
  ret_=$?

  if [ $ret_ -eq 127 ]; then
    syslog "problems executing ( $to_exec_ )" $ret_
  fi
  if [ $ret_ -ne 0 ]; then
    if [ -z "$message_" ]; then
      $error_function_ "problems executing ( $to_exec_ )" "$ret_"
    else
      $error_function_ "$message_" "$ret_"
    fi
  fi
  dprint "exec-$error_function_: ( $to_exec_ ) ret($ret_)"
  return $ret_
}

silentExecute()
{
  unsetVerbose
  execute "$@"
  local ret_=$?
  restoreVerbose
  return $ret_
}


###
#
# TEST FUNCTIONS
#
###

# if the file DOES exist, everything is fine
isExistent()
{
  local file_to_test_="$1"    # file to test
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"    # user supplied error message

  if [ ! -e "$file_to_test_" ]; then
    if [ -z "$message_" ]; then
      $error_function_ "file does not exist \"$file_to_test_\"" 66
    else
      $error_function_ "$message_"
    fi
    return 1
  fi
  dprint "isExistent(): file \"$1\" does exist => ready to go"
  return 0
}

isNotExistent()
{
  local file_to_test_="$1"    # file to test
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"    # user supplied error message

  if [ -e "$file_to_test_" ]; then
    if [ -z "$message_" ]; then
      $error_function_ "file does already exist \"$file_to_test_\"" 67
    else
      $error_function_ "$message_"
    fi
    return 1
  fi
  dprint "isNotExistent(): file \"$1\" does not exist => ready to go"
  return 0
}


checkUser()
{
  local to_check_="$1"    # username to check against running process
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"    # user supplied error message

  local user_=''

  user_=`id -un`
  if [ $user_ != "$to_check_" ]; then
    if [ -z "$message_" ]; then
      $error_function_ "username \"$user_\" is not \"$to_check_\"" 77 $exit_function_
    else
      $error_function_ "$message_"
    fi
    return 1
  else
    dprint "checkUser(): accepted, username matches \"$to_check_\""
    return 0
  fi
}

checkId()
{
  local to_check_="$1"    # user-id to check against running process
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"    # user supplied error message

  local user_id_=''

  user_id_=$(id -u)
  if [ "$user_id_" != "$to_check_" ]; then
    if [ -z "$message_" ]; then
      $error_function_ "UID \"$user_id_\" is not \"$to_check_\"" 77
    else
      $error_function_ "$message_"
    fi
    return 1
  else
    dprint "checkId(): accepted, UID matches \"$to_check_\""
    return 0
  fi
}

checkRoot()
{
  checkId 0 "$1" "$2"
}

isGrml()
{
  if [ -f /etc/grml_version ] ; then
    dprint "isGrml(): this seems to be a grml system"
    return 0
  else
    dprint "isGrml(): this is not a grml system"
    return 1
  fi
}

runsFromHd()
{
  if [ -e "/etc/grml_cd" ]; then
    dprint "runsFromHd(): grml is on CD"
    return 1
  else
    dprint "runsFromHd(): grml is on HD"
    return 0
  fi
}

runsFromCd()
{
  if [ -e "/etc/grml_cd" ]; then
    dprint "runsFromCd(): grml is on CD"
    return 0
  else
    dprint "runsFromCd(): grml is on HD"
    return 1
  fi
}


# secure input from console
secureInput()
{
  local to_secure_="$1"

  local secured_=''

  secured_=`echo -n "$to_secure_" |tr -c '[:alnum:]/.\-,\(\)' '_'`
  dprint "secureInput(): \"$to_secure_\" => \"$secured_\""
  echo "$secured_"
}


# convert all possible path formats to absolute paths
relToAbs()
{
  local relpath_="$1"
  local abspath_=''

  abspath_="`readlink -f \"$relpath_\"`" || \
    warn "relToAbs(): Problems getting absolute path" "$?" || return 1
  dprint "relToAbs(): \"$relpath_\" => \"$abspath_\""
  echo "$abspath_"
}


# Trim off white-space characters
# white-space in the "C" and "POSIX" locales are:
#   space
#   form-feed ('\f')
#   newline ('\n')
#   carriage return ('\r')
#   horizontal tab ('\t')
#   vertical tab ('\v')
stringTrim()
{
  local str_="$1"
  local result_=""

  result_="`echo "$str_" | sed -e 's/^\s*//' -e 's/\s*$//'`" || \
    warn "stringTrim(): Problems stripping of blanks" || return 1
  dprint "stringTrim(): \"$str_\" => \"$result_\""
  echo "$result_"
}

# Simple shell grep
stringInFile()
{
  local to_test_="$1"   # matching pattern
  local source_="$2"    # source-file to grep

  if [ ! -e "$source_" ]; then
    eprint "stringInFile(): \"$source_\" does not exist"
    return 1
  fi

  case "$(cat $source_)" in *$to_test_*) return 0;; esac
  return 1
}

# same for strings
stringInString()
{
  local to_test_="$1"   # matching pattern
  local source_="$2"    # string to search in

  case "$source_" in *$to_test_*) return 0;; esac
  return 1
}

# get value for bootparam given as first param
getBootParam()
{
  local param_to_search_="$1"
  local result_=''

  stringInString " $param_to_search_=" "$CMD_LINE__" || return 1
  result_="${CMD_LINE__##*$param_to_search_=}"
  result_="${result_%%[   ]*}"
  echo "$result_"
  return 0
}

# Check boot commandline for specified option
checkBootParam()
{
  stringInString " $1" "$CMD_LINE__"
  return "$?"
}
# }}}

# NETWORK  {{{

# validates an IP FIXME
netValidIp()
{
  local ip_="$1"    # ip address to validate
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"    # user supplied error message

  local ret_=''

  echo "$ip_" | grep -E -q -e '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.[0-9]{1,3}' \
    1>/dev/null 2>&1
  ret_=$?
  if [ $ret_ -ne 0 ]; then
    if [ -z "$message_" ]; then
      "$error_function_" "ip-address \"$ip_\" is NOT valid" $ret_
    else
      "$error_function_" "$message_" $ret_
    fi
    return 1
  fi

  dprint "ip-address \"$ip_\" is valid" $ret_
  return $ret_
}

netGetIfaces()
{
  local error_function_=${1:-"eprint"}    # function to call on error
  local message_="$2"    # user supplied error message
  local if_=''
  local ret_=''

  #ip a|grep 'inet ' |awk '$NF !~ /lo/{print $NF}'
  if_="`ip a|grep 'inet ' |awk '{print $NF}'`"
  ret_=$?
  if [ -z "$if_" ]; then
    if [ -z "$message_" ]; then
      "$error_function_" "no interfaces found" $ret_
    else
      "$error_function_" "$message_" $ret_
    fi
    return 1
  fi
  dprint "interfaces found" $ret_
  echo "$if_"
}

# FIXME
netGetDefaultGateway()
{
  local error_function_=${1:-"eprint"}    # function to call on error
  local message_="$2"    # user supplied error message

  local ip_=''
  local ret_=''

  setCLang
  ip_=`route -n | awk '/^0\.0\.0\.0/{print $2; exit}'`
  ret_=$?
  restoreLang
  if [ -z "$ip_" ]; then
    if [ -z "$message_" ]; then
      "$error_function_" "no default gateway found" $ret_
    else
      "$error_function_" "$message_" $ret_
    fi
    return 1
  fi
  dprint "default gateway is \"$ip_\"" $ret_
  echo "$ip_"
  return 0
}

# FIXME
netGetNetmask()
{
  local iface_="$1"
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"    # user supplied error message

  local nm_=''
  local ret_=''

  setCLang
  if ifconfig "$iface_" | grep -qi 'Mask:' ; then # old ifconfig output:
    nm_=$(ifconfig "$iface_" | awk '/[Mm]ask/{FS="[:   ]*"; $0=$0; print $8; exit}')
  else # new ifconfig output (net-tools >1.60-27):
    nm_=$(ifconfig "$iface_" | awk '/netmask/{print $4}')
  fi
  ret_=$?
  restoreLang
  if [ -z "$nm_" ]; then
    if [ -z "$message_" ]; then
      "$error_function_" "could not find a netmask for \"$iface_\"" $ret_
    else
      "$error_function_" "$message_" $ret_
    fi
    return 1
  fi
  dprint "netmask on \"$iface_\" is \"$nm_\"" $ret_
  echo "$nm_"
  return 0
}

# FIXME
netGetIp()
{
  local iface_="$1"
  local error_function_=${2:-"eprint"}    # function to call on error
  local message_="$3"    # user supplied error message

  local ip_=""
  local ret_=""

  setCLang
  ip_=$(ip addr show dev "$iface_" | awk '/inet /{split($2,a,"/"); print a[1]}')
  ret_=$?
  restoreLang
  if [ -z "$ip_" ]; then
    if [ -z "$message_" ]; then
      "$error_function_" "no ip for \"$iface_\" found" $ret_
    else
      "$error_function_" "$message_" $ret_
    fi
    return 1
  fi
  dprint "address for \"$iface_\" is \"$ip_\"" $ret_
  echo "$ip_"
  return 0
}

netGetNameservers()
{
  local error_function_=${1:-"eprint"}    # function to call on error
  local message_="$2"    # user supplied error message

  local file_="/etc/resolv.conf"
  local ns_=""

  if [ ! -e $file_ ]; then
    warn "file \"$file_\" does not exist, could not get nameservers"
    return 1
  fi

  setCLang
  ns_=`awk '/^nameserver/{printf "%s ",$2}' $file_ |xargs echo`
  restoreLang
  if [ -z "$ns_" ]; then
    if [ -z "$message_" ]; then
      "$error_function_" "no nameservers found" $ret_
    else
      "$error_function_" "$message_" $ret_
    fi
    return 1
  fi
  dprint "nameservers: \"$ns_\"" $ret_
  echo "$ns_"
  return 0
}

# }}}

# SERVICES {{{
_touchService()
{
  local action_="${1:-"start"}"
  local service_="$2"
  local error_function_=${3:-"eprint"}    # function to call on error
  local message_="$4"     # user supplied error message

  local i=""
  local known_action_='false'
  for i in "start" "stop" "restart" "reload" "force-reload"; do
    if [ "$i" = "$action_" ]; then
      known_action_='true'
      break
    fi
  done
  $known_action_ || warn "_touchService(): unknown action \"$action_\""


  local service_path_=""
  service_path_="${INITD_DIR__}/$service_"
  if [ ! -e "$service_path_" ]; then
    warn "_touchService(): service does not exist: \"$service_\""
    return 1
  fi
  if [ ! -x "$service_path_" ]; then
    warn "_touchService(): service is not executable: \"$service_\""
  fi

  local ret_=""
  "$service_path_" "$action_"
  ret_=$?
  if [ "$ret_" != "0" ]; then
    if [ -z "$message_" ]; then
      "$error_function_" "Problems ${action_}ing service \"$service_\"" $ret_
    else
      "$error_function_" "$message_" $ret_
    fi
    return 1
  fi
  dprint "_touchService(): successfully started service \"$service_\""
  return 0
}

_createServiceFunctions()
{
  for i in "start" "stop" "restart" "reload"; do
    eval "${i}Service() { _touchService ${i} \"\$1\" \"\$2\" \"\$3\"; }"
  done
  eval "forceReloadService() { _touchService force-reload \"\$1\" \"\$2\" \"\$3\"; }"
}
_createServiceFunctions
# }}}

# LOSETUP HELPER FUNCTION {{{
# print next free /dev/loop* to stdout
findNextFreeLoop()
{
  local error_function_=${1:-"eprint"}    # function to call on error
  local message_="$2"    # user supplied error message

  local tmp_=''   # tmp
  local i=''      # counter
  local ret_=''   # saved return value

  for i in 'losetup' 'losetup.orig'; do
    tmp_=`$i -f 2>/dev/null`
    if [ $? -eq 0 ]; then
      echo $tmp_
      return 0
    fi
  done

  # we have to search
  dprint 'findNextFreeLoop(): losetup does not recognice option -f, searching next free loop device'
  for i in `seq 0 100`; do
    test -e /dev/loop$i || continue
    losetup /dev/loop$i >/dev/null 2>&1
    ret_=$?
    case "$ret_" in
      2) continue ;;  # losetup could not get status of loopdevice (EPERM)
      0) continue ;;  # device exist
      1) echo "/dev/loop$i"; return 0 ;;  # device does not exist and no error
      ?) continue ;;  # return value not available in 'man losetup'
    esac
  done

  # hmm... could not find a loopdevice
  if [ -z "$message_" ]; then
    $error_function_ "could not find a free loop device"
  else
    $error_function_ "$message_"
  fi
  return 1
}
# }}}

# INIT {{{

_initProgName()
{
  local name_="$1"    # program name

  local tmp_name_=`basename "$name_"` || \
    logger -p user.alert -i "Init-initProgName: problems executing ( basename \"$name_\" ) ret($?)" >/dev/null

  secureInput "$tmp_name_"
}
PROG_NAME__=`_initProgName "$0"`


_checkExecutables()
{
  local tmp_=""
  for i in tr dirname basename id logger kill cat grep route awk ifconfig; do
    which $i >/dev/null 2>&1 || tmp_="${tmp_}$i "
  done
  if [ -n "$tmp_" ]; then
    eprint "Init-checkExecutables: following executables not found or not executable:\n$tmp_"
    #syslog "Init-checkExecutables: following executables not found or not executable: $tmp_"
  fi
}
_checkExecutables


_checkBootParam()
{
  local path_="/proc/cmdline"
  if [ -e "$path_" ]; then
    CMD_LINE__=`execute "cat $path_" warnLog`
    return 0
  fi
  warnLog "$path_ does not exist, thus sh-lib may not work reliable!"
  return 1
}
_checkBootParam

_setDebugLevel()
{
  # accept only integer as arguments
  if echo "$DEBUG" | grep -E -q '^[0-9]+$' ; then
    local debug_="${DEBUG:-0}"
  else
    local debug_="0"
  fi
  VERBOSE__="$debug_"
}
_setDebugLevel
# }}}

# END OF FILE
################################################################################
# vim:foldmethod=marker expandtab shiftwidth=2 tabstop=2
