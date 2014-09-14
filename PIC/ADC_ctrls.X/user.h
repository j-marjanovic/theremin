/******************************************************************************/
/* User Level #define Macros                                                  */
/******************************************************************************/

#define _XTAL_FREQ      4000000
#define ADC_CHNS        7

/******************************************************************************/
/* User Function Prototypes                                                   */
/******************************************************************************/

void InitApp(void);         /* I/O and Peripheral Initialization */

void ADC_Init();
uint8_t ADC_Read(unsigned char channel);


// Creates meausrement string
uint8_t createMeasString(char* str, uint8_t meas[ADC_CHNS]);
