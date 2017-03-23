`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Roy Kravitz (roy.kravitz@pdx.edu)
// 
// Description: 
// ------------
//	This module debounces the slide switch and rotary encoder pushbutton on the PmodENC.  It works
//	by taking consecutive samples of the inputs and checks whether the value has changed.
//
// Dependencies: 
// -------------
// 	While not a "dependency" per se, the code in this module is based on debouncer.v provided
//	by Digilent as part of their PModENC reference design.  That design debounced the rotary
//	encoder inputs but that is done in encoder.v for this project.  Their debouncer code has
//	been repurposed to debounce the switch and button.  Interesting side note.  The Digilent
//	code was written by Josh Sackos who was a student of mine.
// 
// Revision:
// ---------
// 1.0	RK	 File Created
//
// Additional Comments:
// --------------------
// 
//////////////////////////////////////////////////////////////////////////////////
module debouncer
#(
	parameter RESET_POLARITY_LOW = 1,			// peripheral reset polarity
	parameter CLOCK_FREQ_HZ = 100000000,		// input clock frequency
	parameter DEBOUNCE_CLOCK_HZ = 1000000,		// debounce clock frequency
	parameter SIMULATE = 0						// Assert if simulating
)
(
    input clk,									// clock and reset
    input reset,
    input BTN_in,								// encoder pushbutton input
    input SWT_in,								// switch input
    output BTN_out,							// debounced pushbutton
    output SWT_out							// debounced switch
);

	localparam DEBOUNCE_PERIOD = (SIMULATE == 0) ? (CLOCK_FREQ_HZ / DEBOUNCE_CLOCK_HZ) - 1'b1 : 5;

	// internal variables
	wire reset_int;
	reg btnReg, swtReg;
	reg btnOutReg, swtOutReg;
	reg [31:0] sampleClk;

	// generate internal reset signal based on RESET_POLARITY_LOW
    // reset is asserted high in this module
    assign reset_int = RESET_POLARITY_LOW ? ~reset : reset;
    
    // map output ports
    assign BTN_out = btnOutReg;
    assign SWT_out = swtOutReg;
    
    // debounce logic
    always @(posedge clk) begin
    	if (reset_int) begin
    		sampleClk <= 32'd0;
    		btnReg <= 1'b0;
    		swtReg <= 1'b0;
    		btnOutReg <= 1'b0;
    		swtOutReg <= 1'b0;
    	end  // peripheral reset
    	else begin
    		// synchronize the button and switch
    		btnReg <= BTN_in;
    		swtReg <= SWT_in;
    		
    		// sample the inputs
    		if (sampleClk == DEBOUNCE_PERIOD) begin
    			if (btnReg == BTN_in) begin
    				btnOutReg <= BTN_in;
    			end // btn value is the same
    			
    			if (swtReg == SWT_in) begin
    				swtOutReg <= SWT_in;
    			end // switch value is the same
    			
    			// reset the sample clock counter
    			sampleClk <= 32'd0;
    		end // sample the inputs
    		else begin
    			sampleClk <= sampleClk + 1'b1;
    		end
    	end // do the debouncing
    end // debounce logic
    			
endmodule
