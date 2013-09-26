`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:21:34 06/26/2013 
// Design Name: 
// Module Name:    TxDWrapper 
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
module TxDWrapper(
	input Clock,
	input Reset,
	input [15:0] Data,
	input [1:0] RequestToSend,
	output [1:0] DataReceivedOut,
	output SDO
    );

localparam 	STATE_Idle = 				2'b00,
				STATE_Wait = 2'b01,
				STATE_TxDStart = 2'b010;

reg [1:0] CurrentState = STATE_Idle;
reg [1:0] NextState = STATE_Idle;
reg [7:0] TxDBuffer = 8'b0;
reg [7:0] NewTxDValue = 8'b0;
reg [1:0] DataReceived = 2'b0;
reg [1:0] DRNext = 2'b0;

assign DataReceivedOut = DataReceived;

//--------------------------------------------
//Synchronous State Transition
//--------------------------------------------
always@(posedge Clock) begin
	if(Reset) begin
		CurrentState <= STATE_Idle;
		TxDBuffer <= 8'b0;
		DataReceived <= 2'b0;
		end 
	else begin
		CurrentState <= NextState;
		TxDBuffer <= NewTxDValue;
		DataReceived <= DRNext;
	end
end

//------------------------------------------
//Conditional State Transition
//------------------------------------------
always@(*) begin
	NextState = CurrentState;
	NewTxDValue = TxDBuffer;
	DRNext = DataReceived;
	case (CurrentState)
		STATE_Idle: begin
			if(RequestToSend[1]) 
				begin
					NewTxDValue = Data[15:8];
					NextState = TxDBusy ? STATE_Wait : STATE_TxDStart;
					DRNext = 2'b10;
				end
			else if (RequestToSend[0]) 
				begin
					NewTxDValue = Data[7:0];
					NextState = TxDBusy ? STATE_Wait : STATE_TxDStart;
					DRNext = 2'b01;
				end
		end
		STATE_Wait: begin
			DRNext = 2'b00;
			if(!TxDBusy) NextState = STATE_TxDStart;
		end
		STATE_TxDStart: begin
			DRNext = 2'b00;
			NextState = STATE_Idle;
		end
	endcase
end

assign TxDStart = (CurrentState == STATE_TxDStart);

async_transmitter txd (
    .clk(Clock), 
    .TxD_start(TxDStart), 
    .TxD_data(TxDBuffer), 
    .TxD(SDO), 
    .TxD_busy(TxDBusy)
    );


endmodule
