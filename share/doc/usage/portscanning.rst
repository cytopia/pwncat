*************
Port Scanning
*************


TCP Port Scan
=============

The following examples scan TCP ports for both, IPv4 and IPv6:

.. code-block:: bash

   # scan ports by selection: 80, 443 and 8080
   pwncat -z 10.0.0.1 80,443,8080

   # scan ports by range: 1-65535
   pwncat -z 10.0.0.1 1-65535

   # scan ports by increment: 1+1023 (1 and the next 1023 ports)
   pwncat -z 10.0.0.1 1+1024


UDP Port Scan
=============

The following examples scan UDP ports (``-u``) for both, IPv4 and IPv6:

.. code-block:: bash

   # scan ports by selection: 80, 443 and 8080
   pwncat -z 10.0.0.1 80,443,8080 -u

   # scan ports by range: 1-65535
   pwncat -z 10.0.0.1 1-65535 -u

   # scan ports by increment: 1+1023 (1 and the next 1023 ports)
   pwncat -z 10.0.0.1 1+1024 -u


IPv4 or IPv6 Port Scan
======================

By default the port scanning will scan for both, IPv4 and IPv6. If you want to explicitly scan either of them only, you can append either ``-4`` or ``-6``. This works for TCP and UDP.


.. code-block:: bash

   # scan IPv4 ports only
   pwncat -z 10.0.0.1 80,443,8080 -4

   # scan IPv6 ports only
   pwncat -z 10.0.0.1 80,443,8080 -6


Version detection
=================

``pwncat`` also supports basic version detection by grabbing the and parsing the banner of a listening service (``--banner``). This of course is not as accurate as ``nmap``'s version detection as it does not do any fingerprinting, but for basic detection works moderately well.

.. code-block:: bash

   # Port scan and detect running versions
   pwncat -z 10.0.0.1 80,443,8080 --banner


UDP Scan Performance
====================

In UDP mode ``pwncat`` is insanely fast detecting open ports compared to other scanners.


.. note::
   Due to its aggressively fast scanning behaviour, pwncat sometimes might give false
   positive results when detecting open UDP ports.

The following ports are exposed
-------------------------------

.. code-block:: bash

   $ sudo netstat -ulpn
   Active Internet connections (only servers)
   Proto Recv-Q Send-Q Local Address           Foreign Address
   udp        0      0 0.0.0.0:631             0.0.0.0:*
   udp        0      0 0.0.0.0:5353            0.0.0.0:*
   udp        0      0 0.0.0.0:39856           0.0.0.0:*
   udp        0      0 0.0.0.0:68              0.0.0.0:*
   udp        0      0 0.0.0.0:68              0.0.0.0:*
   udp6       0      0 :::1053                 :::*
   udp6       0      0 :::5353                 :::*
   udp6       0      0 :::57728                :::*

nmap performance
----------------

.. code-block:: bash

   $ time sudo nmap -T5 localhost --version-intensity 0 -p- -sU
   Starting Nmap 7.70 ( https://nmap.org ) at 2020-05-24 17:03 CEST
   Warning: 127.0.0.1 giving up on port because retransmission cap hit (2).
   Nmap scan report for localhost (127.0.0.1)
   Host is up (0.000035s latency).
   Other addresses for localhost (not scanned): ::1
   Not shown: 65529 closed ports
   PORT      STATE         SERVICE
   68/udp    open|filtered dhcpc
   631/udp   open|filtered ipp
   1053/udp  open|filtered remote-as
   5353/udp  open|filtered zeroconf
   39856/udp open|filtered unknown
   40488/udp open|filtered unknown

   Nmap done: 1 IP address (1 host up) scanned in 179.15 seconds

   real    2m52.446s
   user    0m0.844s
   sys     0m2.571s

netcat performance
------------------

.. code-block:: bash

   $ time nc  -z localhost 1-65535  -u -4 -v
   Connection to localhost 68 port [udp/bootpc] succeeded!
   Connection to localhost 631 port [udp/ipp] succeeded!
   Connection to localhost 1053 port [udp/*] succeeded!
   Connection to localhost 5353 port [udp/mdns] succeeded!
   Connection to localhost 39856 port [udp/*] succeeded!

   real    0m18.734s
   user    0m1.004s
   sys     0m2.634s

pwncat performance
------------------

.. code-block:: bash

   $ time pwncat -z localhost 1-65535 -u -4
   Scanning 65535 ports
   [+]    68/UDP open   (IPv4)
   [+]   631/UDP open   (IPv4)
   [+]  1053/UDP open   (IPv4)
   [+]  5353/UDP open   (IPv4)
   [+] 39856/UDP open   (IPv4)

   real    0m7.309s
   user    0m6.465s
   sys     0m4.794s
