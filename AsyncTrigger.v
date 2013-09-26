`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:17:15 06/26/2013 
// Design Name: 
// Module Name:    AsyncTrigger 
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
module AsyncTrigger(
	input wire Armed,
	input wire Trigger,
	input wire Clock,
	input wire Reset,
	output EnableRecordingOut
    );

reg EnableRecording = 1'b0;
reg NextState = 1'b0;

assign EnableRecordingOut = EnableRecording;

always@(posedge Clock)begin
	if(Reset) EnableRecording <= 1'b0;
	else EnableRecording <= NextState;
end

//------------------------------------------
//Conditional State Transition
//------------------------------------------
always@(*) begin
	NextState = EnableRecording;
	case (EnableRecording)
		1'b0: begin
			if (Armed & Trigger) NextState = 1'b1; 
		end
		1'b1: begin
			NextState = 1'b1; //'a'
		end
	endcase
end

endmodule
