SRC_DIR=src
SRC-FILES=README COPYING Makefile build.bat src/Makefile src/*.c src/*.h
TAR-SRC=prm80-src.tar

BIN-FILES=src/*.bin src/*.hex
ZIP-BIN=prm80-bin

all: 
	@(cd $(SRC_DIR) && $(MAKE))
    
.PHONY: clean mrproper prm8060
    
clean:
	rm -rf *.tar *.bz2 *.zip
	@(cd $(SRC_DIR) && $(MAKE) $@)

mrproper: clean
	@(cd $(SRC_DIR) && $(MAKE) $@)

pkg-src: mrproper
	tar -cvf $(TAR-SRC) $(SRC-FILES)
	bzip2 $(TAR-SRC)

pkg-bin: clean all
	zip -j $(ZIP-BIN) $(BIN-FILES)

pkg: pkg-src pkg-bin
