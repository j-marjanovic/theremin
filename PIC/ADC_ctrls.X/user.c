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
    // ADC
    ADC_Init();

    // UART
    UART_Init();
}

void doMeas(uint8_t meas[ADC_CHNS])
{
    uint8_t i;
    for(i = 0; i < ADC_CHNS; i++){
       meas[i] = ADC_Read(i);
   }
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
