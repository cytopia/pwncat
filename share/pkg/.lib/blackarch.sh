#!/usr/bin/env bash

set -e
set -u
set -o pipefail


VERSION="$( curl -sS --fail \
	"https://raw.githubusercontent.com/cytopia/pwncat/master/setup.py" \
	| grep -E '^\s+version=' \
	| awk -F'"' '{print $2}' \
)"


SHA512="$( curl -sS --fail -L \
	"https://github.com/cytopia/pwncat/archive/v${VERSION}.tar.gz" --output - \
	| sha512sum \
	| awk '{print $1}' \
)"


cat <<- EOF
# This file is part of BlackArch Linux ( https://www.blackarch.org/ ).
# See COPYING for license details.

pkgname=pwncat
pkgver=${VERSION}
pkgrel=1
groups=('blackarch' 'blackarch-backdoor' 'blackarch-scanner' 'blackarch-proxy'
        'blackarch-networking')
pkgdesc='Bind and reverse shell handler with FW/IDS/IPS evasion, self-inject and port-scanning.'
url='http://pwncat.org/'
license=('MIT')
arch=('any')
depends=('python')
source=("\$pkgname-\$pkgver.tar.gz::https://github.com/cytopia/\$pkgname/archive/v\$pkgver.tar.gz")
sha512sums=('${SHA512}')

package() {
  cd "\$pkgname-\$pkgver"

  install -Dm 755 bin/\$pkgname "\$pkgdir/usr/bin/\$pkgname"
  install -Dm 644 man/\$pkgname.1 -t "\$pkgdir/usr/share/man/man1"
  install -Dm 644 LICENSE.txt "\$pkgdir/usr/share/licenses/\$pkgname/LICENSE"
  install -Dm 644 README.md CHANGELOG.md -t "\$pkgdir/usr/share/doc/\$pkgname/"

  cp --no-preserve=ownership -a pse "\$pkgdir/usr/share/doc/\$pkgname/"
}

EOF
