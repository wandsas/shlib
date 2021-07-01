#!/bin/sh
.  $HOME/lib/stdout-log.sh
if [ $# -ne 1 ]; then
  error "Illegal number of arguments"
  exit 1
fi

info "Added $1 to ~/docs/lxd.md"
echo "\n### new auto entry ###" >> $HOME/docs/lxd.md
echo $1 >> $HOME/docs/lxd.md
