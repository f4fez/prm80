SRC_DIR=src

all: prm8060
 
prm8060:
	@(cd $(SRC_DIR) && $(MAKE))
    
.PHONY: clean mrproper prm8060
    
clean:
	@(cd $(SRC_DIR) && $(MAKE) $@)

mrproper: clean
	@(cd $(SRC_DIR) && $(MAKE) $@)
