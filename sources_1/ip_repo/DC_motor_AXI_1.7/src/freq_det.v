`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineers: Francisco J Lopez Garibay, Shadman Samin
// Create Date: 02/16/2017 11:13:02 PM
// Module Name: freq_det
// Project Name:DC_motor_controller 
// Target Devices: Xilinx Artix-7 on Nexys4DDR board by Digilent 
// Tool Versions: Vivado 2016.2
// Description: Detect frequency from Hall sensor input.  
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module freq_det
#(
	//parameter declarations
	parameter 			FREQ_WIDTH = 8,	// Number of bits for freq
	parameter           CLK_FREQ_HZ = 100_000_000
	
)
(        // port declarations
	input 						clk, 					
	input						reset,					
	input	                 	in_sig,					// signal whose freq is to be measured	                 	green_sig,				// duty cycle for Green LED PWM channel
	output	[FREQ_WIDTH-1:0] 	freq					// freq of in_sig	
);
    
    localparam          cntr_width = 32; // internal counter width
    localparam          idle_after_s = 2; // max edge wait time in seconds
    reg [cntr_width-1:0]  cntr;     
    reg sig_del_1;        // delay one cycle
    reg rising;           // posedge of in_signal
    reg falling;          // negedge of in_signal 
    reg [cntr_width-1:0] count_high;       // stores counts for high in_sig
    reg [cntr_width-1:0] count_full;       // counts for full period of in_sig
    reg stopped;            // detect motor stopped 
        
    // delay in_sig one cycle
    always @(posedge clk) begin
        sig_del_1 <= in_sig;
    end 
    // Rising edge detection
    always @(posedge clk) begin
        if (reset)
            rising <= 1'b0;
        else if ( (sig_del_1==0) && (in_sig==1) ) 
            rising <= 1'b1;
        else 
            rising <= 1'b0;
    end 
    // Falling edge detection
    always @(posedge clk) begin
        if (reset)
            falling <= 1'b0;
        else if ( (sig_del_1==1) && (in_sig==0) ) 
            falling <= 1'b1;
        else 
            falling <= 1'b0;
    end     
    // implement counter, with 100 MHz clk overfows in 43 seconds                
    always @(posedge clk) begin
        if (reset || rising) // reset cntr on rising edge
            cntr <= {cntr_width{1'b0}};
        else 
            cntr <= cntr + 1;
    end
    // capture high and full period counts
    always @(posedge clk) begin
        if (reset || stopped)begin
            count_high <= {cntr_width{1'b0}};
            count_full  <= {cntr_width{1'b1}}; // defaults to max, see assign freq statement below
        end
        else if (falling) begin
            count_high <= cntr;
            count_full  <= count_full;
        end
        else if (rising) begin
            count_high <= count_high;
            count_full <= (cntr < 666667) ? count_full : cntr;
        end
    end
    
    // Detect motor stopped
    always @(posedge clk) begin
        if (reset || rising)
            stopped <= 0;
        else if (cntr == idle_after_s * CLK_FREQ_HZ)
            stopped <= 1;
    end
    
    assign freq = CLK_FREQ_HZ / count_full ;

endmodule

