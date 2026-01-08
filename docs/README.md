Welcome to the Delphi Modbus library
====================================
The Delphi Modbus library is a Modbus Class I Delphi implementation of a Modbus
master and slave over TCP/IP (ModbusTCP). Serial I/O (RTU or ASCII) is not
supported.


Supported Delphi versions
=========================
The components can be used in Delphi versions 2007 and higher. The components 
are based on the Internet Direct (aka 'Indy') components, which ship with 
Delphi.

Packages are provided and tested for all mentioned Delphi versions, although
full testing occurs only on 2007, XE3 and the latest version (which are my main
Delphi versions for production use). I expect that the Delphi 2006 packages will
work with Turbo Delphi 2006 (Pro) as well, although this has not been tested.

Starting with Delphi XE2, Delphi targets multiple platforms (Win32, Win64 and
32-bit OSX). The components have been tested to work on all support platforms
(in combination with the FireMonkey framework). Starting with XE4, the mobile
versions are also supported (iOS and Android).

Installation in the Delphi IDE
==============================
To install the components in Delphi, identify the packages for your Delphi
version: the 'year' Delphi versions have packages ending in the year of the
Delphi version (e.g. DelphiModbus2010.dpk is for Delphi 2010).

To install open the runtime package and the designtime package in the IDE:
 - DelphiModbus<version>.dpk    : The runtime package source
 - dclDelphiModbus<version>.dpk : The designtime package source
Choose 'Compile' for the runtime package, and select 'Install' for the design
time package. Delphi will now report that the components have been installed.


Support for Free Pascal / Lazarus
=================================
The Delphi Modbus components have been successfully installed and tested on
Lazarus 4.2 with FPC 3.2.2 on Win64.
Lazarus support is a community effort and is not including in standard testing.
Please feel free to submit a pull request to improve it! 


Support
=======
For support on the Delphi Modbus library, please visit the project's website on
GitHub: https://github.com/coassoftwaresystems/delphi-modbus
