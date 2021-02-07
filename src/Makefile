CC=sdcc

CFLAGS=-mmcs51 --model-large -c
LDFLAGS=--model-large --xram-loc 0x1000

all: prm8060_144.hex

prm8060_144.hex: prm8060_144.ihx
	packihx prm8060_144.ihx > $@

prm8060_144.ihx: main.rel sys.rel lcd8060.rel mem.rel serial.rel
	$(CC) $(LDFLAGS) -o prm8060_144.ihx main.rel sys.rel lcd8060.rel serial.rel

main.rel: main.c
	$(CC) $(CFLAGS) main.c

sys.rel: sys.c
	$(CC) $(CFLAGS) sys.c

lcd8060.rel: lcd8060.c
	$(CC) $(CFLAGS) lcd8060.c

mem.rel: mem.c
	$(CC) $(CFLAGS) mem.c

serial.rel: serial.c
	$(CC) $(CFLAGS) serial.c
clean:
	rm *.rel *.lst *.map *.mem *.rst *.sym *.hex *.ihx *.asm *.lk
