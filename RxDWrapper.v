`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:37:53 06/27/2013 
// Design Name: 
// Module Name:    RxDWrapper 
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
module RxDWrapper(
	input Clock,
	input ClearData,
	input SDI,
	output reg [7:0] CurrentData,
	output DataAvailable
   );
	
reg [7:0] NewData;
wire RxD_data_ready;
wire [7:0] RxD_data;

async_receiver rxd (
    .clk(Clock), 
    .RxD(SDI), 
    .RxD_data_ready(RxD_data_ready), 
    .RxD_data(RxD_data) 
    );


assign DataAvailable = (CurrentData > 8'b0);

//-------------------------------------------------
//Synchronous transition of data and reset
//-------------------------------------------------
always@(posedge Clock) begin
	if(ClearData) begin
		CurrentData <= 8'b0;
	end else
		CurrentData <= NewData;
end

//-------------------------------------------------
//New data stored if available
//-------------------------------------------------
always@(*) begin
	NewData = CurrentData;
	if(RxD_data_ready == 1) begin
		NewData[7:0] = RxD_data[7:0];
	end
end

endmodule
