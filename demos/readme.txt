Delphi Modbus library demos
===========================
Demos are available based on Indy 9 and Indy 10 implementation

Indy9: Demos created in Delphi 7, and should also work on Delphi 5 and 6.
       (to open under earlier Delphi versions: delete *.dof).
Indy10: Demos created in Delphi XE, and should also work on higher Delphi versions.
        (to open under earlier Delphi versions: delete *.dproj).

In addition cross platform demos are available:
Lazarus: Demos created using FPC / Lazarus.
FireMonkey: Demos created using FireMonkey on Delphi XE2. Targets Win32, Win64
            and OSX.

Available demos:

Master: Implements a simple Modbus master which reads and writes registers from
        a PLC.
Slave: Implements a simple Modbus slave which can be accessed via ModbusTCP and
       handles read and write operations on holding registers.


Compiling and running the demo applications
===========================================
Seperate demos are provided based on both Indy 9 and Indy 10. The Indy 9 demos
have been created in Delphi 7, whilst the Indy 10 demos have been created in
Delphi 2010. By default DelphiModbus is based on Indy 10 for Delphi versions
from 2005 and up (older versions are set to use Indy 9).

To be able to compile the demos, ensure that the delphimodbus\source folder is
on compiler search path of either the project or the IDE. Without this, the
compiler will not be able to locate the DelphiModbus units.

When you want to compile and run the demos from a Delphi version which differs
from the version it was created in (see above), you should first open each form
in the demo in the form designer, and ignore any errors about missing properties
it might generate. When such message appears, save the modified form afterwards.

After taking these steps into account, the demos can be compiled and run from
the IDE.
