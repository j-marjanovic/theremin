/******************************************************************************/
/* User Level #define Macros                                                  */
/******************************************************************************/

#define _XTAL_FREQ      4000000

/******************************************************************************/
/* User Function Prototypes                                                   */
/******************************************************************************/

void InitApp(void);         /* I/O and Peripheral Initialization */

void ADC_Init();
uint8_t ADC_Read(unsigned char channel);

void UART_Init();
void UART_Send(char ch);
