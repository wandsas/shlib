#!/bin/bash

name=getopt-arg-parse.sh
shell=sh
version=0.1.0

# Print help message
usage() {
  cat <<-EOH
  ${name}.${shell} version ${version}
  usage: ${name}.${shell} [OPTIONS]

  -d, --usrdir=usr       USRDIR to use for binary/options.skel copy
  -u, --useflag=flags    Set extra USE flags to use
  -v, --version=<str>    Set version to use instead of latest 1.4.x
  -h, --help, -?         Print this help message and and exit
EOH
exit $?
}

opt="$(getopt \
	-o \?hd:u:v: \
	-l help,useflag:,usrdir:,version: \
	-n "${name}.${shell}" -s sh -- "$@" || usage)"
[ ${?} = 0 ] || exit 1
eval set -- ${opt}

while true; do
	case "${1}" in
		(-d|--usrdir) usrdir="${2}"; shift;;
		(-u|--useflag) useflag="${2}"; shift;;
		(-v|--version) vsn="${2}"; shift;;
		(--) shift; break;;
		(-?|-h|--help|*) usage;;
	esac
	shift
done
