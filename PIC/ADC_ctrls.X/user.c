/******************************************************************************/
/* Files to Include                                                           */
/******************************************************************************/

#if defined(__XC)
    #include <xc.h>         /* XC8 General Include File */
#elif defined(HI_TECH_C)
    #include <htc.h>        /* HiTech General Include File */
#endif

#include <stdint.h>         /* For uint8_t definition */
#include <stdbool.h>        /* For true/false definition */
#include <string.h>
#include <stdio.h>

#include "user.h"
#include "system.h"

/******************************************************************************/
/* User Functions                                                             */
/******************************************************************************/

/* <Initialize variables in user.h and insert code for user algorithms.> */


void InitApp(void)
{
    //TRISA = 0xFF;   // PORTA input
    //ANSEL = 0x7F;   // Analog inputs on PORTA0-6

    // ADC
    //ADC_Init();

    UART_Init();
}


void ADC_Init()
{
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


uint8_t createMeasString(char* str, uint8_t meas[ADC_CHNS])
{
   uint8_t i;
   uint8_t offset = 0;
   
   memcpy(str, "MEAS:", strlen("MEAS:"));
   offset += strlen("MEAS:");

   for(i = 0; i < ADC_CHNS; i++){

       offset += sprintf(str+offset, "%02x:", meas[i]);
   }

   memcpy(str+offset, "\r\n", strlen("\r\n"));
   offset += strlen("\r\n");

   return offset;
}
