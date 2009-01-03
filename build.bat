@echo off

cd src

if exist 8060_144.bin del 8060_144.bin > nul
if exist 8060d144.bin del 8060d144.bin > nul
if exist 8070_144.bin del 8070_144.bin > nul
if exist 8070d144.bin del 8070d144.bin > nul
if exist 8060_430.bin del 8060_430.bin > nul
if exist 8060d430.bin del 8060d430.bin > nul
if exist 8070_430.bin del 8070_430.bin > nul
if exist 8070d430.bin del 8070d430.bin > nul

if not exist asem.exe   goto absent
if not exist hexbin.exe goto absent
if not exist 83c552.mcu goto absent

if exist prm.a51 asem.exe prm.a51 8060_144.hex 8060_144.lst /INCLUDES:83C552.MCU /DEFINE:TARGET:8060 /DEFINE:FREQ:144
if exist prm.a51 asem.exe prm.a51 8070_144.hex 8070_144.lst /INCLUDES:83C552.MCU /DEFINE:TARGET:8070 /DEFINE:FREQ:144
if exist prm.a51 asem.exe prm.a51 8060_430.hex 8060_430.lst /INCLUDES:83C552.MCU /DEFINE:TARGET:8060 /DEFINE:FREQ:430
if exist prm.a51 asem.exe prm.a51 8070_430.hex 8070_430.lst /INCLUDES:83C552.MCU /DEFINE:TARGET:8070 /DEFINE:FREQ:430

if exist 8060_144.hex hexbin.exe 8060_144.hex 8060d144.bin > nul
if exist 8060_144.hex hexbin.exe 8060_144.hex 8060_144.bin /LENGTH:20000 /FILL:FF > nul
if exist 8070_144.hex hexbin.exe 8070_144.hex 8070d144.bin > nul
if exist 8070_144.hex hexbin.exe 8070_144.hex 8070_144.bin /LENGTH:20000 /FILL:FF > nul
if exist 8060_430.hex hexbin.exe 8060_430.hex 8060d430.bin > nul
if exist 8060_430.hex hexbin.exe 8060_430.hex 8060_430.bin /LENGTH:20000 /FILL:FF > nul
if exist 8070_430.hex hexbin.exe 8070_430.hex 8070d430.bin > nul
if exist 8070_430.hex hexbin.exe 8070_430.hex 8070_430.bin /LENGTH:20000 /FILL:FF > nul

if exist 8060_144.hex del 8060_144.hex > nul
if exist 8070_144.hex del 8070_144.hex > nul
if exist 8060_430.hex del 8060_430.hex > nul
if exist 8070_430.hex del 8070_430.hex > nul

if exist 8060_144.lst del 8060_144.lst > nul
if exist 8070_144.lst del 8070_144.lst > nul
if exist 8060_430.lst del 8060_430.lst > nul
if exist 8070_430.lst del 8070_430.lst > nul

dir 80?0????.bin

echo.
echo If no error has occured, 8 binary files should have been created :
echo.
echo - files "8060xxxx.bin" are for the PRM8060 versions.
echo - files "8070xxxx.bin" are for the PRM8070 versions.
echo - files "xxxxx144.bin" are for the VHF versions.
echo - files "xxxxx430.bin" are for the UHF versions.
echo - files "xxxx_xxx.bin" are binaries for the 27C010 (128 kB).
echo - files "xxxxdxxx.bin" are the same binaries for smaller eproms.
goto fin

:absent
echo.
echo Error ! some assembler files seem to be missing...
echo ensure all the following files are present in the SRC directory :
echo - ASEM.EXE 
echo - HEXBIN.EXE
echo - 83C552.MCU

:fin
echo.
cd ..
pause
