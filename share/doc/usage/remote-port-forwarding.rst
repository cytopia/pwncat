**********************
Remote port forwarding
**********************

Port forwarding is a pivoting feature of pwncat and works without the need of SSH.


How does it work?
=================

Remote port forwarding is a double client proxie or double reverse connection. It works by connecting to the target machine/port and also connects to your listener and then bridging the connection.

**Scenario:**

1. Alice cannot be reached from the Outside
2. Alice is allowed to connect to the Outside (TCP/UDP)
3. Bob can only be reached from Alice's machine
4. pwncat then connects to Bob (on Alice's machine) and also to your listerner

.. code-block:: bash

                              |                               |
        Outside               |           DMZ                 |        private subnet
                              |                               |
                              |                               |
     +-----------------+     TCP     +-----------------+     TCP     +-----------------+
     | The cat         | <----|----- | Alice           | -----|----> | Bob             |
     |                 |      |      | pwncat          |      |      | MySQL           |
     | 56.0.0.1        |      |      | 72.0.0.1:3306   |      |      | 10.0.0.1:3306   |
     +-----------------+      |      +-----------------+      |      +-----------------+
     pwncat -l 4444           |      pwncat --reconn \        |
                              |        -R 56.0.0.1:4444 \     |
                              |        10.0.0.1 3306          |


Examples
========

TCP remote port forwarding
--------------------------

The following example connects to a remote MySQL server (remote port ``3306``) and then connects to another
pwncat/netcat server on 10.0.0.1:4444 and bridges the  traffic.

.. code-block:: bash

   pwncat -R 10.0.0.1:4444 everythingcli.org 3306


UDP remote port forwarding
--------------------------

Same as the TCP example, but convert traffic on your end to UDP

.. code-block:: bash

   pwncat -R 10.0.0.1:4444 everythingcli.org 3306 -u
