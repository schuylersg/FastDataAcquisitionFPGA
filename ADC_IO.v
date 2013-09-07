`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:56:57 07/12/2013 
// Design Name: 
// Module Name:    ADC_IO 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ADC_IO(
    input [31:0] DataInP,
    input [31:0] DataInN,
	 input ClockIn,
	 input ClockInDelayed,
    output [31:0] DataOut
    );

wire [31:0] DataConnection;
wire ClockEnable = 1'b1;

//Create the data logic
//1. Connect the physical pins to the input buffer
//2. Wire input buffer to registers
//Depending on physical location, use ClockIn or ClockDelayed
genvar pin_count;
generate for (pin_count = 0; pin_count < 32; pin_count = pin_count + 1) begin: pins
    // Instantiate the buffers
    ////------------------------------
    // Instantiate a buffer for every bit of the data bus
    IBUFDS
      #(.DIFF_TERM  ("TRUE"),             // Differential termination
        .IOSTANDARD ("LVDS_25"))
     ibufds_inst
       (.I          (DataInP  [pin_count]),
        .IB         (DataInN  [pin_count]),
        .O          (DataConnection[pin_count]));

	//If I need to add a delay, this is where.
	
	if((pin_count  > 10 && pin_count < 16) || (pin_count > 25))
		// Pack the registers into the IOB
		(* IOB = "true" *)	
		FDRE FDRE_inst (
			.Q(DataOut[pin_count]),      		// 1-bit Data output
			.C(ClockIn),      					// 1-bit Clock input
			.CE(ClockEnable),    				// 1-bit Clock enable input
			.R(Reset),      						// 1-bit Synchronous reset input
			.D(DataConnection[pin_count])  	// 1-bit Data input
		);
	else
		(* IOB = "true" *)	
		FDRE FDRE_inst (
			.Q(DataOut[pin_count]),      	// 1-bit Data output
			.C(ClockInDelayed),      		// 1-bit Clock input
			.CE(ClockEnable),    			// 1-bit Clock enable input
			.R(Reset),      					// 1-bit Synchronous reset input
			.D(DataConnection[pin_count]) // 1-bit Data input
		);

  end
  endgenerate
endmodule
