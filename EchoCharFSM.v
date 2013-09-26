`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:44:00 06/25/2013 
// Design Name: 
// Module Name:    EchoCharFSM 
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
module EchoCharFSM(
	input wire Clock,
	input wire Reset,
	input wire [7:0] Cmd,
	output wire EchoChar
    );

localparam ECHO_ON = 1'b0,
			  ECHO_OFF = 1'b1;
	
reg CurrentState = ECHO_ON;
reg NextState = ECHO_ON;

assign EchoChar = (CurrentState == ECHO_ON);

//--------------------------------------------
//Synchronous State Transition
//--------------------------------------------
always@(posedge Clock) begin
	if(Reset) CurrentState <= ECHO_ON;
	else CurrentState <= NextState;
end

//------------------------------------------
//Conditional State Transition
//------------------------------------------
always@(*) begin
	NextState = CurrentState;
	case (CurrentState)
		ECHO_ON: begin
			if (Cmd == 101) NextState = ECHO_OFF; //'e'
		end
		ECHO_OFF: begin
			if (Cmd == 69) NextState = ECHO_ON; //'E'
		end
	endcase
end


endmodule

