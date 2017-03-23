//////////////////////////////////////////////////////////////////////////////////
// Company: Portland Statue University
// Engineer: Roy Kravitz (roy.kravitz@pedx.edu)
//
// Description: 
// ------------
// This module is the top level for the pmodENC peripheral.
//
// Dependencies: 
// -------------
// 	This module is dependent on encocer .v (Rotary Encoder hardware) and 
//	debouncer.v (Debounces the inputs to the rotary encoder) and makes use
//	of signals produced in the AXI interface module for the periphal
// 
// Revision:
// ---------
// 1.0	RK	File Created
//
// Additional Comments:
// --------------------
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ps

	module pmodENC_v1_0 #
	(
		// Users to add parameters here
		parameter RESET_POLARITY_LOW = 1,			// peripheral reset polarity
		parameter SIMULATE = 0,						// Assert if simulating
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4

	)
	(
		// Users to add ports here
		input wire	pmodENC_A,			// A input from rotary encoder
		input wire	pmodENC_B,					// B input from rotary encoder
		input wire	pmodENC_btn,				// PmodEnc pushbutton
		input wire	pmodENC_sw,				// PmodEnc toggle (slide) switch
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready

	);
	
	// declare the interconnect wires
	wire LdCfg, ClrCnt, NoNeg;
	wire btnOut, swtOut;
	wire [3:0] IncrDecrValue;
	wire signed [15:0] RotCnt;
	wire EncEvent;
	
// Instantiation of Axi Bus Interface S00_AXI
	pmodENC_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) pmodENC_v1_0_S00_AXI_inst (
		// Peripheral-specific signals (to/from register bits
		.BTN_DB(btnOut),
		.SWT_DB(swtOut),
		.RotCnt(RotCnt),
		.LdCfg(LdCfg),
		.ClrCnt(ClrCnt),
		.IncrDecrValue(IncrDecrValue),
		.NoNeg(NoNeg),
	
		// AXI Lite Signals
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);


	// Add user logic here
	
	// instantiate the debouncer for the pushbutton and switch
	debouncer #(
		.RESET_POLARITY_LOW(RESET_POLARITY_LOW),
		.SIMULATE(SIMULATE)
	) PMODENC_DEBOUNCER
	(
	    .clk(s00_axi_aclk),
	    .reset(s00_axi_aresetn),
	    .BTN_in(pmodENC_btn),
	    .SWT_in(pmodENC_sw),
	    .BTN_out(btnOut),
	    .SWT_out(swtOut)
	);
	
	// instantiate the encoder logic
	encoder #(
		.RESET_POLARITY_LOW(RESET_POLARITY_LOW)
	) PMODENC_ENCODER
	(
		.clk(s00_axi_aclk),
		.reset(s00_axi_aresetn),
		.A(pmodENC_A),
		.B(pmodENC_B),
		.clearCount(ClrCnt),
		.loadConfig(LdCfg),
		.noNeg(NoNeg),
		.incrDecrValue(IncrDecrValue),
		.encEvent(EncEvent),
		.encLeft(),
		.count(RotCnt)
	);

	// User logic ends

	endmodule

