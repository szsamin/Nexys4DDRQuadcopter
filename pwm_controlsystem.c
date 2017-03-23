/**
 *
 * @file pwm_controlsystem.c
 *
 * @author Francisco Lopez (fjl@pdx.edu)
 * @author Jaisil Muttakulath Joy (jaisil@pdx.edu)
 * @author Shadman Samin (shadman@pdx.edu)
 * @author Spoorthi Chandra Kanchi (spoorthi@pdx.edu)
 * @copyright Portland State University, 2016-2017
 *
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "platform.h"
#include "xparameters.h"
#include "xstatus.h"
#include "nexys4IO.h"
#include "xintc.h"
#include "xbasic_types.h"
#include "xil_types.h"
#include "xil_assert.h"
#include "xuartlite.h"
#include "xil_cache.h"
#include "xgpio.h"
#include "math.h"							//includes trigonometric functions
#include "PmodBT2.h"						//driver for Bluetooth communication
#include "PWM.h"							//driver for PWM control


/************************** Constant Definitions ****************************/
// Clock frequencies
#define CPU_CLOCK_FREQ_HZ		XPAR_CPU_CORE_CLOCK_FREQ_HZ
#define AXI_CLOCK_FREQ_HZ		XPAR_CPU_M_AXI_DP_FREQ_HZ

// AXI timers parameters
#define AXI_TIMER_FREQ_HZ		XPAR_AXI_TIMER_0_CLOCK_FREQ_HZ

// Definitions for peripheral NEXYS4IO
#define NX4IO_DEVICE_ID			XPAR_NEXYS4IO_0_DEVICE_ID
#define NX4IO_BASEADDR			XPAR_NEXYS4IO_0_S00_AXI_BASEADDR
#define NX4IO_HIGHADDR			XPAR_NEXYS4IO_0_S00_AXI_HIGHADDR


// Fixed Interval timer - 100 MHz input clock, 40KHz output clock
#define FIT_IN_CLOCK_FREQ_HZ	CPU_CLOCK_FREQ_HZ
#define FIT_CLOCK_FREQ_HZ		40000
#define FIT_COUNT				(FIT_IN_CLOCK_FREQ_HZ / FIT_CLOCK_FREQ_HZ)
#define FIT_COUNT_1MSEC			40

// Interrupt Controller parameters
#define INTC_DEVICE_ID			XPAR_INTC_0_DEVICE_ID
#define FIT_INTERRUPT_ID		XPAR_MICROBLAZE_0_AXI_INTC_FIT_TIMER_1_INTERRUPT_INTR

// GPIO 0 parameters
#define GPIO_0_DEVICE_ID		 	0
#define GPIO_0_INPUT_0_CHANNEL		1
#define GPIO_0_INPUT2_0_CHANNEL		2
#define GPIO_0_BASEADDR				0x40000000

// GPIO 1 parameters
#define GPIO_1_DEVICE_ID		 	1
#define GPIO_1_INPUT_0_CHANNEL		1
#define GPIO_1_INPUT2_0_CHANNEL		2
#define GPIO_1_BASEADDR				0x40010000

// Control macros for quadcopter
#define ROLL_SENSITIVITY 		8					//defines the impact of change in roll value on motor speed
#define PITCH_SENSITIVITY 		8					//defines the impact of change in pitch value on motor speed
#define THROTTLE_SENSITIVITY 	70					//defines the impact of change in throttle value on motor speed
#define CALIBRATION_MODE		0					//set to 1 when the motors need to be calibrated

#define MOTOR_1					0					//represents first brushless motor
#define MOTOR_2					1					//represents second brushless motor
#define MOTOR_3					2					//represents third brushless motor
#define MOTOR_4					3					//represents fourth brushless motor


/************************** Function Prototypes *****************************/

void 		FIT_Handler(void);
int 		do_init_nx4io(u32 BaseAddress);
int 		do_init();
int 		char2int (char *array, size_t n);
void 		set_control_dc();
int 		convert_from_two_complement(int num);
double 		normalize_angle(double angle);

/************************** Instance declarations *****************************/
XIntc 		IntrptCtlrInst;						// Interrupt Controller instance
PmodBT2 	myDevice;							// represents the bluetooth device
XGpio		GPIOInst0;							// GPIO instance, gets the X,Y values from accelerometer
XGpio		GPIOInst1;							// GPIO instance, gets the Z values from accelerometer


volatile int			x = 0;					//holds the bits read from gpio 0 input port 1
volatile int			y = 0;					//holds the bits read from gpio 0 input port 2
volatile int			z = 0;					//holds the bits read from gpio 1 input port 1

volatile int 			fit_count=0;			//used to fine tune the sampling rate of fit handler
volatile char * 		data=0;					//data buffer for the data received through Bluetooth

volatile u32			Period = 100000;		//defines number of clock cycles required for one cycle of PWM signal
volatile int 		   	set_throttle = 0;		//the throttle value received from android
volatile int 		   	set_roll = 0;			//the roll value received from android
volatile int 		   	set_pitch = 0;			//the pitch value received from android

int 					err_sum_max = 200;		//max possible error for integral control
int 					err_sum_min = -200;		//min possible error for integral control

int						motor1_control_dc=0;	//duty cycle for brushless motor 1
int						motor2_control_dc=0;	//duty cycle for brushless motor 2
int						motor3_control_dc=0;	//duty cycle for brushless motor 3
int						motor4_control_dc=0;	//duty cycle for brushless motor 4

float 					fXg = 0;				//filtered acceleration in X axis
float 					fYg = 0;				//filtered acceleration in Y axis
float 					fZg = 0;				//filtered acceleration in Z axis

float 					prev_fXg = 0;			//previous acceleration in X axis, for filtering
float 					prev_fYg = 0;			//previous acceleration in Y axis, for filtering
float 					prev_fZg = 0;			//previous acceleration in Z axis, for filtering

float 					alpha = 0.5;			//alpha value for low pass filtering
float 					calculated_pitch = 0.0;	//pitch value calculated based on acceleration given by accelerometer
float 					calculated_roll = 0.0;	//pitch value calculated based on acceleration given by accelerometer

float 					corrected_pitch = 0.0;	//corrected pitch value given from PID control system
float 					corrected_roll = 0.0;	//corrected roll value given from PID control system
float 					corrected_throttle = 0.0;//corrected throttle value given from PID control system

//Control system parameters
float 					kp=3.0;
float 					ki=0.2;
float 					kd =1.5;

/************************** MAIN PROGRAM ************************************/
int main()
{
	int sts;

	Xil_ICacheEnable();
	Xil_DCacheEnable();

	//variables for generating pitch control signals
	float 		err_pitch, err_old_pitch, err_sum_pitch, err_chg_pitch;
	float 		p_delta_pitch, i_delta_pitch, d_delta_pitch, delta_pitch;

	//variables for generating roll control signals
	float 		err_roll, err_old_roll, err_sum_roll, err_chg_roll;
	float 		p_delta_roll, i_delta_roll, d_delta_roll, delta_roll;

	init_platform();
	sts = do_init();
	if (XST_SUCCESS != sts)
	{
		exit(1);
	}
	microblaze_enable_interrupts();

	while(1)
	{

		// Process only if there is any data received present in the bluetooth buffer
		if(strlen(myDevice.recv) > 0)
		{
			int 	counter_throttle = 0;		//count variable for array that stores the parsed throtte values
			int 	counter_pitch = 0;			//count variable for array that stores the parsed pitch values
			int 	counter_roll = 0;			//count variable for array that stores the roll pitch
			char 	Throttle[100];				//holds the parsed throttle values from bluetooth
			char 	Pitch[100];					//holds the parsed pitch values from bluetooth
			char 	Roll[100];					//holds the parsed roll values from bluetooth
			int 	flag = 0;					//flag to parse throttle value
			int 	control_flag =0;			//flag to parse roll and pitch value
			int 	pitch_flag=0;				//flag to parse pitch value
			int 	roll_flag=0;				//flag to parse roll value
			int 	set_roll_temp, set_pitch_temp,set_throttle_temp;

			for(int i=0; i<strlen(myDevice.recv); i++)
			{
				//The throttle value is sent from the bluetooth enclosed between two 'A' eg A50A
				//setting the flags to parse the throttle value
				if((flag == 0) && (myDevice.recv[i] == 'A'))
				{
					flag = 1;
				}
				else if((flag == 1) && (myDevice.recv[i] == 'A'))
				{
					//clearing the flag after the end of throttle value
					flag = 0;
				}

				//The roll and pitch values are sent from the bluetooth enclosed between two 'P'
				//Eg: PX50Y50P
				//setting the flags to parse the roll and pitch values
				if((control_flag == 0) && (myDevice.recv[i] == 'P'))
				{
					control_flag = 1;
				}
				else if((control_flag == 1) && (myDevice.recv[i] == 'P'))
				{
					//clearing the flag at the end of after detecting final 'P'
					control_flag = 0;
				}

				//setting the flag to parse pitch
				//pitch value starts with an 'X' , eg: X50
				if(control_flag ==1 && pitch_flag ==0 && (myDevice.recv[i] == 'X') )
				{
					pitch_flag = 1;
				}
				else if(control_flag ==1 && pitch_flag ==1  &&  (myDevice.recv[i] == 'Y'))
				{
					pitch_flag = 0;
				}

				//setting the flag to parse roll
				//pitch value starts with an 'Y' , eg: Y50
				if(control_flag ==1 && roll_flag==0 && (myDevice.recv[i] == 'Y') )
				{
					roll_flag = 1;
				}
				else if(control_flag ==0 && roll_flag==1 && (myDevice.recv[i] == 'P'))
				{
					roll_flag = 0;
				}

				//parsing throttle as long as the throttle flag is set
				if((flag == 1) && (myDevice.recv[i] != 'A')){
					Throttle[counter_throttle] = myDevice.recv[i];
					Throttle[counter_throttle+1] = '\0';
					Throttle[counter_throttle+2] = '\0';
					counter_throttle++;
				}

				//parsing pitch as long as the pitch flag is set
				if((pitch_flag == 1) && (myDevice.recv[i] != 'X')){
					Pitch[counter_pitch] = myDevice.recv[i];
					Pitch[counter_pitch+1] = '\0';
					Pitch[counter_pitch+2] = '\0';
					counter_pitch++;
				}

				//parsing roll as long as the roll flag is set
				if((roll_flag == 1) && (myDevice.recv[i] != 'Y')){
					Roll[counter_roll] = myDevice.recv[i];
					Roll[counter_roll+1] = '\0';
					Roll[counter_roll+2] = '\0';
					counter_roll++;
				}
			}

			//converting parsed values to integers
			set_throttle_temp = char2int(Throttle, 3);
			set_pitch_temp = char2int(Pitch, 3)-30;
			set_roll_temp = char2int(Roll, 3)-30;

			//Normalizing the values
			if(roll_flag == 0 && pitch_flag ==0 && flag== 0 && control_flag==0)
			{
				set_throttle = set_throttle_temp > 100? set_throttle: set_throttle_temp;
				set_pitch = set_pitch_temp;
				set_roll = set_roll_temp;
			}


		}

		//reading the X,Y,Z values of acceleration from GPIO
		x = XGpio_DiscreteRead(&GPIOInst0, GPIO_0_INPUT_0_CHANNEL);
		z = XGpio_DiscreteRead(&GPIOInst0, GPIO_0_INPUT2_0_CHANNEL);
		y = XGpio_DiscreteRead(&GPIOInst1, GPIO_1_INPUT_0_CHANNEL);

		//converting acceleration which is in 2s complement format to normal form
		x = convert_from_two_complement(x);
		y = convert_from_two_complement(y);
		z = convert_from_two_complement(z);

		// applying Low Pass filter on the signals
		fXg = (x) * alpha + (prev_fXg * (1.0 - alpha));
		fYg = (y) * alpha + (prev_fYg * (1.0 - alpha));
		fZg = (z) * alpha + (prev_fZg * (1.0 - alpha));

		//saving the previous state for filtering operation
		prev_fXg = fXg;
		prev_fYg = fYg;
		prev_fZg = fZg;

		//converting the values to proper range
		fXg = x*((2)/(pow(2,11)));
		fYg = y*((2)/(pow(2,11)));
		fZg = z*((2)/(pow(2,11)));


		//Pitch and roll Equation
		calculated_pitch = ((atan2(fYg, sqrt(fXg * fXg + fZg * fZg)) * 180.0) / M_PI )+1;
		calculated_roll  = normalize_angle(((atan2(-fXg, fZg)*180.0)/M_PI)-93);

		// Proportional control for pitch
		err_pitch = set_pitch - calculated_pitch;
		p_delta_pitch = err_pitch * kp;

		// Integral Control for pitch
		err_sum_pitch += err_pitch;
		if (err_sum_pitch > err_sum_max) err_sum_pitch = err_sum_max;
		else if (err_sum_pitch < err_sum_min) err_sum_pitch =err_sum_min;
		i_delta_pitch = err_sum_pitch * ki;

		// Derivative Control for pitch
		err_chg_pitch = err_pitch - err_old_pitch;
		d_delta_pitch = err_chg_pitch * kd;
		err_old_pitch=err_pitch;

		// Delta with PID Control
		delta_pitch = p_delta_pitch + i_delta_pitch + d_delta_pitch;
		corrected_pitch = set_pitch + delta_pitch;

		// Proportional control for roll
		err_roll = set_roll - calculated_roll;
		p_delta_roll = err_roll * kp;

		// Integral Control for roll
		err_sum_roll += err_roll;
		if (err_sum_roll > err_sum_max) err_sum_roll = err_sum_max;
		else if (err_sum_roll < err_sum_min) err_sum_roll =err_sum_min;
		i_delta_roll = err_sum_roll * ki;

		// Derivative Control for roll
		err_chg_roll = err_roll - err_old_roll;
		d_delta_roll = err_chg_roll * kd;
		err_old_roll=err_roll;

		// Delta with PID Control
		delta_roll = p_delta_roll + i_delta_roll + d_delta_roll;
		corrected_roll = set_roll + delta_roll;

		//compensation for throttle value, when quadcopter performs roll or pitch movements
		//the additional throttle required is proportional to the cosine of roll and pitch angle
		corrected_throttle /= cos(calculated_pitch)*cos(calculated_roll);

		//calculating the duty cycle values for 4 motors
		set_control_dc();

		//writing the controlled duty cycle values to 4 motors
		PWM_Set_Duty(XPAR_PWM_0_PWM_AXI_BASEADDR,motor1_control_dc, MOTOR_1);
		PWM_Set_Duty(XPAR_PWM_0_PWM_AXI_BASEADDR,motor2_control_dc, MOTOR_2);
		PWM_Set_Duty(XPAR_PWM_0_PWM_AXI_BASEADDR,motor3_control_dc, MOTOR_3);
		PWM_Set_Duty(XPAR_PWM_0_PWM_AXI_BASEADDR,motor4_control_dc, MOTOR_4);

	}
}

/*
 * Normalizes the angle,
 * eg: converts -360 to 0
 * */
double normalize_angle(double angle)
{
	double normalized;

	if( angle >= -270 && angle <= -180)
	{
		normalized= (double)360+angle;
	}
	else
	{
		normalized = angle;
	}

	return  normalized;
}

/*
 * Converts a number in 2s complement to normal form
 * */
int convert_from_two_complement(int num)
{
	const int negative = (num & (1 << 11)) != 0;
	int nativeInt;

	if (negative)
		nativeInt = num | ~((1 << 12) - 1);
	else
		nativeInt = num;

	return nativeInt;

}

/*
 * Sets the control duty cycle for 4 motors
 *
 * */
void set_control_dc()
{

	//logic to control pitch
	// M1= T+P-R
	// M2= T+P+R
	// M3= T-P+R
	// M4= T-P-R

	if(CALIBRATION_MODE == 1)
	{
		//for calibration
		motor1_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle);
		motor2_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle);
		motor3_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle);
		motor4_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle) ;
	}
	else
	{
		if(set_throttle >= 5)
		{
			//calculating the control signals for 4 motors
			motor1_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle) + (PITCH_SENSITIVITY * corrected_pitch) -(ROLL_SENSITIVITY * corrected_roll);
			motor2_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle) + (PITCH_SENSITIVITY * corrected_pitch) +(ROLL_SENSITIVITY * corrected_roll);
			motor3_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle) - (PITCH_SENSITIVITY * corrected_pitch) +(ROLL_SENSITIVITY * corrected_roll);
			motor4_control_dc = (14000 + THROTTLE_SENSITIVITY * set_throttle) - (PITCH_SENSITIVITY * corrected_pitch) -(ROLL_SENSITIVITY * corrected_roll);
		}
		else
		{
			//stopping motors if throttle is less than the threshold
			motor1_control_dc = 14000;
			motor2_control_dc = 14000;
			motor3_control_dc = 14000;
			motor4_control_dc = 14000;

		}
	}
}

/* convert character array to integer */
int char2int (char *array, size_t n)
{
	int number = 0;
	int mult = 1;

	n = (int)n < 0 ? -n : n;       /* quick absolute value check  */

	/* for each character in array */
	while (n--)
	{
		/* if not digit or '-', check if number > 0, break or continue */
		if ((array[n] < '0' || array[n] > '9') && array[n] != '-') {
			if (number)
				break;
			else
				continue;
		}

		if (array[n] == '-') {      /* if '-' if number, negate, break */
			if (number) {
				number = -number;
				break;
			}
		}
		else {                      /* convert digit to numeric value   */
			number += (array[n] - '0') * mult;
			mult *= 10;
		}
	}

	return number;
}

/**
 * Function Name: do_init()
 *
 * Return: XST_FAILURE or XST_SUCCESS
 *
 * Description: Initialize the AXI timer, gpio, interrupt, FIT timer, Encoder,
 * 				OLED display
 */
int do_init()
{
	int status;

	// initialize the Nexys4 driver and (some of)the devices
	status = (uint32_t) NX4IO_initialize(NX4IO_BASEADDR);
	if (status == XST_FAILURE)
	{
		exit(1);
	}

	NX4IO_setLEDs(0x0000);

	// Adding BT2 Module
	BT2_begin(&myDevice, XPAR_PMODBT2_0_AXI_LITE_GPIO_BASEADDR, XPAR_PMODBT2_0_AXI_LITE_UART_BASEADDR);

	// PWM Enable
	PWM_Enable(XPAR_PWM_0_PWM_AXI_BASEADDR);
	PWM_Set_Period(XPAR_PWM_0_PWM_AXI_BASEADDR, Period);


	// initialize the GPIO instances
	status = XGpio_Initialize(&GPIOInst0, GPIO_0_DEVICE_ID);
	if (status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}
	xil_printf("Debug GPIO");

	// initialize the GPIO instances
	status = XGpio_Initialize(&GPIOInst1, GPIO_1_DEVICE_ID);
	if (status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	XGpio_SetDataDirection(&GPIOInst0, GPIO_0_INPUT_0_CHANNEL, 0xFFF);
	XGpio_SetDataDirection(&GPIOInst0, GPIO_0_INPUT2_0_CHANNEL, 0xFFF);

	XGpio_SetDataDirection(&GPIOInst1, GPIO_1_INPUT_0_CHANNEL, 0xFFF);
	XGpio_SetDataDirection(&GPIOInst1, GPIO_1_INPUT2_0_CHANNEL, 0xFFF);

	// initialize the interrupt controller
	status = XIntc_Initialize(&IntrptCtlrInst, INTC_DEVICE_ID);
	if (status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	// connect the fixed interval timer (FIT) handler to the interrupt
	status = XIntc_Connect(&IntrptCtlrInst, FIT_INTERRUPT_ID,
			(XInterruptHandler)FIT_Handler,
			(void *)0);
	if (status != XST_SUCCESS)
	{
		return XST_FAILURE;

	}

	// start the interrupt controller such that interrupts are enabled for
	// all devices that cause interrupts.
	status = XIntc_Start(&IntrptCtlrInst, XIN_REAL_MODE);
	if (status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	// enable individual interrupts
	XIntc_Enable(&IntrptCtlrInst, FIT_INTERRUPT_ID);
	XIntc_Enable(&IntrptCtlrInst, XPAR_MICROBLAZE_0_AXI_INTC_PMODBT2_0_BT2_UART_INTERRUPT_INTR);
	return XST_SUCCESS;
}

/*********************** HELPER FUNCTIONS ***********************************/


/****************************************************************************/
/**
 * initialize the Nexys4 LEDs and seven segment display digits
 *
 * Initializes the NX4IO driver, turns off all of the LEDs and blanks the seven segment display
 *
 * @param	BaseAddress is the memory mapped address of the start of the Nexys4 registers
 *
 * @return	XST_SUCCESS if initialization succeeds.  XST_FAILURE otherwise
 *
 * @note
 * The NX4IO_initialize() function calls the NX4IO self-test.  This could
 * cause the program to hang if the hardware was not configured properly
 *
 *****************************************************************************/
int do_init_nx4io(u32 BaseAddress)
{
	int sts;

	// initialize the NX4IO driver
	sts = NX4IO_initialize(BaseAddress);
	if (sts == XST_FAILURE)
		return XST_FAILURE;

	// turn all of the LEDs off using the "raw" set functions
	// functions should mask out the unused bits..something to check w/
	// the debugger when we bring the drivers up for the first time
	NX4IO_setLEDs(0x0000);
	NX4IO_RGBLED_setRGB_DATA(RGB1, 0xFF000000);
	NX4IO_RGBLED_setRGB_DATA(RGB2, 0xFF000000);
	NX4IO_RGBLED_setRGB_CNTRL(RGB1, 0xFFFFFFF0);
	NX4IO_RGBLED_setRGB_CNTRL(RGB2, 0xFFFFFFFC);

	// set all of the display digits to blanks and turn off
	// the decimal points using the "raw" set functions.
	// These registers are formatted according to the spec
	// and should remain unchanged when written to Nexys4IO...
	// something else to check w/ the debugger when we bring the
	// drivers up for the first time
	NX4IO_SSEG_setSSEG_DATA(SSEGHI, 0x0058E30E);
	NX4IO_SSEG_setSSEG_DATA(SSEGLO, 0x00144116);

	return XST_SUCCESS;

}


/**************************** INTERRUPT HANDLERS ******************************/


/*******************************************************************************
 * Fixed interval timer interrupt handler
 *
 * Reads the bluetooth signals
 *
 *****************************************************************************/

void FIT_Handler(void)
{
	int len = 0;

	// reads the bluetooth values at every 5 milli seconds
	while(fit_count >= (FIT_COUNT_1MSEC * 5))
	{

		len = BT2_getData(&myDevice, 20);
		if(len > 0){
			XUartNs550_Recv(&myDevice.BT2Uart, (u8*)&myDevice.recv, 20);
			data = myDevice.recv;
		}
		fit_count=0;
	}
	fit_count++;
}
