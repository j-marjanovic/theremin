/******************************************************************************/
/* User Level #define Macros                                                  */
/******************************************************************************/

#define _XTAL_FREQ      4000000
#define ADC_CHNS        7

/******************************************************************************/
/* User Function Prototypes                                                   */
/******************************************************************************/

void InitApp(void);         /* I/O and Peripheral Initialization */

/// Performs measuerment from ADCs
void doMeas(uint8_t meas[ADC_CHNS]);

// Creates meausrement string
uint8_t createMeasString(char* str, uint8_t meas[ADC_CHNS]);
