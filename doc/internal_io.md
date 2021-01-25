Shift register LSB
------------------
* b0: TX power Low (true) / High (false)
* b1: [Unused]
* b2: Alarm output (DB15). Used for 1750Hz
* b3: Output 1
* b4: Output 2
* b5: Lock mike
* b6: CPU Clock offset enable
* b7: Synthetizer validation (Must be true to send data)

Shift register MSB
------------------
* b0: Volume Bit 3
* b1: Volume Bit 2
* b2: Volume Bit 1
* b3: Volume Bit 0
* b4: RX Mute
* b5: Enable 9v8
* b6: RX/TX siwitch
* b7: TX power enable