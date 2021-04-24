*********************
Local port forwarding
*********************

Port forwarding is a pivoting feature of pwncat and works without the need of SSH.


How does it work?
=================

**Scenario:**

1. Alice can be reached from the Outside (TCP/UDP)
2. Bob can only be reached from Alice's machine
3. pwncat makes Bob's MySQL server available on Alice's machine

.. code-block:: bash

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

Examples
========

TCP remote port forwarding
--------------------------

The following examples makes a remote MySQL server (remote port ``3306``) available on current machine
on every interface on port ``5000``

.. code-block:: bash

   pwncat -L 0.0.0.0:5000 everythingcli.org 3306


UDP remote port forwarding
--------------------------

The following examples makes a remote MySQL server (remote port ``3306``) available on current machine
on every interface on port ``5000`` and converts traffic on the pwncat listening side to UDP.

.. code-block:: bash

   pwncat -L 0.0.0.0:5000 everythingcli.org 3306 -u
