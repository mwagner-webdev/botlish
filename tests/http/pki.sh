#!/bin/sh
# pki.sh DIR -- the http package tests' certificates
# (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "Testing"), made by the openssl
# command-line tool (independent of the BoringSSL under test):
#
#   ca.pem             the test CA the tests trust (anchors)
#   good.pem/.key      localhost, 127.0.0.1 and ::1, by the CA, valid now
#   wronghost.pem/.key other.example, by the CA
#   expired.pem/.key   localhost, by the CA, expired in 2021
#   untrusted.pem/.key localhost, by a CA nobody trusts
#   other-ca.pem       that CA
set -eu
dir=$1
mkdir -p "$dir"
cd "$dir"
key() { openssl ecparam -name prime256v1 -genkey -noout -out "$1" 2>/dev/null; }
ca() {
    key "$1.key"
    openssl req -x509 -new -key "$1.key" -sha256 -days 30 -subj "/CN=$2" \
        -addext "basicConstraints=critical,CA:TRUE" -addext "keyUsage=critical,keyCertSign,cRLSign" -out "$1.pem" 2>/dev/null
}
ca ca "Botlish http test CA"
ca other-ca "Untrusted test CA"
cat > ext.cnf <<EOX
[good]
subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
[wrong]
subjectAltName=DNS:other.example
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
EOX
leaf() { # name issuer section
    key "$1.key"
    openssl req -new -key "$1.key" -subj "/CN=$1" -out "$1.csr" 2>/dev/null
    openssl x509 -req -in "$1.csr" -CA "$2.pem" -CAkey "$2.key" -CAcreateserial -days 30 -sha256 \
        -extfile ext.cnf -extensions "$3" -out "$1.pem" 2>/dev/null
}
leaf good ca good
leaf wronghost ca wrong
leaf untrusted other-ca good
# An expired leaf: openssl ca, which can date a certificate in the past.
mkdir -p ca.d/new
: > ca.d/index.txt
echo 01 > ca.d/serial
cat > ca.cnf <<EOX
[ca]
default_ca=test
[test]
dir=ca.d
database=ca.d/index.txt
new_certs_dir=ca.d/new
serial=ca.d/serial
default_md=sha256
policy=any
copy_extensions=none
[any]
commonName=supplied
EOX
key expired.key
openssl req -new -key expired.key -subj "/CN=expired" -out expired.csr 2>/dev/null
openssl ca -batch -config ca.cnf -cert ca.pem -keyfile ca.key -startdate 20210101000000Z -enddate 20210201000000Z \
    -extfile ext.cnf -extensions good -in expired.csr -out expired.pem -notext 2>/dev/null
echo ok
