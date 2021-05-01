.. :hidden:

********************
pwncat documentation
********************

..
  |img_banner|

pwncat is a fully compatible netcat fork written in Python with many more aggressive network features on top.

It comes with a **Python Scripting Engine** (PSE) that allows you to manipulate incoming and outgoing traffic to your needs. This can reach from wrapping current TCP/UDP traffic into higher protocols such as HTTP, FTP, Telnet, etc or even go to encrypting and decrypting your traffic.

Besides regular netcat features like full IPv4, IPv6 and UDP/TCP, IP ToS, port scanning, server/client, bind- and reverse shells, it also comes with pivoting features, ssh-less local and remote port-forwarding, port-hopping, target self-injection and many more.


Contents
========

.. toctree::
   :maxdepth: 3

   installation
   usage

.. toctree::
   :caption: Usage
   :maxdepth: 2

   usage/reverse-shell
   usage/bind-shell
   usage/local-port-forwarding
   usage/remote-port-forwarding
   usage/send-receive-files

.. toctree::
   :caption: Features
   :maxdepth: 2

   pse

.. toctree::
   :caption: Code
   :maxdepth: 2

   code/api
   code/coverage
