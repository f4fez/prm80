The Philips/Simoco PRM80 series are professionnal radiocommunication transceivers. This project intended to give a new Firmware EPROM for ham radio use of PRM8060 and PRM8070.

This software in under the terms of the [GNU General Public Licence version 3](http://www.gnu.org/licenses/gpl.html)

You can also visit :

Firmware
========
Main features
-------------
* Firmware for models: [PRM8060](doc/PRM8060.md) and [PRM8070](doc/PRM8070.md)
* Work on VHF and UHF PRMs: [PRM80 available frequency versions](doc/PRM80_bands.md)
* Up to 100 channels. [VHF Channels frequencies](doc/Prm80x0_144.bin.md) - [UHF Channels frequencies](doc/Prm80x0_430.bin.md)
* Power commutation (High/Low)
* Shift for repeaters. Reverse mode available
* [1750 Hz tone](doc/1750Hz_tone.md) generator for repeaters
* [Computer control](doc/Computer_control.md) and channels programming

About PRM80
===========
The family
----------
The PRM80 family is composed of multiple professional mobile radio (PMR) models.

* PRM8010: _Will never be compatible with this firmware_
* PRM8020: _Will never be compatible with this firmware_
* PRM8025: Missing informations. Currently unsuported
* PRM8030: Missing  informations. Currently unsuported
* PRM8040: _Unsuported_
* PRM8041: _Unsuported_
* [PRM8060](doc/PRM8060.md): **Supported**
* PRM8061: **Radio wanted to make the port**
* [PRM8070](doc/PRM8070.md): **Supported**

PRM80 frequencies
=================
The PRM80 family work for many frequencies and have different radio board for each [PRM80 band code](doc/PRM80_bands.md). Look at the [PRM80 band code list](doc/PRM80_bands.md) to know supported version and specific modifications for the ham radio firmware.

Modifications
=============
Frequency independant modification:

* [EPROM update](doc/EPROM_update.md)
* [Connectors informations](doc/Connectors_informations.md)
* [Mike gain](doc/Mike_gain.md)
* [Tx power ajustement](doc/Tx_power_ajustement.md)
* [Serial interface](doc/Computer_control.md)
* [1750 Hz tone](doc/1750Hz_tone.md)
You can also look at the [PRM80 band code list](doc/PRM80_bands.md) to know specific radio board mods.

Firmware Frequencies
--------------------
The firmware is released for 2 ham band depending of the original PRM80 band:

* 2m [prm80x0_144.bin](doc/Prm80x0_144.bin.md)
* 70cm [prm80x0_430.bin](doc/Prm80x0_430.bin.md)

Release
-------
See [Release note](Release note)

[Building it from source](doc/build.md)


Authors
=======
* Florian MAZEN (F4FEZ)
* Pierre COL (F8EGQ)

Acknowledjments
---------------
Within the framework of the realization of this poject we wish to thanks the following ham radio operators:

* Roger MONTEIX (F4EPQ) who obtained an gave us the PRM8060 and different accessories.
* Jean-Claude BENECHE (F1AIA) for the informations on the settings, the measures and the tests.
* Jean-Michel MANARANCHE (F5BVJ) for the tests and the feedback.
* Pierre MAINGUET (F8FHC SK) for the English translation.
* Scott BIGGS (KD0FRN) for translation help / proofreading.
* Manuel JESUS (CT1EWT) for the UHF version

