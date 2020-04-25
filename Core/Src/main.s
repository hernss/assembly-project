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

    main.s (Released 2020-01)

--------------------------------------------------------------------

    main file for Assembly Programming - Project for LPC1769.

    See readme.txt for project information.

-*--------------------------------------------------------------------*/


// Project header
#include "main.h"
#include "tasks.h"

// ------ Public functions -----------------------------------------
		.extern		task1Init, task1Update
		.extern		task2Init, task2Update
		.extern 	pin_init

/*------------------------------------------------------------------*/
		.section	.bss

		.comm	mainLoopCnt,4	// static volatile uint32_t mainLoopCnt;
		.comm	taskCnt,4		// static volatile uint32_t taskCnt;

		.comm	tick_ct, 4		// static volatile uint32_t taskCnt;
		.comm	paramArray,8

/*------TEST 4------------------------------------------------------*/



		.comm	addrParametrosReferencia, 5 * 4 //5 elementos de 4bytes
		//Base Address
		//Tipo (8, 16 o 32)
		//Size (0 a 256)
		//Process (null)
		//Valor a buscar (4 bytes)

/*------------------------------------------------------------------*/
		.syntax		unified
	    .arch       armv7-m
		.cpu		cortex-m0
		.thumb



		.section	.text


#if (TEST == TEST_4)

baseAddrArray8:       .byte 1,1,9,4,3,45,4,9,3,1,3
endArray8:
		.size	baseAddrArray8, . - baseAddrArray8

baseAddrArray16:      .short 1,2,3,4,4,1,1,1,2,5
endArray16:
		.size	baseAddrArray16, . - baseAddrArray16

baseAddrArray32:      .word 1,2,3,4,4,1,1,1,2,5
endArray32:
		.size	baseAddrArray32, . - baseAddrArray32

		.equ	SIZE_ARRAY_8, (endArray8 - baseAddrArray8)
		.equ	SIZE_ARRAY_16, (endArray16 - baseAddrArray16)/2
		.equ	SIZE_ARRAY_32, (endArray32 - baseAddrArray32)/4
#endif


		.align		2

#if (TEST == TEST_1)	/* Test original two tasks without arguments */
/*-------------------------------------------------------------------*/
 		.global		main
		.type		main, %function

main:
		PUSH	{LR}					// Save PC

    	BL		systemInit				// systemInit();

		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
		MOVS	R0, #0					// R0 <- 0
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt = 0;

		LDR		R1, =taskCnt			// R1 <- address of taskCnt
		MOVS	R0, #0					// R0 <- 0
		STR		R0, [R1]      			// mem[R1] <- R0 => taskCnt = 0;

mainLoop:

		LDR		R1, =taskCnt			// R1 <- address of taskCnt
  		LDR		R0, [R1]				// R0 <- mem[R1]
		CMP		R0, #tasksTableParts
		BHI		taskCntError			// Jump if (R0 > tasksTableParts)


		MOVS	R2, #tasksTablePartSize	// R2 <- tasksTablePartSize
		MULS	R0, R0, R2				// R0 <- R0 * R2
										// R0 <- taskCnt * tasksTablePartSize
		LDR		R1, =tasksTable			// R1 <- address of tasksTable
		LDR		R2, [R1, R0]			// R2 <- mem[R1 + R0]
		BLX		R2						// Branch to taskX

		LDR		R1, =taskCnt			// R1 <- address of taskCnt
  		LDR		R0, [R1]				// R0 <- mem[R1]
		ADDS	R0, R0, #1				// R0 <- R0 + 1
		STR		R0, [R1]    			// mem[R1] <- R0 => taskCnt++;
		CMP		R0, #tasksTableParts
		BLT		mainLoopContinue		// Jump if (R0 < tasksTableParts)

		MOVS	R0, #0					// R0 <- 0
		STR		R0, [R1]      			// mem[R1] <- R0 => taskCnt = 0;

mainLoopContinue:

		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
  		LDR		R0, [R1]				// R0 <- mem[R1]
		ADDS	R0, R0, #1				// R0 <- R0 + 1
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt++;

		B		mainLoop				// Continue forever

mainLoopEnd:							// We should never reach here

		POP		{PC}					// Return

taskCntError:							// We should never reach here
		B		taskCntError

		.size	main, . - main


/*------------------------------------------------------------------*/
		.global	systemInit
		.type	systemInit, %function
systemInit:
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		PUSH	{LR}					// Save PC
										// HW & SW initialization here
		BL		task1Init				// task1Init();
		BL		task2Init				// task2Init();

		POP		{PC}					// Retun

		.size	systemInit, . - systemInit


/*------------------------------------------------------------------*/
		.global	tasksTable
		.type	tasksTable, %object
		// Table of tasks
tasksTable:
		.word	task1Update				// task1Update();
tasksTable1:

		.word	task2Update				// task1Update();

tasksTableEnd:

		.size	tasksTable, . - tasksTable

		.equ	tasksTableSize, (tasksTableEnd - tasksTable)
		.equ	tasksTablePartSize, (tasksTable1 - tasksTable)
		.equ	tasksTableParts, (tasksTableSize/tasksTablePartSize)


#elif (TEST == TEST_2)
		.global		main
		.type		main, %function
main:
		PUSH	{LR}					// Save PC

    	BL		systemInit				// systemInit();
		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
		MOVS	R0, #0					// R0 <- 0
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt = 0;
mainLoop:

		LDR		R0, =LEDoN
		LDR		R1, =LEDoNdELAY
		BL		UpdateOutput

		LDR		R0, =LEDoFF
		LDR		R1, =LEDoFFdELAY
		BL		UpdateOutput


		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
  		LDR		R0, [R1]				// R0 <- mem[R1]
		ADDS	R0, R0, #1				// R0 <- R0 + 1
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt++;

		B		mainLoop				// Continue forever

mainLoopEnd:							// We should never reach here

		POP		{PC}					// Return


		.size	main, . - main


#elif (TEST == TEST_3)

		.global		main
		.type		main, %function
main:
		PUSH	{LR}					// Save PC

    	BL		systemInit				// systemInit();
		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
		MOVS	R0, #0					// R0 <- 0
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt = 0;
mainLoop:


		LDR		R0, =paramArray
		LDR		R1, =LEDoN
		STR		R1, [R0]

		LDR		R1, =LEDoNdELAY
		STR		R1, [R0,#4]
		BL		UpdateOutputReference

		LDR		R0, =paramArray
		LDR		R1, =LEDoFF
		STR		R1, [R0]

		LDR		R1, =LEDoFFdELAY
		STR		R1, [R0,#4]
		BL		UpdateOutputReference


		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
  		LDR		R0, [R1]				// R0 <- mem[R1]
		ADDS	R0, R0, #1				// R0 <- R0 + 1
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt++;

		B		mainLoop				// Continue forever

mainLoopEnd:							// We should never reach here

		POP		{PC}					// Return


		.size	main, . - main

#elif (TEST == TEST_4)

		.global		main
		.type		main, %function
main:
		PUSH	{LR}					// Save PC

    	BL		systemInit				// systemInit();
		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
		MOVS	R0, #0					// R0 <- 0
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt = 0;
mainLoop:

		//Prueba para array de 8bits
		LDR		R0, =addrParametrosReferencia
		LDR		R1, =baseAddrArray8
		STR		R1, [R0,#OFFSET_BASE_ADDRESS]

		LDR		R1, =BYTE_ARRAY
		STR		R1, [R0,#OFFSET_ARRAY_TYPE]

		LDR		R1, =SIZE_ARRAY_8
		STR		R1, [R0,#OFFSET_ARRAY_SIZE]

		MOVS	R1, #0
		STR		R1, [R0,#OFFSET_PROCESS]

		MOVS	R1, #3		//VALOR A BUSCAR
		STR		R1, [R0,#OFFSET_VALUE]

		BL		taskBuscarValor

		//Prueba para array de 16bits
		LDR		R0, =addrParametrosReferencia
		LDR		R1, =baseAddrArray16
		STR		R1, [R0,#OFFSET_BASE_ADDRESS]

		LDR		R1, =SHORT_ARRAY
		STR		R1, [R0,#OFFSET_ARRAY_TYPE]

		LDR		R1, =SIZE_ARRAY_16
		STR		R1, [R0,#OFFSET_ARRAY_SIZE]

		MOVS	R1, #0
		STR		R1, [R0,#OFFSET_PROCESS]

		MOVS	R1, #1		//VALOR A BUSCAR
		STR		R1, [R0,#OFFSET_VALUE]

		BL		taskBuscarValor

		//Prueba para array de 32bits
		LDR		R0, =addrParametrosReferencia
		LDR		R1, =baseAddrArray32
		STR		R1, [R0,#OFFSET_BASE_ADDRESS]

		LDR		R1, =WORD_ARRAY
		STR		R1, [R0,#OFFSET_ARRAY_TYPE]

		LDR		R1, =SIZE_ARRAY_32
		STR		R1, [R0,#OFFSET_ARRAY_SIZE]

		MOVS	R1, #0
		STR		R1, [R0,#OFFSET_PROCESS]

		MOVS	R1, #4		//VALOR A BUSCAR
		STR		R1, [R0,#OFFSET_VALUE]

		BL		taskBuscarValor


		LDR		R1, =mainLoopCnt		// R1 <- address of mainLoopCnt
  		LDR		R0, [R1]				// R0 <- mem[R1]
		ADDS	R0, R0, #1				// R0 <- R0 + 1
		STR		R0, [R1]      			// mem[R1] <- R0 => mainLoopCnt++;

		B		mainLoop				// Continue forever

mainLoopEnd:							// We should never reach here

		POP		{PC}					// Return


		.size	main, . - main

#endif


		.global	systemInit
		.type	systemInit, %function
systemInit:
		// R0, R1: argument / result / scratch register
		// R2, R3: argument / scratch register
		PUSH	{LR}					// Save PC
										// HW & SW initialization here
		BL		pin_init				// Inicializo el pin del led como salida


		POP		{PC}					// Retun

		.size	systemInit, . - systemInit

		.end
// .end marks the end of the assembly file. as does not process anything in
// the file past the .end directive.

/*------------------------------------------------------------------*-
  ---- END OF FILE -------------------------------------------------
-*------------------------------------------------------------------*/
