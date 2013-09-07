`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:52:42 07/23/2013 
// Design Name: 
// Module Name:    DataAcqTB 
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
module DataAcqTB(
    );

reg USB_RS232_RXD, USER_RESET, USER_CLK, DATA_TRIGGER, ADC_CALIB, ADC_OVER_RANGE_P, ADC_OVER_RANGE_N, ADC_CLK_P, ADC_CLK_N;
reg [31:0] ADC_DATA_P, ADC_DATA_N;

DataAcqTop UUT (
    .USB_RS232_RXD(USB_RS232_RXD), 
    .USB_RS232_TXD(USB_RS232_TXD), 
	 
    .USER_RESET(USER_RESET), 
    .USER_CLK(USER_CLK), 
    
	 .DATA_TRIGGER(DATA_TRIGGER), 
    
	 .ADC_SCLK(ADC_SCLK), 
    .ADC_SDATA(ADC_SDATA), 
    .ADC_POWER_DOWN(ADC_POWER_DOWN), 
    .ADC_RUN_CALIB(ADC_RUN_CALIB), 
    .ADC_CALIB(ADC_CALIB), 
    .ADC_SCS(ADC_SCS), 
    .ADC_EXTENDED_CONTROL(ADC_EXTENDED_CONTROL), 
    
	 .ADC_OVER_RANGE_P(ADC_OVER_RANGE_P), 
    .ADC_OVER_RANGE_N(ADC_OVER_RANGE_N), 
    
	 .ADC_CLK_P(ADC_CLK_P), 
    .ADC_CLK_N(ADC_CLK_N), 
    
	 .ADC_DATA_P(ADC_DATA_P), 
    .ADC_DATA_N(ADC_DATA_N)
    );

initial begin
	USER_RESET = 0;
	USER_CLK = 0;
	ADC_CLK_P = 1;
	ADC_CLK_N = 0;
	USB_RS232_RXD = 1;
	ADC_OVER_RANGE_P = 0;
	ADC_OVER_RANGE_N = 1;
	
	ADC_DATA_P[7:0] = 8'd0;
	ADC_DATA_P[15:8] = 8'd64;
	ADC_DATA_P[23:16] = 8'd128;
	ADC_DATA_P[31:24] = 8'd192;
	
	DATA_TRIGGER = 0;
	
	#10 USER_RESET = 1;
	#50 USER_RESET = 0;
	
	#200 DATA_TRIGGER = 1;
	
/**
	#1000 USB_RS232_RXD = 0;
	#1085 USB_RS232_RXD = 1;
	#1085 USB_RS232_RXD = 0;
	#5425 USB_RS232_RXD = 1;
	#1085 USB_RS232_RXD = 0;
	#1085 USB_RS232_RXD = 1;
**/
end

always begin
	#2 ADC_CLK_P = ~ADC_CLK_P;
	ADC_CLK_N = ~ADC_CLK_N;
end

always begin
	#12.5 USER_CLK = ~USER_CLK;
end

always begin
	#4 ADC_DATA_P[7:0] = ADC_DATA_P [7:0] + 1;
		ADC_DATA_P[15:8] = ADC_DATA_P [15:8] + 1;
		ADC_DATA_P[23:16] = ADC_DATA_P [23:16] + 1;
		ADC_DATA_P[31:24] = ADC_DATA_P [31:24] + 1;
		ADC_DATA_N[31:0] = ~ADC_DATA_P [31:0];
end
endmodule
