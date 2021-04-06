#!/usr/bin/env bash

set -e
set -u
set -o pipefail


VERSION="$( curl -sS --fail \
	"https://raw.githubusercontent.com/cytopia/pwncat/master/setup.py" \
	| grep -E '^\s+version=' \
	| awk -F'"' '{print $2}' \
)"


BYTES="$( curl -sS --fail -L \
	"https://github.com/cytopia/pwncat/archive/v${VERSION}.tar.gz" --output - \
	| wc -c \
)"
BLAKE2B="$( curl -sS --fail -L \
	"https://github.com/cytopia/pwncat/archive/v${VERSION}.tar.gz" --output - \
	| python2 -c 'from pyblake2 import blake2b;import sys; print blake2b(sys.stdin.read()).hexdigest()' \
)"
SHA512="$( curl -sS --fail -L \
	"https://github.com/cytopia/pwncat/archive/v${VERSION}.tar.gz" --output - \
	| sha512sum \
	| awk '{print $1}' \
)"

cat <<- EOF
DIST pwncat-${VERSION}.tar.gz ${BYTES} BLAKE2B ${BLAKE2B} SHA512 ${SHA512}
EOF
