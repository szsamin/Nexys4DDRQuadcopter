/** @file PmodENC.c
*
* @author Roy Kravitz (roy.kravitz@pdx.edu)
* @copyright Portland State University, 2014, 2015
*
* @brief
* This header file contains the driver functions for the PmodENC custom AXI Slave peripheral.  
* The peripheral provides access to a Digilent PmodENC.  The PmodENC contains a quadrature
* encoder (the rotary encoder), a pushbutton (the shaft of the rotary encoder) and an 
* independent slide switch.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a	rhk	12/20/14	First release of driver
* </pre>
*
******************************************************************************/

/***************************** Include Files *******************************/
#include "pmodENC.h"

/************************** Constant Definitions *****************************/

// bit masks for the pmodENC peripheral

// status register
#define PMODENC_BTN_MSK			0x00000001
#define PMODENC_SW_MSK			0x00000002


// control register
#define PMODENC_CLRCNT_MSK 		0x00000080
#define PMODENC_LDCFG_MSK		0x00000040
#define PMODENC_NONEG_MSK		0x00000010
#define PMODENC_INCDECCNT_MSK	0x0000000F

// rotary count register
#define PMODENC_COUNT_MSK		0x0000FFFF
#define PMODENC_COUNT_LO_MSK	0x000000FF
#define PMODENC_COUNT_HI_MSK	0x0000FF00

/**************************** Type definitions ******************************/

/***************** Macros (Inline function) Definitions *********************/

/******************** Static variable declarations **************************/


/*********************** Private function prototypes ************************/

/************************** Public functions ********************************/

/****************************************************************************/
/**
* @brief Initialize the pmodENC peripheral driver
*
* Saves the base address of the pmodENC registers and runs the selftest
* (only the first time the peripheral is initialized). If the self-test passes
* the function sets the rotary encoder mode and clears the rotary encoder count.
*
* @param	p_instance is a pointer to the pmodENC driver instance 
* @param	baseaddr is the base address of the pmodENC perioheral register set
*
* @return
* 		- XST_SUCCESS	Initialization was successful.
*
* @note		This function can hang if the peripheral was not created correctly
* @note		The Base Address of the pmodENC peripheral registers will be in xparameters.h
*****************************************************************************/
uint32_t pmodENC_initialize(p_pmodENC p_instance, uint32_t baseaddr)
{
	
	// Save the Base Address of the pmodENC register set so we know where to point the driver
	p_instance->base_address = baseaddr;
	
	// Run the driver self-test.
	if ( XST_SUCCESS == pmodENC_selftest(p_instance->base_address ) )
	{
		p_instance->is_ready = true;
	}
	else
	{
		p_instance->is_ready = false;
	}
	
	// if pmodENC is ready configure the rotary encoder and clear the count
	if (p_instance->is_ready)
	{
		pmodENC_init(p_instance, 1, false);
		pmodENC_clear_count(p_instance);
	}
	
	return (p_instance->is_ready) ? XST_SUCCESS : XST_FAILURE;
}


/****************************************************************************/
/**
* @brief Initialize the Rotary Encoder control logic
*
* Configures the rotary encoder logic
*
* @param	p_instance is a pointer to the pmodENC driver instance 
*
* @param	inc_dec_cnt is the count for how much the rotary encorder increments
*			or decrements each time the rotary encoder is turned.  The count is
*			truncated to 4 bits
* @param	no_neg permits or prevents the rotary count from going below 0.,  no_neg
*			true say do not allow negative counts.
*
* @return	XST_SUCCESS
*
*****************************************************************************/
uint32_t pmodENC_init(p_pmodENC p_instance, int32_t incr_decr_cnt, bool no_neg)
{
	uint32_t enc_state;
	
	// build the new rotary encoder control state
	enc_state = (incr_decr_cnt & PMODENC_INCDECCNT_MSK);
	if (no_neg)
	{
		enc_state |= PMODENC_NONEG_MSK;
	}
	
	// kick off the command by writing 1 to	"Load Configuration" bit
	enc_state = (enc_state | PMODENC_LDCFG_MSK);
	pmodENC_mWriteReg(p_instance->base_address, PMODENC_CNTRL_OFFSET, enc_state);
	
	// end the command by toggling (writing 0) to "Load Configuration" bit
	pmodENC_mWriteReg(p_instance->base_address, PMODENC_CNTRL_OFFSET, (enc_state ^ PMODENC_LDCFG_MSK));
	
	return XST_SUCCESS;
}


/****************************************************************************/
/**
* @brief Clear the rotary encoder count
*
* Sets the rotary encoder count back to 0
*
* @param	p_instance is a pointer to the pmodENC driver instance 
*
*
* @return	XST_SUCCESS if the count was cleared, XST_FAILURE otherwise
*****************************************************************************/
uint32_t pmodENC_clear_count(p_pmodENC p_instance)
{
	uint32_t enc_state;
	uint16_t rotary_count;
	uint32_t sts;

	// kick off the command by writing 1 to	"Clear Count bit
	enc_state = PMODENC_CLRCNT_MSK;
	pmodENC_mWriteReg(p_instance->base_address, PMODENC_CNTRL_OFFSET, enc_state);
	
	// end the command by toggling (writing 0) to "Clear Count" bit
	pmodENC_mWriteReg(p_instance->base_address, PMODENC_CNTRL_OFFSET, (enc_state ^ PMODENC_CLRCNT_MSK));
	
	// read the count and update the pmodENC struct (a way to check that it has been cleared)
	pmodENC_read_count(p_instance, &rotary_count);
	if (0 == rotary_count)
	{
		p_instance->count = rotary_count;
		sts = XST_SUCCESS;
	}
	else
	{
		sts = XST_FAILURE;
	}
	
	return sts;
}


/****************************************************************************/
/**
* @brief read and return the count from the rotary encoder
*
* Returns the rotary count.  The rotary count is a 16-bit unsigned integer 
* Updates the count in the pmodENC instance if the count has changed
*
* @param	p_instance is a pointer to the pmodENC driver instance 
* @param	p_rotary_count is a pointer to where the rotary count is returned
*
* @return	XST_SUCCESS
*****************************************************************************/
uint32_t pmodENC_read_count(p_pmodENC p_instance, uint16_t* p_rotary_count)
{
	uint32_t count;
	
	count = pmodENC_mReadReg(p_instance->base_address, PMODENC_COUNT_OFFSET);
	if (count != p_instance->count)
	{
		p_instance->count = (uint16_t) count;
	}
	*p_rotary_count = p_instance->count;
	
	return XST_SUCCESS;
}


/****************************************************************************/
/**
* @brief Returns the state of the rotary encoder pusbbutton
*
* Reads the pmodENC status register to determine whether the rotary encoder shaft
* pushbutton is pressed
*
* @param	p_instance is a pointer to the pmodENC driver instance 
*
* @return	true if the button is pressed, false otherwise
*****************************************************************************/
bool pmodENC_is_button_pressed(p_pmodENC p_instance)
{
	uint32_t sts;
	
	sts = pmodENC_mReadReg(p_instance->base_address, PMODENC_STS_OFFSET);
	
	return (0 != (sts & PMODENC_BTN_MSK	)) ? true : false;
}


/****************************************************************************/
/**
* @brief Returns the state of the slide switch on the PmodENC
*
* Reads the pmodENC status register to determine whether the slide switch is on (up) 
*
* @param	p_instance is a pointer to the pmodENC driver instance 
*
* @return	true if the slide switch is on, false otherwise
*****************************************************************************/
bool pmodENC_is_switch_on(p_pmodENC p_instance)
{
	uint32_t sts;
	
	sts = pmodENC_mReadReg(p_instance->base_address, PMODENC_STS_OFFSET);
	
	return (0 != (sts & PMODENC_SW_MSK)) ? true : false;
}

