Welcome to the Delphi Modbus library
====================================
The Delphi Modbus library is a Modbus Class I Delphi implementation of a Modbus
master and slave over TCP/IP (ModbusTCP). Serial I/O (RTU or ASCII) is not
supported.


Supported Delphi versions
=========================
The components can be used in Delphi versions 5, 6, 7, 2005, 2006, 2007, 2009,
2010, XE, XE2, XE3, XE4, XE5, XE6, XE7, XE8, 10 Seattle, 10.1 Berlin and 
10.2 Tokyo. The components are based on the Internet Direct (aka 'Indy') 
components, which ship with Delphi versions 6 and up. Only native development 
is supported (no .NET version is available).

For Delphi 5 and 6, you should download the latest Indy version 9.0 from the
Indy website at http://www.indyproject.org/. At the moment of this writing,
9.0.14 is the latest stable release.

Delphi Modbus has been tested with both Indy 9 and 10. For using with Delphi 5,
6 and 7, the usage of Indy9 is the default. For using with Delphi 2005 and
onwards Indy 10 will be used by default. You can overrule the default Indy
version be defining the compile directive FORCE_INDY9 or FORCE_INDY10 in the
package compiler options (To use Indy 10 on Delphi 7 you should first download
the required Indy 10 sources from the Indy project website).

A Delphi 2005 note: the Indy 10 packages which ship with Delphi 2005 are very
old, and DelphiModbus requires them to be replaced by a more recent version
which is available for download from the Indy project website.

Packages are provided and tested for all mentioned Delphi versions, although
full testing occurs only on Delphi 7, 2007 and 10 Seattle (which are my main
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
Delphi version (e.g. DelphiModbus2010.dpk is for Delphi 2010). The lower Delphi
versions have the version number (e.g. DelphiModbus70.dpk is for Delphi 7.0).

To install open the runtime package and the designtime package in the IDE:
 - DelphiModbus<version>.dpk    : The runtime package source
 - dclDelphiModbus<version>.dpk : The designtime package source
Choose 'Compile' for the runtime package, and select 'Install' for the design
time package. Delphi will now report that the components have been installed.

Alternative for this procedure you can also use the Delphi package installer
utility (http://code.google.com/p/delphipi/), which automates this process for
you.


Support for Free Pascal / Lazarus
=================================
The Delphi Modbus components have been successfully installed and tested on
Lazarus 0.9.29 with FPC 2.5.1 on Win32. The package has a dependency on the
Indy 10 package provided by the CodeTyphoon FPC distribution, which should be
installed first (http://www.pilotlogic.com/).


Support
=======
For support on the Delphi Modbus library, please visit the project's website on
GitHub: https://github.com/coassoftwaresystems/delphi-modbus
