`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:15:37 04/08/2015
// Design Name:   inst_decoder
// Module Name:   S:/Xilinx/finalproject/inst_decoder_tb.v
// Project Name:  finalproject
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: inst_decoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module processor_tb;
parameter CONTROL_WIDTH = 4;			// width of the tag
parameter ADDR_WIDTH = 4;			// width of the data
parameter DATA_WIDTH = 8;			// width of the data
parameter LINE_WIDTH = CONTROL_WIDTH+ADDR_WIDTH+ADDR_WIDTH; // length of the input vector 

parameter HALT	= 1'b0;
parameter START = 1'b1;

parameter BUS_GRANTED = 1'b1;
parameter BUS_NOT_GRANTED = 1'b0;

// Inputs
reg [LINE_WIDTH-1:0]vector_in;
reg clk;
reg reset;
reg [DATA_WIDTH-1:0]data;
reg bus_grant;
// Outputs
wire bus_request;
wire status;
wire [ADDR_WIDTH-1:0]addr;
wire [DATA_WIDTH-1:0]alu_out;

	// Instantiate the Unit Under Test (UUT)
	processor #(CONTROL_WIDTH,ADDR_WIDTH) P1	(
		.alu_out(alu_out), 		
		.addr_out(addr), 		
		.bus_request_out(bus_request), 		
		.status_out(status), 
		.vector_in(vector_in), 
		.bus_grant_in(bus_grant),		
		.reset_in(reset),
		.data_in(data),
		.clk(clk)
	);

	initial begin
		// Initialize Inputs		
		clk = 1;
		reset = 1;
		vector_in = 0;
		bus_grant = 0;

		// Wait 100 ns for global reset to finish
//		#100;     
		// Add stimulus here
		#2 reset = 0; vector_in = 12'b0001_0000_0101;
		#2 vector_in = 12'b0010_1101_1011;
		#2 vector_in = 12'b0111_1000_1111;
		#4 bus_grant = BUS_GRANTED; 
		#2 data = 8'b01010101;
		#2 data = 8'b10101010; bus_grant = BUS_NOT_GRANTED;		
		#2 vector_in = 12'b1010_0001_0110;
//		#12 bus_grant = `BUS_GRANTED;
//		#14 bus_grant = `BUS_NOT_GRANTED;
		$monitor("alu_out:%d",alu_out); 
		#20 $finish;
	end
	
	always@(status) begin
		if(status == HALT)
		begin
			vector_in = 12'b0010_1101_1011;
		end
//		else begin
//			#2 reset = 0; vector_in = 12'b0001_0000_0101;
//			#2 vector_in = 12'b0010_1101_1011;
//			#2 vector_in = 12'b0111_1000_1111;
//			#4 bus_grant = BUS_GRANTED; 
//			#2 data = 8'b01010101;
//			#2 data = 8'b10101010; bus_grant = BUS_NOT_GRANTED;		
//			#2 vector_in = 12'b1010_0001_0110;
//		else	
	end	
		
   always begin
		#1 clk = ~clk; // Toggle clock every 1 ticks
	end   
endmodule

