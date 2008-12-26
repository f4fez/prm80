@echo off
rem Pour le 8070, modifier la ligne suivante :
set MODELE=8060
if exist prm%MODELE%.bin del prm%MODELE%.bin
if exist prm%MODELE%.lst del prm%MODELE%.lst
if exist prm%MODELE%.hex del prm%MODELE%.hex
cd src
echo Assembling file for the PRM%MODELE% :
if exist prm.a51 asem.exe prm.a51 prm%MODELE%.hex prm%MODELE%.lst /INCLUDES:83C552.MCU /DEFINE:TARGET:%MODELE%
if exist prm%MODELE%.hex hexbin.exe prm%MODELE%.hex /LENGTH:20000 /FILL:FF
if exist prm%MODELE%.bin move prm%MODELE%.bin ..\
if exist prm%MODELE%.lst move prm%MODELE%.lst ..\
if exist prm%MODELE%.hex move prm%MODELE%.hex ..\
cd ..
echo.
dir prm%MODELE%.*
echo.
set MODELE=
pause
 