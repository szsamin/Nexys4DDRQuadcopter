`timescale 1us / 1us
// PWM_out - DC motor control, PWM signal to Pmod H-bridge
//
// Created By:	Francisco J Lopez, Shadman Samin
// Date:		17-February-2017
// Version:		1.0
//
// Description:
//  Implements PWM output from an 8 bit duty cycle value

///////////////////////////////////////////////////////////////////////////////////
module PWM_out
#(
	//parameter declarations
	parameter	DUTY_WIDTH = 15	// Number of duty cycle bits(Default = 8-bit)
)
(
	// port declarations
	input 				clk,		// PWM clock (500kHz / 255 gives about 2kHz PWM freq, 8 MHz beyond audible noise)
	input				reset,		// system reset
	input	[DUTY_WIDTH-1:0]	duty,				// duty cycle
	output reg     pwm_out			// PWM output to Pmod H-bridge
);

reg [DUTY_WIDTH-1:0] pwm_cntr;
               				
// PWM counter
// counter overflows to restart PWM period
always @(posedge clk) begin
		if (reset) begin
			pwm_cntr <= {DUTY_WIDTH{1'b0}};
		end
		else begin
			pwm_cntr <= pwm_cntr + 1'b1;	
		end
end // pwm counter

// PWM output generation
// Block can be combinational because the counters are synchronized to the clock
always @* begin
    if (pwm_cntr < duty) 
        pwm_out = 1'b1;
    else
        pwm_out = 1'b0;            
end // PWM output generation

endmodule
	
