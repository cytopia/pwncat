#!/usr/bin/env bash

set -e
set -u
set -o pipefail


VERSION="$( curl -sS --fail \
	"https://raw.githubusercontent.com/cytopia/pwncat/master/setup.py" \
	| grep -E '^\s+version=' \
	| awk -F'"' '{print $2}' \
)"

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"


URL="$( curl -sS --fail \
	-A "${UA}" "https://pypi.org/project/pwncat/${VERSION}/" \
	-H "cache-control: no-cache" \
	-H "dnt: 1" \
	-H "pragma: no-cache" \
	-H "accept-language: en-US,en;q=0.9,de;q=0.8" \
	-H "accept-encoding: deflate, br" \
	-H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" \
	| grep -Eo 'https://files\.pythonhosted\..+?tar.gz' \
)"
SHA256="$( curl -sS "${URL}" | sha256sum | awk '{print $1}' )"

cat <<- EOF
class Pwncat < Formula
  include Language::Python::Virtualenv

  desc "Netcat with FW/IDS/IPS evasion, self-inject-, bind- and reverse shell"
  homepage "https://pwncat.org"
  url "${URL}"
  sha256 "${SHA256}"
  license "MIT"
  head "https://github.com/cytopia/pwncat.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "3858b6511e81b5b8cee59724213d438f042f3cc80e3d87fb4eaa7df6771dd326"
    sha256 cellar: :any_skip_relocation, big_sur:       "4c25ffa0c2a969ee67ecbb252c841471c5ea9e2ce87e581c130ec800db482b51"
    sha256 cellar: :any_skip_relocation, catalina:      "192c19f127e900be34ca58bc3b7dec8b2fae412e53d2613396233f9e3fbb6123"
    sha256 cellar: :any_skip_relocation, mojave:        "5eedc0f7cdfa07a82325e09c5a3bc37e7250ad1fc87f48062c99a3a21f5964ac"
    sha256 cellar: :any_skip_relocation, high_sierra:   "9448463d98056aa3b6049f00261fea896e2a16712407f8c10fdf61d9d82dd61b"
  end

  depends_on "python@3.9"

  def install
    ENV.prepend_path "PATH", Formula["python@3.9"].opt_libexec/"bin"
    virtualenv_install_with_resources
  end

  test do
    system "echo HEAD  | #{bin}/pwncat www.google.com 80 | grep ^HTTP"
  end
end
EOF
