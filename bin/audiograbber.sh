#!/usr/bin/env sh

. ~/lib/stdout-log.sh

# convert <input.mp3> <output.m4a>
convert () {
    local input="${1}"
    local output="${2}"

    ffmpeg \
        -c:a libfdk_aac \
        -b:a 128k \
        -i "${input}" \
        "${output}"
}



main () {
local i=0
for file in ${HOME}/syncthing/pixel4a/Music/newpipe/*.mp3; do
    local infile="${file}"
    local outfile="${file%.*}.m4a"
    i="$((i+1))"
    
    convert "${infile}" "${outfile}"

    msg "$(i) file: `basename "${infile}"` transcoded to `basename "${outfile}"`"
done

}
main
