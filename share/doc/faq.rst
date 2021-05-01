***
FAQ
***

.. contents:: Table of Contents
   :local:
   :class: local-toc



General
=======

How to install pwncat?
----------------------
   `pwncat <https://github.com/cytopia/pwncat>`_ is available on most Linux distributions (e.g. Kali Linux), on MacOS via `homebrew <https://formulae.brew.sh/formula/pwncat>`_ and via `pip <https://pypi.org/project/pwncat/>`_.
   See :doc:`installation` for detailed instructions.


Does pwncat work on Linux?
--------------------------
   Yes, with Python2 or Python3

Does pwncat work on MacOS?
--------------------------
   Yes, with Python2 or Python3

Does pwncat work on Windows?
----------------------------
   Yes, with Python2 or Python3

Does pwncat work on \*BSD?
--------------------------
   Yes, with Python2 or Python3


Terminology
===========

What is pwncat?
---------------
   `pwncat <https://github.com/cytopia/pwncat>`_ is a sophisticated bind and reverse shell handler with many features as well as a drop-in replacement or compatible complement to netcat , ncat or socat.

   It comes with a Python Scripting Engine (PSE) that allows you to manipulate incoming and outgoing traffic to your needs. This can reach from wrapping current TCP/UDP traffic into higher protocols such as HTTP, FTP, Telnet, etc or even go to encrypting and decrypting your traffic.


What is netcat?
---------------
   netcat is a computer networking utility for reading from and writing to network connections using TCP or UDP. The command is designed to be a dependable back-end that can be used directly or easily driven by other programs and scripts. At the same time, it is a feature-rich network debugging and investigation tool, since it can produce almost any kind of connection its user could need and has a number of built-in capabilities. `[1] <https://en.wikipedia.org/wiki/Netcat>`_


What is a reverse shell?
------------------------
   A reverse shell is a type of shell that is initiated from a victim's computer to connect with attacker's computer. Once the connection is established, it allows attacker to send over commands to execute on the victim's computer and to get results back. `[2] <https://triagingx.com/img/website_images/resource_images/776444019_detectreverseshell.pdf>`_


What is a bind shell?
---------------------
   A bind shell is a type of shell in which the target machine opens up a communication port or a listener on the victim machine and waits for an incoming connection. The attacker then connects to the victim machine’s listener which then leads to code or command execution on the server. `[3] <https://irichmore.wordpress.com/2015/06/04/bind-shell-vs-reverse-shell/>`_
