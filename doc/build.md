Build from the source code 
==========================
Source code is originaly compiled with ASEM 51 (http://plit.de/asem-51/)
Check if asem51 is correctly installed and binaries are in the system path.

Under Linux
-----------

just type "make" to build the source
    
Under Windows / Dos
-------------------

Make sure asem51 binaries are in the system path, if not, you can also copy asem.exe, hexbin.exe and 83c552.mcu in the "src" directory
 beware of the length of files & directories names ("8.3" DOS names must be used
 
the root of the drive would be a good choice as the main directory).

Run "build.bat"

Build it manualy 
----------------
(Without make or build.bat)

Don't forget to add the TARGET and FREQ constants in the command line.

i.e : "asem -d TARGET:8060 -d FREQ:144 prm.a51"