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
#ifndef PRM_MEM_H
#define PRM_MEM_H

#define MEM_ID_CODE_V5_0	0x050
#define MEM_ID_CODE_V4_0	0x040

#define MEM_ID_CODE			MEM_ID_CODE_V5_0

#define EEPROM_SIZE			2048

#define RAM_AREA_CONFIG		0

/**
 * Update memory model to last version.
 */
void mem_update_ram_last();

/**
 * Update memory model. Set from_version to 0 to reset.
 * \param from_version Version to update from.
 */
void mem_update_ram(unsigned char from_version);

/**
 * Compute the checksum of the RAM config area.
 * \return The checksum.
 */
unsigned char compute_config_area_checksum();

/**
 * Compute the checksum of the RAM channel frequencies area.
 * \return The checksum.
 */
unsigned char compute_frequency_area_checksum();

/**
 * Compute the checksum of the RAM channel state area.
 * \return The checksum.
 */
unsigned char compute_state_area_checksum();

#endif
