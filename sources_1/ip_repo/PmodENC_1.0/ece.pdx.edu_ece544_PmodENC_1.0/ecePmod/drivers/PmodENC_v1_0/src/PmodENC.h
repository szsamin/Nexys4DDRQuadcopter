/** @file PmodENC.h
*
* @author Roy Kravitz (roy.kravitz@pdx.edu)
* @copyright Portland State University, 2016, 2017
*
* @brief
* This header file contains the constants and low level function for the PmodENC custom AXI Slave
* peripheral driver.  The peripheral provides access to a Digilent PmodENC.  The PmodENC contains
* a quadrature encoder (the rotary encoder), a pushbutton (the shaft of the rotary encoder) and an 
* independent slide switch.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a	rhk	27-Jun-2016	First release of driver
* </pre>
*
******************************************************************************/

#ifndef PMODENC_H
#define PMODENC_H


/****************** Include Files ********************/
#include "stdint.h"
#include "stdbool.h"
#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"

/************* Constant Dclarations *****************/
// register declarations
#define PMODENC_S00_AXI_SLV_REG0_OFFSET 0
#define PMODENC_S00_AXI_SLV_REG1_OFFSET 4
#define PMODENC_S00_AXI_SLV_REG2_OFFSET 8
#define PMODENC_S00_AXI_SLV_REG3_OFFSET 12

// canonical register declaration
#define PMODENC_STS_OFFSET		PMODENC_S00_AXI_SLV_REG0_OFFSET
#define PMODENC_CNTRL_OFFSET 	PMODENC_S00_AXI_SLV_REG1_OFFSET
#define PMODENC_COUNT_OFFSET	PMODENC_S00_AXI_SLV_REG2_OFFSET
#define PMODENC_RSVD00_OFFSET	PMODENC_S00_AXI_SLV_REG3_OFFSET



/**************************** Type Definitions *****************************/
typedef struct
{
	uint32_t	base_address;		// base address for pmodENC peripheral registers
	bool		is_ready;			// pmodENC driver has been successfully initialized	
	uint16_t	count;				// current rotary encoder count
} PmodENC, *p_pmodENC;

/***************** Macros (Inline function) Definitions *********************/

/**
 *
 * Write a value to a pmodENC register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the PMODENCdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void pmodENC_mWriteReg(u32 BaseAddress, unsigned RegOffset, uint32_t Data)
 *
 */
#define pmodENC_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (uint32_t)(Data))

/**
 *
 * Read a value from a PMODENC register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the PMODENC device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 PMODENC_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define pmodENC_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

	
/************************** Function Prototypes ****************************/

// self test and initialization functions
uint32_t pmodENC_selftest(uint32_t baseaddr);
uint32_t pmodENC_initialize(p_pmodENC instance, uint32_t baseaddr);

//rotary encoder functions
uint32_t pmodENC_init(p_pmodENC p_instance, int32_t incr_decr_cnt, bool no_neg);
uint32_t pmodENC_clear_count(p_pmodENC p_instance);
uint32_t pmodENC_read_count(p_pmodENC p_instance, uint16_t* p_rotary_count);

// button and switch functions
bool pmodENC_is_button_pressed(p_pmodENC p_instance);
bool pmodENC_is_switch_on(p_pmodENC p_instance);

#endif // PMODENC_H
