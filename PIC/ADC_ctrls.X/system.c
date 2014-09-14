/******************************************************************************/
/*Files to Include                                                            */
/******************************************************************************/

#if defined(__XC)
    #include <xc.h>         /* XC8 General Include File */
#elif defined(HI_TECH_C)
    #include <htc.h>        /* HiTech General Include File */
#endif

#include <stdint.h>        /* For uint8_t definition */
#include <stdbool.h>       /* For true/false definition */

#include "system.h"

/* Refer to the device datasheet for information about available
oscillator configurations. */
void ConfigureOscillator(void)
{

    // use INTRC as system clock
    SCS0 = 0; SCS1 = 1;

    IRCF2 = 1; IRCF1 = 1; IRCF0 = 0; // 4MHz

}


void ADC_Init()
{
  ANSEL = 0x7F;   // Analog inputs on PORTA0-6
  TRISA = 0xFF;   // PORTA input
  ADCON0 = 0x41; //ADC Module Turned ON and Clock is selected
  ADCON1 = 0x00; //All pins as Analog Input
                 //With reference voltages VDD and VSS
}

uint8_t ADC_Read(unsigned char channel)
{
  if(channel > 7) //If Invalid channel selected
    return 0;     //Return 0

  ADCON0 &= 0xC5; //Clearing the Channel Selection Bits
  ADCON0 |= channel<<3; //Setting the required Bits
  __delay_ms(2); //Acquisition time to charge hold capacitor
  GO_nDONE = 1; //Initializes A/D Conversion
  while(GO_nDONE); //Wait for A/D Conversion to complete
  return (ADRESH); //Returns Result
}


/// Initalizes to 9600 bps
void UART_Init()
{
    TRISB5 = 1;
    TRISB2 = 1;
    SPBRG = 25;
    SPEN = 1;
    BRGH = 1;
    TXEN = 1;
}

/// Sends single character
void UART_Send(char ch)
{
    while(!TRMT);
    TXREG = ch;
}

/// Sends string
void UART_Send_String(char *str)
{
    while(*str!='\0'){
        UART_Send(*str);
        *str++;
    }
}
