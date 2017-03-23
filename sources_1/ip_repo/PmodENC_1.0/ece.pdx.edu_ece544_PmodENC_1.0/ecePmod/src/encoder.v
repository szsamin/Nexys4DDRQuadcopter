`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland Statue University
// Engineer: Roy Kravitz (roy.kravitz@pdx.edu)
//
// Description: 
// ------------
// This module does the processing for the rotary encoder on a Digilent PmodENC.  The
// rotary encoder is a Quadrature Encoder with two mechanical switches.  The module
// detects transitions on the mechanical switches and generates a pulse on the
// "encEvent" signal everytime the rotary encoder postion changes.  The events
// are used to to increment and decrement a counter which shows the "current"
// count.  The count is increased whenever the roatry encoder is turned to the
// right and decremented when the rotary encoder is turned to the left.
// 
// This module encodes the A and B quadrature input from the rotary encoder to two signals
// The "rotary_event" output  is pulsed when the rotary encoder knob is turned in either
// direction.  The "rotary_left" output indicates which direction the knob was turned.  A 1 on
// "rotary_left" indicates the knob was turned to the left, a 0 indicates the knob was turned
// to the right
//
// Dependencies: 
// -------------
// 	While not a "dependency" per se, the code in this module is based on rotary_filter.v,
//	a module provided by Ken Chapman (Xilinx Inc)
// 
// Revision:
// ---------
// 1.0	RK	File Created
//
// Additional Comments:
// --------------------
//	Although this module could be used in a standalone configuration the intent
//  is that the fucntionality will be wrapped into an AXI peripheral.
//
//	The code in this module assumes that the input clock "clk" is running much
//	much faster than the rotary encoder position can be changed.
// 
//////////////////////////////////////////////////////////////////////////////////
module encoder
#(
	parameter CNTR_WIDTH = 16, 				// rotary counter width
	parameter RESET_POLARITY_LOW = 1,		// reset signal polarity
	parameter DFLT_INCRDECRVALUE = 1,		// value to increment/decrement rotary count
	parameter DFLT_NONEG = 0				// allow count < 0 (or not)
)
(	
    input clk,								// clock and reset for the encoder moudle
    input reset,
    input A,								// A and B switch inputs from rotary encoder
    input B,
    input clearCount,						// Pulse to clear the rotary count
    input loadConfig,						// Pulse to load rotary encoder configuration
    input noNeg,							// Asserted to keep the rotary count >= 0
    input [3:0] incrDecrValue,				// Amouny to update the rotary count
    output encEvent,						// Pulsed whenever rotary encoder position changes
    output encLeft,  						// Asserted if last rotary encoder movement was to the left
    output signed [CNTR_WIDTH-1:0] count	// Rotary count (signed number)
 );
    
	// declare internal variables
	reg	A_int, B_int;						// synchronization flip flops
    reg	q1,q2, dly_q1;						// state flip-flops 
    reg eventReg, dirReg;					// event and direction registers
    
    reg noNegReg;							// Register to store whether to allow count < 0
    reg signed [4:0] incrDecrValReg;		// Register to store value to increment or decrement the count by
    										// make it 5 bits wide because it is signed and we want to support
    										// incre/decr values up to 4'b1111
    reg signed [CNTR_WIDTH-1:0] countReg;	// Rotary count register
    
    wire reset_int;							// internal reset signal
    
    // generate internal reset signal based on RESET_POLARITY_LOW
    // reset is asserted high in this module
    assign reset_int = RESET_POLARITY_LOW ? ~reset : reset;
    
    // map the output ports
    assign count = countReg;
    assign encEvent = eventReg;
    assign encLeft = dirReg;
    
    // Rotary event and direction generation (taken almost verbatim from rotary_event.v)   
    // The rotary switch contacts are filtered using their offset (one-hot) style to  
    // clean them. Circuit concept by Peter Alfke.
    always @(posedge clk) begin
    	// Synchronize inputs to clock domain using flip-flops in input/output blocks.
    	A_int <= A;
    	B_int <= B;
    	
    	case ({B_int, A_int})
    		2'b00: 	begin
    					q1 <= 1'b0;         
    					q2 <= q2;
    			   	end
    		2'b01: 	begin
    					q1 <= q1;         
    					q2 <= 1'b0;
    			   	end
 			2'b10: 	begin
    					q1 <= q1;         
    					q2 <= 1'b1;
    			   	end
 			2'b11: 	begin
    					q1 <= 1'b1;         
    					q2 <= q2;
    			   	end
    	endcase
    end // rotary switch filter
    
    // The rising edges of 'q1' indicate that a rotation has occurred and the 
    // state of 'q2' at that time will indicate the direction. 
    always @(posedge clk) begin
    	// catch the first edge
        dly_q1 <= q1;
      	if (q1 && ~dly_q1) begin
    		// rotary position has changed
        	eventReg <= 1;
       		dirReg <= q2;
       	end
       	else begin
    	// rotary position has not changed
        	eventReg <= 0;
        	dirReg <= dirReg;
      	end
     end //edge detect
     
     // Rotary counter
     always @(posedge clk) begin
     	if (reset_int) begin
     		countReg <= {CNTR_WIDTH{1'b0}};
     	end // peripheral reset
     	else if (clearCount) begin
     		countReg <= {CNTR_WIDTH{1'b0}};
     	end // clear count pulse
     	else if (eventReg) begin
     		case ({dirReg, noNegReg})
     			2'b00:	begin		// dir = right, noNeg = don't care
     						countReg <= countReg + incrDecrValReg;
     					end
     			2'b01:	begin		// dir = right, noNeg = don't care
     						countReg <= countReg + incrDecrValReg;
     					end
     			2'b10:	begin		// dir = left, noNeg = can go negative
     						countReg <= countReg - incrDecrValReg;
     					end
    			2'b11: begin		// dir = left, noNeg = cannot go negative
     						if ((countReg - incrDecrValReg) <= 0) begin
     							countReg <= {CNTR_WIDTH{1'b0}};
     						end
     						else begin
     						    countReg <= countReg - incrDecrValReg;
     						end	
     					end
     		endcase
     	end // rotary event
     	else begin
     		countReg <= countReg;
     	end // no change
     end // Rotary Counter
     
     // configuration bits
     always @(posedge clk) begin
     	if (reset_int) begin
     		incrDecrValReg <= {1'b0, DFLT_INCRDECRVALUE};
     		noNegReg <= DFLT_NONEG;
     	end // peripheral reset
     	else if (loadConfig) begin
   			incrDecrValReg <= {1'b0, incrDecrValue};
     	    noNegReg <= noNeg; 
     	end // load config bits
     	else begin
     		incrDecrValReg <= incrDecrValReg;
     		noNegReg <= noNegReg;
     	end // no change
     end // configuration bits 		
     		    
endmodule
