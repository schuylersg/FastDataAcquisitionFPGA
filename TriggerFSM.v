`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:29:54 06/25/2013 
// Design Name: 
// Module Name:    TriggerFSM 
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
module TriggerFSM(
	input wire Clock,
	input wire Reset,
	input wire [7:0] Cmd,
	output wire TriggerArmed
    );

localparam TRIGGER_NOT_ARMED = 1'b0,
			  TRIGGER_ARMED = 1'b1;
	
reg CurrentState = TRIGGER_NOT_ARMED;
reg NextState = TRIGGER_NOT_ARMED;

//uncomment for real 
assign TriggerArmed = (CurrentState == TRIGGER_ARMED);

//assign TriggerArmed = 1'b1; //set just for simulation

//--------------------------------------------
//Synchronous State Transition
//--------------------------------------------
always@(posedge Clock) begin
	if(Reset) CurrentState <= TRIGGER_NOT_ARMED;
	else CurrentState <= NextState;
end

//------------------------------------------
//Conditional State Transition
//------------------------------------------
always@(*) begin
	NextState = CurrentState;
	case (CurrentState)
		TRIGGER_NOT_ARMED: begin
			if (Cmd == 65) NextState = TRIGGER_ARMED; //'A'
		end
		TRIGGER_ARMED: begin
			if (Cmd == 97) NextState = TRIGGER_NOT_ARMED; //'a'
		end
	endcase
end


endmodule
