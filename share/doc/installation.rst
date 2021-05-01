.. |img_lnk_logo_pip| raw:: html

   <a title="Install pwncat on BSD, Linux, MacOS or Windows with Python Pip" target="_blank" href="https://pypi.org/project/pwncat/">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/python.png" />
   </a>

.. |img_lnk_logo_mac| raw:: html

   <a title="Install pwncat on MacOS with homebrew" target="_blank" href="https://formulae.brew.sh/formula/pwncat#default">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/osx.png" />
   </a>

.. |img_lnk_logo_arch| raw:: html

   <a title="Install pwncat on Arch Linux" target="_blank" href="https://aur.archlinux.org/packages/pwncat/">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/archlinux.png" />
   </a>

.. |img_lnk_logo_blackarch| raw:: html

   <a title="Install pwncat on BlackArch" target="_blank" href="https://www.blackarch.org/tools.html">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/blackarch.png" />
   </a>

.. |img_lnk_logo_centos| raw:: html

   <a title="Install pwncat on CentOS" target="_blank" href="https://pkgs.org/download/pwncat">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/centos.png" />
   </a>

.. |img_lnk_logo_fedora| raw:: html

   <a title="Install pwncat on Fedora" target="_blank" href="https://src.fedoraproject.org/rpms/pwncat">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/fedora.png" />
   </a>

.. |img_lnk_logo_kali| raw:: html

   <a title="Install pwncat on Kali Linux" target="_blank" href="https://gitlab.com/kalilinux/packages/pwncat">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/kali.png" />
   </a>

.. |img_lnk_logo_nixos| raw:: html

   <a title="Install pwncat on NixOS" target="_blank" href="https://search.nixos.org/packages?channel=unstable&query=pwncat">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/nixos.png" />
   </a>

.. |img_lnk_logo_oracle| raw:: html

   <a title="Install pwncat on Oracle Linux" target="_blank" href="https://yum.oracle.com/repo/OracleLinux/OL8/developer/EPEL/x86_64/index.html">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/oracle-linux.png" />
   </a>

.. |img_lnk_logo_parrot| raw:: html

   <a title="Install pwncat on Parrot OS" target="_blank" href="https://repology.org/project/pwncat/versions">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/parrot.png" />
   </a>

.. |img_lnk_logo_pentoo| raw:: html

   <a title="Install pwncat on Pentoo" target="_blank" href="https://repology.org/project/pwncat/versions">
     <img src="https://raw.githubusercontent.com/cytopia/icons/master/64x64/pentoo.png" />
   </a>


.. _installation:

************
Installation
************


.. contents:: Table of Contents
   :local:
   :class: local-toc


Generic Installation
====================

``pwncat`` can be installed easily via `pip <https://pypi.org/project/pwncat/>`_ on **BSD**, **Linux**, **MacOS** or **Windows**.


.. list-table::
   :widths: 25
   :header-rows: 1
   :class: install

   * - Pip
   * - |img_lnk_logo_pip|
   * - ``pip install pwncat``


Specific Installation
=====================

Alternatively ``pwncat`` can also be installed with your operating system's package manager of choice.


Linux
-----

.. list-table::
   :widths: 25 25 25 25
   :header-rows: 1
   :class: install

   * - Arch Linux
     - BlackArch
     - CentOS
     - Fedora
   * - |img_lnk_logo_arch|
     - |img_lnk_logo_blackarch|
     - |img_lnk_logo_centos|
     - |img_lnk_logo_fedora|
   * - ``yay -S pwncat``
     - ``pacman -S pwncat``
     - ``yum install pwncat``
     - ``dnf install pwncat``

.. list-table::
   :widths: 25 25 25 25
   :header-rows: 1
   :class: install

   * - Kali Linux
     - NixOS
     - Oracle Linux
     - Parrot OS
   * - |img_lnk_logo_kali|
     - |img_lnk_logo_nixos|
     - |img_lnk_logo_oracle|
     - |img_lnk_logo_parrot|
   * - ``apt install pwncat``
     - ``nixos.pwncat``
     - ``yum install pwncat``
     - ``apt install pwncat``


.. list-table::
   :widths: 25
   :header-rows: 1
   :class: install

   * - Pentoo
   * - |img_lnk_logo_pentoo|
   * - ``net-analyzer/pwncat``


MacOS
-----

.. list-table::
   :widths: 25
   :header-rows: 1
   :class: install

   * - MacOS
   * - |img_lnk_logo_mac|
   * - ``brew install pwncat``


Windows
-------

There is currently no package for Windows, so you are adviced to install it via `pip <https://pypi.org/project/pwncat/>`_. If you want to package it, please contact me.


\*BSD
-----

There is currently no package for \*BSD, so you are adviced to install it via `pip <https://pypi.org/project/pwncat/>`_. If you want to package it, please contact me.



Requirements
============

* Python2 or Python3.


.. note::
     ``pwncat`` only uses Python core libraries and does not have any other dependencies. It is fully compatible starting from Python 2.7 up to the latest Python 3.x version.
