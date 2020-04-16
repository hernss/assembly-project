/* Copyright 2020, Juan Manuel Cruz.
 * All rights reserved.
 *
 * This file is part of Project => assembly-project-1.
 *    https://gitlab.frba.utn.edu.ar/R-TDII/assembly-project-1
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

/*--------------------------------------------------------------------*-

    tasks.s (Released 2020-01)

--------------------------------------------------------------------

    tasks file for Assembly Programming - Project for LPC1769.

    See readme.txt for project information.

-*--------------------------------------------------------------------*/


// Project header
#include "main.h"

// Task header
#include "tasks.h"


/*------------------------------------------------------------------*/
		.syntax		unified
	    .arch       armv7-m
		.cpu		cortex-m3
		.thumb

		.section	.text
		.align		2


#if (TEST == TEST_1)	/* Test original two tasks without arguments */
/*------------------------------------------------------------------*/
		.global	task1Init
		.type	task1Init, %function
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		// R4 - R7: varaible register
task1Init:
		PUSH	{LR}					// Save PC

		BL		ledInit					// ledInit();

		MOVS	R0, #LEDoN
		BL		led						// led(LEDoN);

task1InitEnd:

		POP		{PC}					// Return

		.size	task1Init, . - task1Init


/*------------------------------------------------------------------*/
		.global	task1Update
		.type	task1Update, %function
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		// R4 - R7: varaible register
task1Update:
		PUSH	{LR}					// Save PC

		MOVS	R0, #LEDoN
		BL		led						// led(LEDoN);

        LDR		R0, =LEDoNdELAY
		BL		delay					// delay(LEDoNdELAY);

task1UpdateEnd:

		POP		{PC}					// Return

		.size	task1Update, . - task1Update


/*------------------------------------------------------------------*/
		.global	task2Init
		.type	task2Init, %function
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		// R4 - R7: varaible register
task2Init:
		PUSH	{LR}					// Save PC

		BL		ledInit					// ledInit();

		MOVS	R0, #LEDoFF
		BL		led						// led(LEDoFF);

task2InitEnd:

		POP		{PC}					// Return

		.size	task2Init, . - task2Init


/*------------------------------------------------------------------*/
		.global	task2Update
		.type	task2Update, %function
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		// R4 - R7: varaible register
task2Update:
		PUSH	{LR}					// Save PC

		MOVS	R0, #LEDoFF
		BL		led						// led(LEDoFF);

        LDR		R0, =LEDoFFdELAY
		BL		delay					// delay(LEDoFFdELAY);

task2UpdateEnd:

		POP		{PC}					// Return

		.size	task2Update, . - task2Update

#endif


/*------------------------------------------------------------------*/
		.type	ledInit, %function
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		// R4 - R7: varaible register
ledInit:
		PUSH	{LR}					// Save PC

		// Set P0.22 as a GPIO pin => "LED2" on LPC1769 board
		// P0.22 is controlled by bits 13:12 of PINSEL1
		// xxxx xxxx xxxx xxxx xx11 xxxx xxxx xxxx
		//    0    0    0    0    3    0    0    0
		LDR		R2, =PINSEL1			// R2 <- address of PINSEL1
        LDR		R0, [R2]				// R0 <- mem[R2] Read PINSEL1
		LDR		R1, =0x00003000
		BICS	R0, R0, R1				// Clear bits 13:12 to force GPIO mode
        STR		R0, [R2]				// mem[R2] <- R0 Write PINSEL1

        LDR		R2, =FIO0DIR			// R2 <- address of FIO0DIR
        LDR		R0, =LED_MASK			// R0 <- address of LED_MASK
        STR		R0, [R2]				// mem[R2] <- R0 Write FIO0DIR

ledInitEnd:

		POP		{PC}					// Retun

		.size	ledInit, . - ledInit


/*------------------------------------------------------------------*/
		.type	led, %function
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		// R4 - R7: varaible register
		// R0: LEDoN or LEDoFF
led:
		PUSH	{LR}					// Save PC

		CMP		R0, #LEDoN
		BNE		ledOff					// Jump if (R0 != LEDoN)

ledOn:
        LDR		R3, =FIO0SET			// R3 <- address of FIO0SET
        LDR		R1, =LED_MASK			// R1 <- address of LED_MASK
		STR		R1, [R3]				// mem[R3] <- R1 Write FIO0SET
										// LED2 ON
		B		ledEnd

ledOff:
        LDR		R3, =FIO0CLR			// R3 <- address of FIO0CLR
        LDR		R1, =LED_MASK			// R1 <- address of LED_MASK
		STR		R1, [R3]				// mem[R3] <- R1 Write FIO0CLR
										// LED2 OFF

ledEnd:
		POP		{PC}					// Return

		.size	led, . - led


/*------------------------------------------------------------------*/
		.type	delay, %function
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		// R4 - R7: varaible register
		// R0: LEDdELAY
delay:
		PUSH	{LR}					// Save PC

delay0:
        SUBS	R0, 1					// R0 <- R0 - 1
        BNE		delay0					// Jump if (R0 != 0)

		POP		{PC}					// Return

delayEnd:

		.size	delay, . - delay


		.type	pin_init, %function
pin_init:
		PUSH	{LR}
		LDR		R1, =(1 << 4)       @ load to r1 value we want to write to RCC_APB2ENR
		LDR 	R2, =#RCC_APB2ENR   @ load to r2 RCC_APB2ENR address
		STR		R1, [R2]            @ store (1 << 4) in RCC_APB2ENR
		@ Set C13 to output
		LDR 	R1, =(0b11 << 20)
		LDR 	R2, =#GPIOC_CHR
		STR 	R1, [R2]
		POP		{PC}

		.end
// .end marks the end of the assembly file. as does not process anything in
// the file past the .end directive.

/*------------------------------------------------------------------*-
  ---- END OF FILE -------------------------------------------------
-*------------------------------------------------------------------*/
