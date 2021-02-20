This is the description of the computer commands for the [version 4](https://github.com/f4fez/prm80/blob/doc/Release%20note.md) firmware. See also the [computer interface](Computer_control.md) for hardware and communication parameters.

Memory description
==================
The PRM80 use different kind of memory:

* Program memory is the 27C010 EPROM that contain the firmware.
* I2C EEPROM save configuration parameters like channels frequencies and original states. Content is saved for years.
* External 32Kb RAM have a capacitor to hold the content for some weeks without power. This memory is used for:
  Saving the current system state (Last channel, squelch...). The first 2Kb contain a copy of the EEPROM.
  Use as internal buffer for serial communication.
* Internal CPU RAM and registers are used by the system. Functions are available for debugging but should not be used in other case.

During the boot, the RAM memory is checked. If the content is invalid (First start or long power cut), data is loaded from the EEPROM. If data is also invalid in the EEPROM (First start), the data is loaded from the program memory with default values.

During service, only the RAM data is modified for storing the current channel, squelch value, reverse mode... This is usefull to restore the last channel when turning on the radio.
When altering the RAM, the checksum is automaticaly computed for common functions (Except for direct RAM write "M"). 

When programming channels from the computer interface, only the RAM is modified. So you can rollback your modification ("S" command) for copying the EEPROM to the RAM. Or you can save it from the RAM to the EEPROM ("X" command) to be sure that your parameters will be restored if the RAM is altered (Long power cut)

System variable bits
====================
Mode byte
---------
This general variable hold the state of system basic features.

* b0: Squelch mode is displayed on LCD if true. Channel mode if false.
* b1: Power level (High or Low mode)
* b2: Squelch open (Read only)
* b3: TX mode (Read only)
* b4: PLL locked (Read only)
* b5: Long key push (Internal)
* b6: Key bounce (Internal)
* b7: Force LCD refresh when set. Automaticaly cleared.

Channel state byte
------------------
This channel state byte is set for each channel at programming.

* b0: Shift enable when true
* b1: Reverse mode when true
* b2: Positive shift when true. Negative if false
* b3: Scanning locked out channel if set
* b4: 
* b5: 
* b6: 
* b7:

Lock byte
---------
Used to disabled user controls when connected to a computer

* b0: Keys disabled when true
* b1: TX disabled when true
* b2: Volume button disabled when true
* b3: RX disabled when true
* b4: 
* b5: 
* b6: 
* b7:

List of commands
================
0: Reset
---------
CPU reset

1: Show 80c552 port state P1
----------------------------
Display the value on the internal CPU port P1. Used for debuging.

2 : Show 80c552 port state P2
----------------------------
Display the value on the internal CPU port P2. Used for debuging.

3: Show 80c552 port state P3
----------------------------
Display the value on the internal CPU port P3. Used for debuging.

4: Show 80c552 port state P4
----------------------------
Display the value on the internal CPU port P4. Used for debuging.

5: Show 80c552 port state P5
----------------------------
Display the value on the internal CPU port P5. Used for debuging.

C: Print channels list
----------------------
List all saved channel. Print channel number, frequency and channel statebyte.

D: Set "Mode" byte
------------------
Set the system "Mode" byte. Used for debugging.

E: Show system state
--------------------
This command display the following internal variables :

* Mode byte
* Channel number
* Channel state
* Squelch level
* Volume level
* Lock byte
* Current RX PLL word (2 bytes)
* Current TX PLL word (2 bytes
This is intended to be used by a non human device.

F: Set squelch
--------------
Set the squelch level. The value uses decimal encoding between 00 and 15.

H: Print help page
------------------
Display the list of available command.

I: System initialisation
------------------------
Force memory initialisation. Restore RAM and EEPROM from data in program memory.

K: Set lock byte
----------------
Set the lock bits. The value uses hexadecimal encoding. The lock bits disable some functionalities. Usefull to disable front command when the radio is controled from the computer.

L: Print latch state
--------------------
Display the state of the internal IO latch. Use for debbug only.

M: Edit external RAM manualy
----------------------------
Edit the external RAM. Use for debug only.

N: Set current channel
----------------------
Switch the radio to the given channel. The channel number uses a decimal encoding between 00 and 99.

O: Set volume
-------------
Set the volume. The value uses decimal encoding between 00 and 15.

Before volume setting can be done remotely, the command has to be locked (See "K" command).

P: Edit/Add channel
-------------------
This is the main function for editing a channel. Set the RX frequency as PLL word and the channel status byte. 

To add a new channel, choose a not existing channel (i.e. 99). The next available number will be used.

Q: Set channels number
----------------------
This command set the total number of channel. Since there is no channel delete function. It is possible to reduce the number of channels. Increasing the number of channel is hazardous, use the "P" function instead.

R: Set synthetiser frequencies
------------------------------
This command set the PLL words for RX and TX frequency. This function do not modify channels parameters. This is usefull for hardware check.

U: Print 80c552 internal RAM
----------------------------
Display the content of the internal RAM memory. Used for debgging only.

S: Copy EEPROM to external RAM
------------------------------
This command force the RAM data to be remplaced by the EEPROM data. Can be used as rollback when configuring.

T: Set current channel state
----------------------------
Change the current channel state byte. This function do not change the saved value in RAM or EEPROM.

V: Print firmware version
-------------------------
Print the current firmware version and device.

X: Copy external RAM to EEPROM
------------------------------
This command is used to save to the RAM to the EEPROM. After RAM modification, use this command to save parameters

Warn: This command do not compute the checksum. In case of invalid checksum in the EEPROM, the data will be erased and replaced by the configuration from the program memory at boot.

Y: Print the content of the I2C 24c16 EEPROM
--------------------------------------------
Display the EEPROM. The size is 2Kb.

Z: Print external RAM ($0000 to $07FF)
--------------------------------------
Display the first 2kb of the RAM. This aera is loaded from the EEPROM at boot if needed.
