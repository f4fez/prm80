Hardware interface
==================
The link with a computer can be done in two different places. First by the microphone plug on the front end of the transciever (see schematics of the cabling of the microphone above).Then by the DB15 plug at the back of the apparatus. In both cases it is the level of a TTL (0,5V). This one has to be necessarily adapted to the level RS232 of the PC(-12V, +12V) at the risc to destroy the radio, for that one has to use the mouting based upon the classic MAX232. Bellow is an example of the schematics of the cabling of a MAX232, for the interfacing with a PC through the DB15 plug.
[](Db15_interface.png)

Requiered PC software
=====================
This PRM80 firmware does not require a specific PC software. You can use any serial terminal program to access and control your radio like Windows hyperterminal...

The connection is done with parameters :

* 4800 bps
* 7 bits
* 1 stop bit
* Parity : Even

Quick start
===========
When the communication is successfully established, command can be send to the device. Each commmand is a single character. The first important command to know is "H" to display the list of available command with a little help message. For other commands check the available list:

- [Computer commands V3](Computer_commands_V3.md)
- [Computer commands V4](Computer_commands_V4.md)
- [Computer commands V5](Computer_commands_V5.md)

Mosts commands parameters wait for a precise number of digits or characters. As example : the channel number take 2 digits, always type "04" for channel 4. A PLL word is 4 digits long...

Adding a new channel
--------------------
1. First compute the PLL word without the IF : (Final RX frequency in KHz / 12.5)
   i.e : 145000/12.5 = 11600
2. Next convert this value in hexadecimal (You can use the windows calculator in scientific mode)
    i.e : 11600 => 2D50 hexadecimal
3. From the terminal, type "P"
4. Set the channel to modify or "99" to add a new one
5. Input the computed PLL word at step 2
6. Enter channel state value for options [See command "P"](Computer_commands_V4.md). 
