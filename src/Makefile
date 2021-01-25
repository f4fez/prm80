
CC=sdcc

CFLAGS=-mmcs51 --model-large -c

all: prm8060_430.ihx

prm8060_430.ihx: main.rel sys.rel lcd8060.rel mem.rel
    $(CC) main.rel sys.rel lcd8060.rel

main.rel: main.c
    $(CC) $(CFLAGS) main.c

sys.rel: sys.c
    $(CC) $(CFLAGS) sys.c

lcd8060.rel: lcd8060.c
    $(CC) $(CFLAGS) lcd8060.c

mem.rel: mem.c
    $(CC) $(CFLAGS) mem.c
clean:
    rm *.rel *.lst *.map *.mem *.rst *.sym *.hex *.ihx *.asm