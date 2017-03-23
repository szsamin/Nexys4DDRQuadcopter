
/***************************** Include Files *******************************/
#include "pmodENC.h"
#include "xparameters.h"
#include "stdio.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/
#define READ_WRITE_MUL_FACTOR 0x10

/************************** Function Definitions ***************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the PMODENCinstance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 * @note	Only checks the read/write registers
 *
 */
uint32_t pmodENC_selftest(uint32_t baseaddr)
{
	int32_t write_loop_index;
	int32_t read_loop_index;


	xil_printf("******************************\n\r");
	xil_printf("* pmodENC Peripheral Self Test\n\r");
	xil_printf("******************************\n\n\r");

	/*
	 * Write to user logic slave module register(s) and read back
	 */
	xil_printf("User logic slave module test...\n\r");

	for (write_loop_index = 0 ; write_loop_index < 4; write_loop_index++)
	{
		// registers 0 and 2 are read-only
		if ( (1 == write_loop_index) || (3 == write_loop_index) )
		{
			pmodENC_mWriteReg (baseaddr, write_loop_index * 4, (write_loop_index + 1) * READ_WRITE_MUL_FACTOR);
		}
	}
	
	for (read_loop_index = 0 ; read_loop_index < 4; read_loop_index++)
	{
		// registers 0 and 2 are read-only
		if ( (1 == read_loop_index) || (3 == read_loop_index) )
		{	
			if ( pmodENC_mReadReg (baseaddr, read_loop_index * 4) != (read_loop_index + 1) * READ_WRITE_MUL_FACTOR)
			{
				xil_printf ("Error reading register value at address %x\n", (int32_t) baseaddr + read_loop_index * 4);
				return XST_FAILURE;
			}
		}
	}

	xil_printf("   - slave register write/read passed\n\n\r");

	return XST_SUCCESS;
}
