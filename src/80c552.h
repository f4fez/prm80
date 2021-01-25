/*-------------------------------------------------------------------------
   80c552.h: Register Declarations for the Philips 8xc52 Processor

   Copyright (C) 2000, Bela Torok / bela.torok@kssg.ch

   This library is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License 
   along with this library; see the file COPYING. If not, write to the
   Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.

   As a special exception, if you link this library with other files,
   some of which are compiled with SDCC, to produce an executable,
   this library does not by itself cause the resulting executable to
   be covered by the GNU General Public License. This exception does
   not however invalidate any other reasons why the executable file
   might be covered by the GNU General Public License.
-------------------------------------------------------------------------*/

#ifndef REG80C552_H
#define REG80C552_H

#include <8051.h>     /* load definitions for the 8051 core */

#ifdef REG8051_H
#undef REG8051_H
#endif

/*  IO Register  */
__sfr __at (0xC0) P4 ;
__sfr __at (0xC4) P5 ;

/* Timer 3 */
__sfr __at (0xFF) T3 ;

/* PWM */
__sfr __at (0xFC) PWM0 ;
__sfr __at (0xFD) PWM1 ;
__sfr __at (0xFE) PWMP ;

/* P4 */
__sbit __at (0xC0) P4_0 ;
__sbit __at (0xC1) P4_1 ;
__sbit __at (0xC2) P4_2 ;
__sbit __at (0xC3) P4_3 ;
__sbit __at (0xC4) P4_4 ;
__sbit __at (0xC5) P4_5 ;
__sbit __at (0xC6) P4_6 ;
__sbit __at (0xC7) P4_7 ;
#endif
