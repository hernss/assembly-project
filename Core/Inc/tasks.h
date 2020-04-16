/*
 * tasks.h
 *
 *  Created on: Apr 15, 2020
 *      Author: hanib
 */

#ifndef INC_TASKS_H_
#define INC_TASKS_H_


// ------ Public constants -----------------------------------------
// PORTS para LPC1769
#define LED_MASK	0x00400000
#define PINSEL1		0x4002C004
#define FIO0DIR		0x2009C000
#define FIO0MASK	0x2009C010
#define FIO0PIN		0x2009C014
#define FIO0SET		0x2009C018
#define FIO0CLR		0x2009C01C

// PORTS para Blue Pill
#define PORTC_ODR	0x4001100C
#define GPIOC_CHR 	0x40011004
#define	RCC_APB2ENR	0x40021018


#define LEDdELAY	200000
#define LEDoNdELAY	LEDdELAY
#define LEDoFFdELAY	(LEDdELAY * 2)

#define LEDoFF	false
#define LEDoN	true


#endif /* INC_TASKS_H_ */
