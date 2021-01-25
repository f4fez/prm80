CPU Port 1
----------
* b0: [Out] Serial clock. Synthesizer, latch
* b1: [Out] Serial clock data
* b2: [In] FFSK Sync data input
* b3: [In] FFSK Sync data output
* b4: [Unused]
* b5: [Out] Synthesizer validation. CE
* b6: I2C
* b7: I2C

CPU Port 3
----------
* b0: [In] RS232 RX
* b1: [Out] RS232 TX
* b2: [Unused]
* b3: Option pin
* b4: [Out] Latch OE
* b5: [Out] Latch STR
* b6: [RAM /WR]
* b7: [RAM /RD]

CPU Port 4
----------
* b0: [In] PTT
* b1: [Out] Speaker mute
* b2: [Out] Display chip validation
* b3: [In] Signal to detect radio is turned on for permanent power option
* b4: [In] FFSK modem data input
* b5: [Out] FFSK modem data output. DA0
* b6: [In] FFSK carrier detected. DA1
* b7: [Out] FFSK data output validation. DA2

CPU Port 5
----------
* b0: TCS Option
* b1: [In] squelch comparator output
* b2: [In] PLL unlocked
* b3: [In] Alarm input
* b4: [In] false when PA > 0.5w
* b5: [In] Mike hang out sensor
* b6: [Analog] RSSI
* b7: [Analog] Volume

Shift register LSB
------------------
* b0: TX power Low (true) / High (false)
* b1: [Unused]
* b2: Alarm output (DB15). Used for 1750Hz
* b3: Output 1
* b4: Output 2
* b5: Lock mike
* b6: CPU Clock offset enable
* b7: Synthesizer validation (Must be true to send data)

Shift register MSB
------------------
* b0: Volume Bit 3
* b1: Volume Bit 2
* b2: Volume Bit 1
* b3: Volume Bit 0
* b4: RX Mute
* b5: Enable 9v8
* b6: RX/TX switch
* b7: TX power enable