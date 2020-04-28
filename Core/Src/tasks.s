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

		BL		pin_init				// ledInit();

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

		BL		pin_init					// ledInit();

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

#elif (TEST == TEST_2)
		.global	UpdateOutput
		.type	UpdateOutput, %function
		// R0: Led Status
		// R1: Delay
UpdateOutput:
		PUSH	{LR}

		MVNS	R0,R0				// R0 = not R0
		ANDS	R0,#1				// R0&=0x01
		LSLS	R0,R0,#13			// R0<<=13
		LDR 	R2, =#PORTC_ODR   	// load to r2 PORTC_ODR adress
		STR 	R0, [R2]          	// flush output
		MOV		R0, R1				// R1 -> R0
		BL		delay				// Ejecuto un delay de R0 instrucciones

		POP		{PC}

		.size UpdateOutput, . - UpdateOutput

#elif (TEST == TEST_3)
		.global	UpdateOutputReference
		.type	UpdateOutputReference, %function
		// R0: Led Status
		// R1: Delay
UpdateOutputReference:
		PUSH	{LR}

		LDR		R1,[R0]				// La primera posicion es el estado del led
		LDR		R2,[R0,#4]			// La segunda posicion es el delay

		MVNS	R1,R1				// R1 = not R1
		ANDS	R1,#1				// R1&=0x01
		LSLS	R1,R1,#13			// R1<<=13
		LDR 	R3, =#PORTC_ODR   	// load to r3 PORTC_ODR adress
		STR 	R1, [R3]          	// flush output
		MOV		R0, R2				// R2 -> R0
		BL		delay				// Ejecuto un delay de R0 instrucciones

		POP		{PC}

		.size UpdateOutputReference, . - UpdateOutputReference

#elif (TEST == TEST_4)

		.global	taskBuscarValor
		.type	taskBuscarValor, %function
		// R0: Direccion a un array con los parametros de la funcion
taskBuscarValor:
		PUSH	{LR}

		LDR		R1,[R0,#OFFSET_BASE_ADDRESS]	// Direccion base del array
		LDR		R2,[R0,#OFFSET_ARRAY_TYPE]		// Tipo de datos del array
		LDR		R3,[R0,#OFFSET_ARRAY_SIZE]		// Tamaño del array
		LDR		R4,[R0,#OFFSET_PROCESS]			// Proccess
		LDR		R5,[R0,#OFFSET_VALUE]			// Valor a buscar

		MOVS	R0,#0					//Limpio la variable de retorno

		CMP		R3,#0
		BEQ		finBusqueda				//Si el Array tiene tamaño 0 no busco nada

		CMP		R3,#255
		BLS		comprobacionDatos		//Si es menor o igual a 255 entonces salto

		MOVS	R3,#256					//Sino sobreescribo R3 con 256 (mas adelante le resto 1)  para no pasarme en la busqueda

comprobacionDatos:
		MULS	R3,R3,R2				//Multiplico la cantidad de registros por la cantidad de bytes
										//De esta manera me adapto a los distintos tamaños de registros

		CMP		R2,BYTE_ARRAY			//Compruebo que el tipo de datos sea valido para la tarea
		BNE		probarShort
		LDR		R7, =0xFF				//Seteo la mascara para el BYTE
		B		iniciarBusqueda
probarShort:
		CMP		R2,SHORT_ARRAY
		BNE		probarWord
		LDR		R7, =0xFFFF				//Seteo la mascara para el Short
		B		iniciarBusqueda
probarWord:
		CMP		R2,WORD_ARRAY
		BNE		finBusqueda				//Si llegue hasta aca es porque el array no tiene un tipo de datos aceptado por la tarea
		LDR		R7, =0xFFFFFFFF			//Seteo la mascara para el WORD

iniciarBusqueda:
		SUBS 	R3,R3,R2				//Le resto la cantidad de bytes del registro. Lo hago en esta instancia porque el valor 0 es valido
		LDR		R6,[R1, R3]				//Incializo el indice
		AND		R6,R6,R7				//Aplico la mascara que tengo en R7

		CMP		R6, R5
		BNE		comprobarFinal			//Si no coincide con el valor que busco salto

		ADDS	R0,R0,#1				//Si llego aca es porque coincide con el valor que busco

comprobarFinal:
		CMP 	R3,#0					//Si R3 es cero ya recorri todo el array
		BNE		iniciarBusqueda

finBusqueda:
		POP		{PC}

		.size taskBuscarValor, . - taskBuscarValor

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
        /*LPC1769
        LDR		R3, =FIO0SET			// R3 <- address of FIO0SET
        LDR		R1, =LED_MASK			// R1 <- address of LED_MASK
		STR		R1, [R3]				// mem[R3] <- R1 Write FIO0SET
										// LED2 ON
		*/
		LDR 	R0,=(1 << 13)			@ R0 = 1<<13
		LDR 	R2,=#PORTC_ODR   		@ load to r2 PORTC_ODR adress
		STR 	R0, [R2]          		@ store!
		B		ledEnd

ledOff:
		/*LPC1769
        LDR		R3, =FIO0CLR			// R3 <- address of FIO0CLR
        LDR		R1, =LED_MASK			// R1 <- address of LED_MASK
		STR		R1, [R3]				// mem[R3] <- R1 Write FIO0CLR
										// LED2 OFF
		*/
		MOV		R0,#0					@ R0 = 0
		LDR 	R2, =#PORTC_ODR   		@ load to r2 PORTC_ODR adress
		STR 	R0, [R2]          		@ store!

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

//Inicializacion del pin C13 para blue pill
		.global pin_init
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

		.size	pin_init, . - pin_init

		.end
// .end marks the end of the assembly file. as does not process anything in
// the file past the .end directive.

/*------------------------------------------------------------------*-
  ---- END OF FILE -------------------------------------------------
-*------------------------------------------------------------------*/
