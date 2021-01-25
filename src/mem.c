//    Copyright (c) 2007, 2015 Florian MAZEN and Pierre COL
//    
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY// without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "80c552.h"
#include "mem.h"
#include "sys.h"

__xdata __at (0x0000) unsigned char ram_id_code;					// Introduced 1.0
__xdata __at (0x0001) unsigned char ram_config_sum;					// Introduced 4.0
__xdata __at (0x0002) unsigned char ram_freq_sum;					// Introduced 4.0
__xdata __at (0x0003) unsigned char ram_state_sum;					// Introduced 4.0
__xdata __at (0x0004) unsigned char ram_reserved1[0x10-0x04];
__xdata __at (0x0010) unsigned char ram_chan;						// Introduced 3.0
__xdata __at (0x0011) unsigned char ram_mode;						// Introduced 3.0
__xdata __at (0x0012) unsigned char ram_squelch;					// Introduced 3.0
__xdata __at (0x0013) unsigned char ram_max_chan;					// Introduced 3.0
__xdata __at (0x0014) unsigned char ram_shift_hi;					// Introduced 4.0
__xdata __at (0x0015) unsigned char ram_shift_lo;					// Introduced 4.0
__xdata __at (0x0016) unsigned char ram_pll_div_hi;					// Introduced 4.0
__xdata __at (0x0017) unsigned char ram_pll_div_lo;					// Introduced 4.0
__xdata __at (0x0018) unsigned char ram_scan_duration;				// Introduced 4.0
__xdata __at (0x0019) unsigned char ram_reserved2[0x0100-0x19];
__xdata __at (0x0100) unsigned char ram_chanels_frequencies[256];	// Introduced 4.0
__xdata __at (0x0200) unsigned char ram_chanels_state[256];			// Introduced 4.0
__xdata __at (0x0300) unsigned char ram_reserved3[0x800-0x300];

unsigned char is_ram_valid() {
	if (ram_id_code != MEM_ID_CODE)
		return 0;
	if (compute_config_area_checksum() != ram_config_sum)
		return 0;
	if (compute_frequency_area_checksum() != ram_freq_sum)
		return 0;
	if (compute_state_area_checksum() != ram_state_sum)
		return 0;
	return 1;
}

void validate_ram() {
	if (is_ram_valid()) {
		return;
	}
	/* TODO
	 mem_copy_eeprom2ram();
	 if (is_ram_valid())
		return;
	*/
	mem_update_ram_last();
    //TODO	mem_copy_ram2eeprom(); 
}

void mem_update_ram_last() {
    if (ram_id_code > MEM_ID_CODE) {
        mem_update_ram(0);
    }
    else {
        mem_update_ram(ram_id_code);
    }
}

void mem_update_ram(unsigned char from_version) {
	register unsigned int cnt;
	register unsigned char *ptr = &ram_id_code;
	if (from_version < MEM_ID_CODE_V4_0) {
        // Clear RAM to 0xff
        for (cnt = 0; cnt < EEPROM_SIZE; cnt++) {
            *ptr = 0xff;
            ptr++;
        }
        //Init default value
        ram_shift_hi = 0; //TODO
        ram_shift_lo = 0; //TODO
        ram_chan = 0;
        ram_mode = 0;
        ram_squelch = 5;
        ram_max_chan = 0; //TODO
        ram_pll_div_hi = 0; //TODO
        ram_pll_div_lo = 0; //TODO
        ram_scan_duration = 0; //TODO
        //TODO load channels        
    }
            
	if (from_version < MEM_ID_CODE) {
        ram_id_code = MEM_ID_CODE;
        ram_config_sum = compute_config_area_checksum();
	}
    
    //Compute Checksum
    ram_config_sum = compute_config_area_checksum();
    ram_freq_sum = compute_frequency_area_checksum();
    ram_state_sum = compute_state_area_checksum();
}

unsigned char compute_config_area_checksum() {		
	register unsigned char sum = 0;
	register unsigned char cnt;
	register unsigned char *ptr = &ram_chan; // Values before ram_chan are not in the checksums
	wdt_reset();
	
	for (cnt = 0x10; cnt != 0; cnt++) {
		sum += *ptr;
		ptr++;
	}
		
	return sum; 
}

unsigned char compute_frequency_area_checksum() {
	register unsigned char sum = 0;
	register unsigned char cnt = 0; 
	wdt_reset();
	
	do {
		sum += ram_chanels_frequencies[cnt];
		cnt++;
	} while(cnt != 0);
		
	return sum;
}

unsigned char compute_state_area_checksum() {
	register unsigned char sum = 0;
	register unsigned char cnt = 0; 
	wdt_reset();
	
	do {
		sum += ram_chanels_state[cnt];
		cnt++;
	} while(cnt != 0);
		
	return sum;
}
