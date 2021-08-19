#!/bin/sh
# ./lxc-import.sh -a x86_64 -o Gentoo -r rolling -t stage3-amd64-hardened-nomultilib-selinux-openrc-20210722T095939Z.tar.xz -n gentoo-selinux

prog="$(basename ${0})"
shell="$(basename ${SHELL})"

usage () {
    cat <<-EOH
        Usage: lxc-import.sh [OPTIONS]
        -a, --arch x86_64           Processor type
        -o, --os                    Operating system
        -r, --release     <version> Release
        -p, --properties  <props>   Properties
        -d, --description <descrip> Description
        -t, --tarball     <tarball> Tarball to convert to lxd container
        -h, --help, -?              Print this help message and and exit.
EOH
exit $?
}

ARCH=
OS=
RELEASE=
CREATED="$(date +%s)"
PROPERTIES=
DESCRIPTION=
TARBALL=
ALIAS=

opt=$(getopt -o a:o:r:p:d:t:n:h: \
	-l arch:,os:,release:,properties:,description:,tarball:i,name:,help: -- "$@")
[ ${?} = 0 ] || exit 1
eval set -- ${opt}

while true; do
	case "${1}" in
		(-a|--arch) ARCH=${2}; shift;;
    (-o|--os) OS=${2}; shift;;
		(-r|--release) RELEASE=${2}; shift;;
    (-p|--properties) PROPERTIES=${2}; shift;;
		(-d|--description) DESCRIPTION=${2}; shift;;
    (-t|--tarball) TARBALL=${2}; shift;;
    (-n|--name) ALIAS=${2}; shift;;
		(--) shift; break;;
		(-?|-h|--help|*) usage;;
	esac
	shift
done

cat <<EOF >metadata.yaml
architecture: $ARCH
os: $OS
release: $RELEASE
creation_date: $(date +%s)
properties: $PROPERTIES
description: $DESCRIPTION
EOF
METADATA=

bsdtar -cvf metadata.tar.xz metadata.yaml
lxc image import \
    --alias $ALIAS \
    metadata.tar.xz \
    $TARBALL

rm metadata.yaml metadata.tar.xz

