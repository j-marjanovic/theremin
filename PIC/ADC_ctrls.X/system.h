/******************************************************************************/
/* System Level #define Macros                                                */
/******************************************************************************/

#define _XTAL_FREQ      4000000

/* Microcontroller MIPs (FCY) */
#define SYS_FREQ        500000L
#define FCY             SYS_FREQ/4

/******************************************************************************/
/* System Function Prototypes                                                 */
/******************************************************************************/

/* Custom oscillator configuration funtions, reset source evaluation
functions, and other non-peripheral microcontroller initialization functions
go here. */

void ConfigureOscillator(void); /* Handles clock switching/osc initialization */


/// Initalizes to 9600 bps
void UART_Init();

/// Sends single character
void UART_Send(char ch);

/// Sends string
void UART_Send_String(char *str);