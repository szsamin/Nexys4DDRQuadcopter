`timescale 1ns / 1ps

// n4fpga.v - Top level module for the ECE 544 Getting Started project
//
// Copyright Chetan Bornarkar, Portland State University, 2016
// 
// Created By:	Roy Kravitz
// Modified By: Chetan Bornarkar
// Date:		23-December-2016
// Version:		1.0
//
// Description:
// ------------
// This module provides the top level for the Getting Started hardware.
// The module  assume that a PmodOLED is plugged into the JA 
// expansion ports and that a PmodENC is plugged into the JD expansion 
// port (bottom row).  
//////////////////////////////////////////////////////////////////////
module n4fpga(
    input				clk,			// 100Mhz clock input
    input				btnC,			// center pushbutton
    input				btnU,			// UP (North) pusbhbutton
    input				btnL,			// LEFT (West) pushbutton
    input				btnD,			// DOWN (South) pushbutton  - used for system reset
    input				btnR,			// RIGHT (East) pushbutton
	input				btnCpuReset,	// CPU reset pushbutton
    input	[15:0]		sw,				// slide switches on Nexys 4
    output	[15:0] 		led,			// LEDs on Nexys 4   
    output              RGB1_Blue,      // RGB1 LED (LD16) 
    output              RGB1_Green,
    output              RGB1_Red,
    output              RGB2_Blue,      // RGB2 LED (LD17)
    output              RGB2_Green,
    output              RGB2_Red,
    output [7:0]        an,             // Seven Segment display
    output [6:0]        seg,
    output              dp,             // decimal point display on the seven segment 
    
    input				uart_rtl_rxd,	// USB UART Rx and Tx on Nexys 4
    output				uart_rtl_txd,	
    
	inout   [7:0]       JA,             
	
	// GY 520 - Accelerometer and Gyro  									
    inout	[7:0] 		JB,				 
    
    // Bluetooth Communication                                      
    inout	[7:0] 		JC,				
    
    //Quadcopter PMOD - For PWM Control	
	inout	[7:0]		JD, 
	
	//Accelerometer
	input ACL_MISO,
	output ACL_MOSI,
	output ACL_SCLK,
	output ACL_CSN
	
					
);

// internal variables
// Clock and Reset 
wire				sysclk;             // 
wire				sysreset_n, sysreset;
wire                pw_det_clk;     // PWM detect clock 50 MHz
// Rotary encoder 
wire				rotary_a, rotary_b, rotary_press, rotary_sw;

//PWM Data
wire [3:0] pwm_2; 

// GPIO pins 
wire	[7:0]	    gpio_in;				// embsys GPIO input port
wire	[23:0]	    pwm_dc;		// hardware detected pwm duty cycles

wire pmod_out_pin10_i, pmod_out_pin10_io, pmod_out_pin10_o, pmod_out_pin10_t, pmod_out_pin1_i;
wire pmod_out_pin1_io, pmod_out_pin1_o, pmod_out_pin1_t, pmod_out_pin2_i, pmod_out_pin2_io, pmod_out_pin2_o;
wire pmod_out_pin2_t, pmod_out_pin3_i, pmod_out_pin3_io, pmod_out_pin3_o, pmod_out_pin3_t, pmod_out_pin4_i;
wire pmod_out_pin4_io, pmod_out_pin4_o, pmod_out_pin4_t, pmod_out_pin7_i, pmod_out_pin7_io, pmod_out_pin7_o;
wire pmod_out_pin7_t, pmod_out_pin8_i, pmod_out_pin8_io, pmod_out_pin8_o, pmod_out_pin8_t;
wire pmod_out_pin9_i, pmod_out_pin9_io, pmod_out_pin9_o, pmod_out_pin9_t;

// RGB LED 
wire                w_RGB1_Red, w_RGB1_Blue, w_RGB1_Green;

// IIC (I2C) pins
wire scl_i, scl_o, scl_t, scl_io;
wire sda_i, sda_o, sda_t, sda_io;


// LED pins 
wire    [15:0]      led_int;                // Nexys4IO drives these outputs

// 100 MMhz 
wire clockOut;
// Drive the leds from the signal generated by the microblaze 
assign led = led_int;                   // LEDs are driven by led

// make the connections
// system-wide signals
assign sysclk = clk;
assign sysreset_n = btnCpuReset;		// The CPU reset pushbutton is asserted low.  The other pushbuttons are asserted high
										// but the microblaze for Nexys 4 expects reset to be asserted low
assign sysreset = ~sysreset_n;			// Generate a reset signal that is asserted high for any logic blocks expecting it.

// PmodHB3 H-bridge connections
//assign JA[4] = pmodhb3_dir;
wire en; 

//assign JA[0] = pwm_2[0];
//assign JA[1] = pwm_2[1];
//assign JA[2] = pwm_2[2];
//assign JA[3] = pwm_2[3];

assign JD[0] = pwm_2[0];
assign JD[1] = pwm_2[1];
assign JD[2] = pwm_2[2];
assign JD[3] = pwm_2[3];

// JC Connector pins I2C interface to motion sensors
assign JB[0] = sda_io; // sda pin
assign JB[1] = scl_io; // scl pin

// Pmod Bluetooth connections 
assign JC[0] = pmod_out_pin1_io;
assign JC[1] = pmod_out_pin2_io;
assign JC[2] = pmod_out_pin3_io;
assign JC[3] = pmod_out_pin4_io;
assign JC[4] = pmod_out_pin7_io;
assign JC[5] = pmod_out_pin8_io;
assign JC[6] = pmod_out_pin9_io;
assign JC[7] = pmod_out_pin10_io;


// PmodENC signals
// JD - bottom row only
// Pins are assigned such that turning the knob to the right
// causes the rotary count to increment.

//assign rotary_a = JD[5];
//assign rotary_b = JD[4];
//assign rotary_press = JD[6];
//assign rotary_sw = JD[7];

// instantiate the embedded system
embsys EMBSYS
       (	    
	    // Bluetooth
	    .Pmod_out_pin10_i(pmod_out_pin10_i),
        .Pmod_out_pin10_o(pmod_out_pin10_o),
        .Pmod_out_pin10_t(pmod_out_pin10_t),
        .Pmod_out_pin1_i(pmod_out_pin1_i),
        .Pmod_out_pin1_o(pmod_out_pin1_o),
        .Pmod_out_pin1_t(pmod_out_pin1_t),
        .Pmod_out_pin2_i(pmod_out_pin2_i),
        .Pmod_out_pin2_o(pmod_out_pin2_o),
        .Pmod_out_pin2_t(pmod_out_pin2_t),
        .Pmod_out_pin3_i(pmod_out_pin3_i),
        .Pmod_out_pin3_o(pmod_out_pin3_o),
        .Pmod_out_pin3_t(pmod_out_pin3_t),
        .Pmod_out_pin4_i(pmod_out_pin4_i),
        .Pmod_out_pin4_o(pmod_out_pin4_o),
        .Pmod_out_pin4_t(pmod_out_pin4_t),
        .Pmod_out_pin7_i(pmod_out_pin7_i),
        .Pmod_out_pin7_o(pmod_out_pin7_o),
        .Pmod_out_pin7_t(pmod_out_pin7_t),
        .Pmod_out_pin8_i(pmod_out_pin8_i),
        .Pmod_out_pin8_o(pmod_out_pin8_o),
        .Pmod_out_pin8_t(pmod_out_pin8_t),
        .Pmod_out_pin9_i(pmod_out_pin9_i),
        .Pmod_out_pin9_o(pmod_out_pin9_o),
        .Pmod_out_pin9_t(pmod_out_pin9_t),
        //GPIO 
        .gpio_rtl_0_tri_i(xout),
        .gpio_rtl_tri_i(zout),
        .gpio_rtl_1_tri_i(yout),
        

        //PWM Out Signal 
        .pwm_2(pwm_2), 
        
        // Pmod Rotary Encoder
	    .pmodENC_A(rotary_a),
        .pmodENC_B(rotary_b),
        .pmodENC_btn(rotary_press),
        .pmodENC_sw(rotary_sw),
        
        // I2C pins (IIC)
        .sda_i(sda_i),
        .sda_o(sda_o),        
        .sda_t(sda_t),
        .scl_i(scl_i),
        .scl_o(scl_o),
        .scl_t(scl_t),
        
        // Seven Segment Display anode control  
        .an(an),
        .dp(dp),
        .led(led_int),
        .seg(seg),

        // Push buttons and switches  
        .btnC(btnC),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .sw(sw),
        
        //Gyro/Accelerometer Data 
        

        // reset and clock 
        .sysreset_n(sysreset_n),
        .clockOut(clockOut),
        .sysclk(sysclk),
        .clock_50MHz(pw_det_clk),

        // UART pins 
        .uart_rtl_rxd(uart_rtl_rxd),
        .uart_rtl_txd(uart_rtl_txd)
        );
        

IOBUF pmod_out_pin10_iobuf
   (.I(pmod_out_pin10_o),
    .IO(pmod_out_pin10_io),
    .O(pmod_out_pin10_i),
    .T(pmod_out_pin10_t));
    
IOBUF pmod_out_pin1_iobuf
   (.I(pmod_out_pin1_o),
    .IO(pmod_out_pin1_io),
    .O(pmod_out_pin1_i),
    .T(pmod_out_pin1_t)
    );
    
IOBUF pmod_out_pin2_iobuf
   (.I(pmod_out_pin2_o),
    .IO(pmod_out_pin2_io),
    .O(pmod_out_pin2_i),
    .T(pmod_out_pin2_t)
    );
    
IOBUF pmod_out_pin3_iobuf
   (.I(pmod_out_pin3_o),
    .IO(pmod_out_pin3_io),
    .O(pmod_out_pin3_i),
    .T(pmod_out_pin3_t)
    );
    
IOBUF pmod_out_pin4_iobuf
   (.I(pmod_out_pin4_o),
    .IO(pmod_out_pin4_io),
    .O(pmod_out_pin4_i),
    .T(pmod_out_pin4_t)
    );
    
IOBUF pmod_out_pin7_iobuf
   (.I(pmod_out_pin7_o),
    .IO(pmod_out_pin7_io),
    .O(pmod_out_pin7_i),
    .T(pmod_out_pin7_t)
    );
    
IOBUF pmod_out_pin8_iobuf
   (.I(pmod_out_pin8_o),
    .IO(pmod_out_pin8_io),
    .O(pmod_out_pin8_i),
    .T(pmod_out_pin8_t)
    );
    
IOBUF pmod_out_pin9_iobuf
   (.I(pmod_out_pin9_o),
    .IO(pmod_out_pin9_io),
    .O(pmod_out_pin9_i),
    .T(pmod_out_pin9_t)
    );


IOBUF i2c_sda_iobuf(
.I(sda_o),
.IO(sda_io),
.O(sda_i),
.T(sda_t));

IOBUF i2c_scl_iobuf(
.I(scl_o),
.IO(scl_io),
.O(scl_i),
.T(scl_t)
);
wire [11:0] xout,yout,zout; 
wire [11:0] magout,tempout; 

ADXL362Ctrl( 
            .SYSCLK(clockOut),      
            .RESET(sysreset),      
            .SCLK(ACL_SCLK),       
            .MOSI(ACL_MOSI),       
            .MISO(ACL_MISO),       
            .SS(ACL_CSN),         
            .ACCEL_X(xout),    
            .ACCEL_Y(yout),    
            .ACCEL_Z(zout)
);    
endmodule

