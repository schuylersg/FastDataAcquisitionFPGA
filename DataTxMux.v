`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Schuyler Senft-Grupp
// 
// Create Date:    16:33:46 07/22/2013 
// Design Name: 
// Module Name:    DataTxMux 
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
module DataTxMux(
	 output UARTRequestToSend,
    output ReadyToRead,
    output [7:0] DataOut,
	 input Clk,
	 input Reset,
    input [31:0] FIFOData,
	 input FIFODataValid,
	 input UARTDataLoaded
    );

localparam IDLE 	= 1'b0,
			  TRANSMIT 	= 1'b1;
			  
			  	  
reg CurrentState, NextState;
reg [31:0] DataReg, DataNext;
reg [1:0] DataCounter, DCNext;

//--------------------------------------------
//Output logic
//--------------------------------------------
assign UARTRequestToSend = (CurrentState == TRANSMIT);
assign ReadyToRead = (CurrentState == IDLE);

assign DataOut[7:0] =  FIFOData [31:24];

//--------------------------------------------
//Synchronous State Transition
//--------------------------------------------
always@(posedge Clk) begin
	if(Reset) 
		begin
			CurrentState <= IDLE;
			DataReg <= 0;
			DataCounter <= 0;
		end
	else 
		begin
			CurrentState <= NextState;
			DataReg <= DataNext;
			DataCounter <= DCNext;
		end
end


//------------------------------------------
//Conditional State Transition
//------------------------------------------
always@(*) begin
	NextState = CurrentState;
	DataNext = DataReg;
	DCNext = DataCounter;
	case (CurrentState)
		IDLE:
			begin
				if(FIFODataValid)
					begin
						DataNext = FIFOData;
						NextState = TRANSMIT;
						DCNext = 1'b0;
					end
			end
		TRANSMIT:
			begin
				if(UARTDataLoaded)
					begin
						DataNext = DataReg << 8;
						if(DataCounter == 3)
							NextState = IDLE;
						else
							DCNext = DCNext + 1;
					end
			end
	endcase
end
endmodule
