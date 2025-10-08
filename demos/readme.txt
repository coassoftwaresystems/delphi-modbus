Delphi Modbus library demos
===========================
Demos are available based on the Indy 10 implementation

Vcl:
Demos created in Delphi XE, and should also work on higher Delphi versions. 
For some early Delphi versions, you need to delete *.dproj.

In addition cross platform demos are available:
Lazarus: Demos created using FPC / Lazarus.
FireMonkey: Demos created using FireMonkey on Delphi 13. Targets Win32, Win64 and OSX.


Available demos
===============

Master: 
Implements a simple Modbus master which reads and writes registers from a PLC, or any 
ModbusTCP compatible slave device).

Slave: 
Implements a simple Modbus slave which can be accessed via ModbusTCP and handles 
read and write operations on holding registers.


Compiling and running the demo applications
===========================================
To be able to compile the demos, ensure that the delphimodbus\source folder is
on compiler search path of either the project or the IDE. Without this, the
compiler will not be able to locate the DelphiModbus units.

When you want to compile and run the demos from a Delphi version which differs
from the version it was created in (see above), you should first open each form
in the demo in the form designer, and ignore any errors about missing properties
it might generate. When such message appears, save the modified form afterwards.

After taking these steps into account, the demos can be compiled and run from
the IDE.
