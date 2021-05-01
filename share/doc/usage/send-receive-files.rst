**********************
Send and receive files
**********************

Sending and receiving files works in the same way as you would do with netcat.

.. contents:: Table of Contents
   :local:
   :class: local-toc


Send and receive behaviour
==========================

Like the original implementation of ``netcat``, when using TCP, ``pwncat`` (in client and listen mode)
will automatically quit, if the network connection has been terminated, properly or improperly.
In case the remote peer does not terminate the connection, or in UDP mode, ``netcat`` and ``pwncat``
will stay open. The behaviour differs a bit when STDIN is closed.

1. ``netcat``: If STDIN is closed, but connection stays open, netcat will stay open
2. ``pwncat``: If STDIN is closed, but connection stays open, pwncat will close

You can emulate the ``netcat`` behaviour with ``--no-shutdown`` command line argument.

**TL;DR:** When sending and receiving files with ``pwncat`` in TCP mode, both client and server instances will terminate as soon as the file has been transfered.


TCP mode
========

Receiving Listener
------------------

In this example the listening instance of pwncat will receive a file from the connecting instance.

.. code-block:: bash

   # Pipe any data received into a file called output.txt
   pwncat -l 4444 > output.txt

Another pwncat instance will send a local file to the listening instance created above

.. code-block:: bash

   # The file 'some-file.txt' will be send to 10.0.0.1 on port 4444
   pwncat -l 4444 10.0.0.1 < some-file.txt


Sending Listener
----------------

In this example the listening instance of pwncat will send a file to the connecting instance.

.. code-block:: bash

   # Send file 'some-file.txt' to whoever connects to this instance
   pwncat -l 4444 < some-file.txt

Another pwncat instance will connect to it and receive the data into a file.

.. code-block:: bash

   # Connect to 10.0.0.1:4444 and store output in file 'output.txt'
   pwncat -l 4444 10.0.0.1 > output.txt


UDP mode
========

.. note::
   As UDP is a stateless protocol, pwncat is not able to determine when all data has been send or
   received, thus it will stay open, even if data has been completely send.
   You will need to terminate both, the sending and receiving instances manually.

   Also note that UDP is not as reliable as TCP and sending files should rather be done in TCP mode.

Receiving Listener
------------------

In this example the listening instance of pwncat will receive a file from the connecting instance.

.. code-block:: bash

   # Pipe any data received into a file called output.txt
   pwncat -u -l 4444 > output.txt

Another pwncat instance will send a local file to the listening instance created above

.. code-block:: bash

   # The file 'some-file.txt' will be send to 10.0.0.1 on port 4444
   pwncat -u -l 4444 10.0.0.1 < some-file.txt


Sending Listener
----------------

In this example the listening instance of pwncat will send a file to the connecting instance.

.. code-block:: bash

   # Send file 'some-file.txt' to whoever connects to this instance
   pwncat -u -l 4444 < some-file.txt

Another pwncat instance will connect to it and receive the data into a file.

.. code-block:: bash

   # Connect to 10.0.0.1:4444 and store output in file 'output.txt'
   pwncat -u -l 4444 10.0.0.1 > output.txt


FAQ
===

1. Can I send binary data?
--------------------------
   Yes, ``pwncat`` automatically detects if input or output is text-based or binary and sends or receives
   it accordingly without the need to specify it explicitly.

2. Can I mix ``netcat`` and ``pwncat`` while sending and receiving files?
-------------------------------------------------------------------------
   Yes, ``pwncat`` is fully compatible with ``netcat`` and you can for instance receive a file with
   ``pwncat`` which is being send by ``netcat`` or vice versa.
