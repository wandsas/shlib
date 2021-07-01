#!/bin/bash

name=getopt-arg-parse.sh
shell=sh
version=0.1.0

# @FUNCTION: Print help message
usage() {
  cat <<-EOH
  ${name}.${shell} version ${version}
  usage: ${name}.${shell} [OPTIONS]

  -d, --usrdir=usr       USRDIR to use (where to copy BusyBox binary)
  -v, --version=1.20.0   Set version to build instead of latest
  -h, --help, -?         Print the help message and exit
EOH
exit $?
}

die() {
	local ret="${?}"; error "${@}"; exit ${ret}
}

opt="$(getopt \
	-o \?hd:v: \
	-l help,usrdir:,version: \
	-n ${name}.${shell} -s sh -- "${@}" || usage)"
[ ${?} = 0 ] || exit 1
eval set -- ${opt}
while true; do
	case "${1}" in
		(-d|--usrdir) usrdir="${2}"; shift;;
		(-v|--version) vsn="${2}"; shift;;
		(--) shift; break;;
		(-?|-h|--help|*) usage;;
	esac
	shift
done

:	${usrdir:=${PWD}/usr}
pkg=busybox
