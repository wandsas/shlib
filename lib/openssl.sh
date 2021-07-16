
generate_keypair () {
    openssl req -nodes -x509 -sha256 \
        -newkey rsa:4096 \
        -keyout "$(whoami).key" \
        -out "$(whoami).crt" \
        -days 365 \
        -subj "/C=DE/ST=Germay/L=Frankfurt/OU=ITDept/CN=$(whoami) signing key"
}

sign () {
    openssl dgst -sha256 -sign "$(whoami).key" -out "${1}.sha256" "${1}"
}

verify () {
    openssl dgst -sha256 -verify  <(openssl x509 -in "$(whoami).crt" \
        -pubkey -noout) -signature ${1}.sha256 ${1}
}
