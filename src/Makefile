all: prm8060

prm8060: prm8060_144 prm8060_430

prm8060debug: prm8060_144debug prm8060_430debug

prm8060_144: prm.a51
	asem -v --define=TARGET:8060 --define=FREQ:144 prm.a51 8060_144.hex
	hexbin 8060_144.hex --fill=ff --length=20000 -v

prm8060_144debug:
	asem -v --define=TARGET:8060 --define=FREQ:144 prm.a51 8060_144.hex
	hexbin 8060_144.hex -v

prm8060_430: prm.a51
	asem -v --define=TARGET:8060 --define=FREQ:430 prm.a51 8060_430.hex
	hexbin 8060_430.hex --fill=ff --length=20000 -v

prm8060_430debug:
	asem -v --define=TARGET:8060 --define=FREQ:430 prm.a51 8060_430.hex
	hexbin 8060_430.hex -v

.PHONY: clean mrproper

clean:
	rm -rf *.lst

mrproper: clean
	rm -rf *.bin *.hex