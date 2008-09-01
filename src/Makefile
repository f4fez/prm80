all: prm8060

debug: prm8060debug

prm8060: prm.a51
	asem -v --define=TARGET:8060 prm.a51 8060.hex
	hexbin 8060.hex --fill=ff --length=20000 -v

prm8060debug:
	asem -v --define=TARGET:8060 prm.a51 8060.hex
	hexbin 8060.hex -v

.PHONY: clean mrproper

clean:
	rm -rf *.lst

mrproper: clean
	rm -rf *.bin *.hex