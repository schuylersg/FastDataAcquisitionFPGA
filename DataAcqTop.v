`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MIT Hemond Lab
// Engineer: Schuyler Senft-Grupp
// 
// Create Date:    15:10:54 07/12/2013 
// Design Name: 
// Module Name:    DataAcqTop 
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
module DataAcqTop(
	input 	USB_RS232_RXD,	 			//to FTDI chip
	output 	USB_RS232_TXD, 			//to FTDI chip
	output 	FPGA_SCL,					//two-way serial clock
	inout 	FPGA_SDL,					//two-way serial data line
	input 	USER_CLK,		 			//clock input at 100MHz
	input 	DATA_TRIGGER_N, 			//Differential data trigger input
	input 	DATA_TRIGGER_P,
	
	//PINS CONNECTED TO ADC
	output 	ADC_SCLK,					//serial comm with ADC
	output 	ADC_SDATA,					//serial data to ADC
	output 	ADC_SCS,						//serial chip select
	output 	ADC_PD,						//active high - powers down ADC
	output 	ADC_PDQ,						//active high - powers down Q half of ADC
	output 	ADC_CAL,						//pull low then high to start calibration
	input 	ADC_CALRUN,					//high during calibration

	//ADC Data and Clock Pins
	input 	ADC_CLK_P,
	input 	ADC_CLK_N,
	input 	[31:0] ADC_DATA_P,
	input 	[31:0] ADC_DATA_N	
    );

//--------------------------------------------------------------------------
//Clock Management and Reset Logic
//--------------------------------------------------------------------------
wire Clk100Mhz, ClkADC2DCM, ClkADCData0p, ClkADCData30p;
wire InputTrigger;
assign Clk100Mhz = USER_CLK;


// Create the ADC input clock buffer and send the signal to the DCM
IBUFGDS #(
      .DIFF_TERM("TRUE"), 		// Differential Termination
      .IOSTANDARD("LVDS_33") 	// Specifies the I/O standard for this buffer
   ) IBUFGDS_adcClock (
      .O(ClkADC2DCM),  			// Clock buffer output
      .I(ADC_CLK_P),  			// Diff_p clock buffer input
      .IB(ADC_CLK_N) 			// Diff_n clock buffer input
   );
	
	// Create the ADC input clock buffer and send the signal to the DCM
IBUFDS #(
      .DIFF_TERM("TRUE"), 		// Differential Termination
      .IOSTANDARD("LVDS_33") 	// Specifies the I/O standard for this buffer
   ) IBUFDS_trigger (
      .O(InputTrigger),  				// Clock buffer output
      .I(DATA_TRIGGER_P),  			// Diff_p clock buffer input
      .IB(DATA_TRIGGER_N) 				// Diff_n clock buffer input
   );

// Use the DCM to buffer the clock and create phase shifted versions to account for PCB delay
DCM1 adc_dclk_dcm
   (// Clock in ports
    .CLK_IN1(ClkADC2DCM),      		// IN
    // Clock out ports
    .CLK_OUT0P(ClkADCData0p),     	// OUT
    .CLK_OUT_30P(ClkADCData30p),    // OUT
    // Status and control signals
    .RESET(1'b0),					// IN
    .LOCKED(DCM1Locked));

//------------------------------------------------------------------------------
// UART and device settings/state machines 
//------------------------------------------------------------------------------
wire [7:0] DataRxD;
wire [7:0] FIFODataOut;
wire [7:0] OtherDataOut;
wire DataAvailable, ClearData;
wire FIFORequestToSend, OtherRequestToSend, FIFODataReceived, OtherDataReceived;
wire ArmTrigger, TriggerReset, EchoChar;

RxDWrapper RxD (
    .Clock(Clk100Mhz), 
    .ClearData(ClearData), 
    .SDI(USB_RS232_RXD), 
    .CurrentData(DataRxD), 
    .DataAvailable(DataAvailable)
    );

assign ClearData = DataAvailable; //Temporary - automatically erases available data

TxDWrapper TxD (
    .Clock(Clk100Mhz), 
    .Reset(1'b0), 
    .Data({FIFODataOut, OtherDataOut}), 
    .RequestToSend({FIFORequestToSend, OtherRequestToSend}),
	 .DataReceivedOut({FIFODataReceived, OtherDataReceived}), 
    .SDO(USB_RS232_TXD)
    );

TriggerFSM TriggerSetting (
    .Clock(Clk100Mhz), 
    .Reset(TriggerReset), 
    .Cmd(DataRxD), 
    .TriggerArmed(ArmTrigger)
    );

EchoCharFSM EchoSetting (
    .Clock(Clk100Mhz), 
    .Reset(1'b0), 
    .Cmd(DataRxD), 
    .EchoChar(EchoChar)
    );

//------------------------------------------------------------------------------
//ADC Data Connection
//------------------------------------------------------------------------------
wire [31:0] FIFODataIn;

ADC_IO ADCConnection (
    .DataInP(ADC_DATA_P), 
    .DataInN(ADC_DATA_N),
	 .ClockIn(ClkADCData0p),
	 .ClockInDelayed(ClkADCData30p),	 
    .DataOut(FIFODataIn)
    );
	 
//------------------------------------------------------------------------------
//ADC Control
//------------------------------------------------------------------------------
	
	assign ADC_SCLK = 1'b0;
	assign ADC_SDATA = 1'b0;
	assign ADC_PD = 1'b0;
	assign ADC_CAL = 1'b0;
	assign ADC_SCS = 1'b0;
	
	reg CalStatus = 1'b0;
	
	always@(posedge ClkADCData0p)
		CalStatus <= ADC_CALRUN;
	

//------------------------------------------------------------------------------
//FIFO and FIFO Start Trigger
//------------------------------------------------------------------------------
wire EnableRun, Trigger;
/*AsyncTrigger DataTrigger (
	 .Clock(ClkADCData0p),
    .Armed(ArmTrigger && CalStatus), 
    .Trigger(InputTrigger), 
    .Reset(TriggerReset), 
    .EnableRecordingOut(EnableRecording)
    );
*/

assign EnableRecording = 1'b1;

wire FIFOFull0, FIFOFull1, FIFOFull2;
wire FIFOEmpty0, FIFOEmpty1, FIFOEmpty2;
wire OutputValid0, OutputValid1, OutputValid2, AllDataValid;
wire MuxReadyToRead;

wire [10:0] FIFODataOut0, FIFODataOut1;
wire [9:0] FIFODataOut2;

assign AllDataValid = (OutputValid2 & OutputValid1 & OutputValid0);
assign FifoRdEn = MuxReadyToRead & (~FIFOEmpty0 & ~FIFOEmpty1 & ~FIFOEmpty2);


FIFO_11_bit fifo_0 (
  .rst(1'b0), // input rst
  .wr_clk(ClkADCData30p), // input wr_clk
  .rd_clk(Clk100Mhz), // input rd_clk
  .din(FIFODataIn[10:0]), // input [10 : 0] din
  .wr_en(EnableRecording), // input wr_en
  .rd_en(FifoRdEn), // input rd_en
  .dout(FIFODataOut0), // output [7 : 0] dout
  .full(FIFOFull0), // output full
  .empty(FIFOEmpty0), // output empty
  .valid(OutputValid0) // output valid
);

FIFO_11_bit fifo_1 (
  .rst(1'b0), // input rst
  .wr_clk(ClkADCData0p), // input wr_clk
  .rd_clk(Clk100Mhz), // input rd_clk
  .din({FIFODataIn[31:26], FIFODataIn[15:11]}), // input [10 : 0] din
  .wr_en(EnableRecording), // input wr_en
  .rd_en(FifoRdEn), // input rd_en
  .dout(FIFODataOut1), // output [7 : 0] dout
  .full(FIFOFull1), // output full
  .empty(FIFOEmpty1), // output empty
  .valid(OutputValid1) // output valid
);


FIFO_10_bit fifo_2 (
  .rst(1'b0), // input rst
  .wr_clk(ClkADCData30p), // input wr_clk
  .rd_clk(Clk100Mhz), // input rd_clk
  .din(FIFODataIn[25:16]), // input [9 : 0] din
  .wr_en(EnableRecording), // input wr_en
  .rd_en(FifoRdEn), // input rd_en
  .dout(FIFODataOut2), // output [9 : 0] dout
  .full(FIFOFull2), // output full
  .empty(FIFOEmpty2), // output empty
  .valid(OutputValid2) // output valid
);

DataTxMux DataMux (
    .UARTRequestToSend(FIFORequestToSend), 
    .ReadyToRead(MuxReadyToRead), 
    .DataOut(FIFODataOut), 			//Data out to UART Tx
    .Clk(Clk100Mhz), 					//fpga clock
    .Reset(1'b0), 
    .FIFOData({FIFODataOut1[10:5], FIFODataOut2[9:0], FIFODataOut1[4:0], FIFODataOut0[10:0]}), 
    .FIFODataValid(AllDataValid), 		
    .UARTDataLoaded(FIFODataReceived)
    );


//Reset the trigger on 1) a User reset or 2) if the FIFO is full 
wire FIFOFull = FIFOFull2 | FIFOFull1 | FIFOFull0;
assign TriggerReset = FIFOFull;

endmodule
