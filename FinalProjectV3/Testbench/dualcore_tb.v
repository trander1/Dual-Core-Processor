`timescale 1ns / 1ps

`define HALT	1'b1
`define START	1'b0

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:19:34 04/28/2015
// Design Name:   dualcore
// Module Name:   S:/Xilinx/finalproject/dualcore_tb.v
// Project Name:  finalproject
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dualcore
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dualcore_tb;
parameter ALU_OPCODE_WIDTH = 4;
parameter ADDRESS_WIDTH = 4;
parameter DATA_WIDTH = 8;
parameter NUM_OF_INSTR = 10; 
parameter INSTRUCTION_WIDTH = ALU_OPCODE_WIDTH + ADDRESS_WIDTH + ADDRESS_WIDTH; 
	// Inputs
	reg clk;
	reg [INSTRUCTION_WIDTH-1:0] vector_in1;
	reg [INSTRUCTION_WIDTH-1:0] vector_in2;
	reg reset;

	// Outputs
	wire status1;
	wire status2;
	wire [DATA_WIDTH-1:0] alu_out1;
	wire [DATA_WIDTH-1:0] alu_out2;
	wire alu_carry_output1;									// carry from ALU P1
	wire alu_zero_flag_output1;								// zero flag ALU P1
	wire alu_carry_output2;									// carry from ALU P2
	wire alu_zero_flag_output2;								// zero flag ALU P2
	
	reg [ADDRESS_WIDTH-1:0]alu_opcodesP1[NUM_OF_INSTR-1:0];
	reg [ADDRESS_WIDTH-1:0]data1_addressP1[NUM_OF_INSTR-1:0];
	reg [ADDRESS_WIDTH-1:0]data2_addressP1[NUM_OF_INSTR-1:0];
	reg [ADDRESS_WIDTH-1:0]instruction_counter1;
	reg fetchingP1;
	
	reg [ADDRESS_WIDTH-1:0]alu_opcodesP2[NUM_OF_INSTR-1:0];
	reg [ADDRESS_WIDTH-1:0]data1_addressP2[NUM_OF_INSTR-1:0];
	reg [ADDRESS_WIDTH-1:0]data2_addressP2[NUM_OF_INSTR-1:0];
	reg [ADDRESS_WIDTH:0]instruction_counter2;
	reg fetchingP2;
	
	// Instantiate the Unit Under Test (UUT)
	dualcore D (
		.status_out1(status1), .status_out2(status2), .alu_out1(alu_out1), .alu_out2(alu_out2), .alu_carry_output1(alu_carry_output1), .alu_zero_flag_output1(alu_zero_flag_output1), .alu_carry_output2(alu_carry_output2), .alu_zero_flag_output2(alu_zero_flag_output2),		
		.vector_in1(vector_in1), .vector_in2(vector_in2), .fetchingP1(fetchingP1), .fetchingP2(fetchingP2), .reset(reset), .clk(clk)
	);

	initial begin
		// Initialize Inputs
		clk = 1;
		vector_in1 = 0;
		vector_in2 = 0;
		reset = 1;
		instruction_counter1 = 0;
		instruction_counter2 = 0;
		fetchingP1=1;
		fetchingP2=1;
		// Wait 100 ns for global reset to finish
//		#100;
        
		// Add stimulus here
		alu_opcodesP1[0] = 4'b0001;/*ADD*/		alu_opcodesP2[0] = 4'b1100;/*LE_TH*/	
		alu_opcodesP1[1] = 4'b0010;/*SUB*/		alu_opcodesP2[1] = 4'b0001;/*ADD*/	
		alu_opcodesP1[2] = 4'b0111;/*OR*/		alu_opcodesP2[2] = 4'b1001;/*ZE_TE*/	
		alu_opcodesP1[3] = 4'b1010;/*GR_TH*/	alu_opcodesP2[3] = 4'b0111;/*OR*/	
		alu_opcodesP1[4] = 4'b1011;/*EQUAL*/	alu_opcodesP2[4] = 4'b0110;/*AND*/	
		alu_opcodesP1[5] = 4'b0001;/*ADD*/		alu_opcodesP2[5] = 4'b0001;/*ADD*/
		alu_opcodesP1[6] = 4'b0110;/*AND*/		alu_opcodesP2[6] = 4'b1010;/*GR_TH*/	
		alu_opcodesP1[7] = 4'b0111;/*OR*/		alu_opcodesP2[7] = 4'b1100;/*LE_TH*/	
		alu_opcodesP1[8] = 4'b1001;/*ZE_TE*/	alu_opcodesP2[8] = 4'b0110;/*AND*/	
		alu_opcodesP1[9] = 4'b0010;/*SUB*/		alu_opcodesP2[9] = 4'b0010;/*SUB*/
		
		data1_addressP1[0] = 4'b0000;/*0000_0000_0*/  	data2_addressP1[0] = 4'b0101;/*0111_0001_113*/  
		data1_addressP1[1] = 4'b1101;/*1111_1111_255*/  data2_addressP1[1] = 4'b1011;/*0010_0001_33*/  
		data1_addressP1[2] = 4'b1000;/*0000_0100_4*/  	data2_addressP1[2] = 4'b1111;/*1001_1101_157*/  
		data1_addressP1[3] = 4'b0001;/*1001_1100_156*/  data2_addressP1[3] = 4'b0110;/*1111_1111_255*/  
		data1_addressP1[4] = 4'b0011;/*0000_1111_15*/  	data2_addressP1[4] = 4'b0001;/*1001_1100_156*/  
		data1_addressP1[5] = 4'b1001;/*1011_0010_178*/  data2_addressP1[5] = 4'b1010;/*0101_0101_85*/  
		data1_addressP1[6] = 4'b1100;/*1010_1010_170*/  data2_addressP1[6] = 4'b0100;/*0100_0100_68*/  
		data1_addressP1[7] = 4'b0111;/*0001_1110_30*/  	data2_addressP1[7] = 4'b1101;/*1111_1111_255*/  
		data1_addressP1[8] = 4'b0000;/*0000_0000_0*/  	data2_addressP1[8] = 4'b0000;/*0000_0000_0*/  
		data1_addressP1[9] = 4'b1101;/*1111_1111_255*/  data2_addressP1[9] = 4'b0110;/*1111_1111_255*/  
		
		data1_addressP2[0] = 4'b1110;/*1010_1010_170*/	data2_addressP2[0] = 4'b0101;/*0111_0001_113*/  
		data1_addressP2[1] = 4'b0101;/*0111_0001_113*/	data2_addressP2[1] = 4'b1001;/*1011_0010_178*/  
		data1_addressP2[2] = 4'b1001;/*1011_0010_178*/  data2_addressP2[2] = 4'b1111;/*1001_1101_157*/  
		data1_addressP2[3] = 4'b0000;/*0000_0000_0*/  	data2_addressP2[3] = 4'b1111;/*1001_1101_157*/  
		data1_addressP2[4] = 4'b1111;/*1001_1101_157*/  data2_addressP2[4] = 4'b0000;/*0000_0000_0*/  
		data1_addressP2[5] = 4'b1000;/*0000_0100_4*/  	data2_addressP2[5] = 4'b1011;/*0010_0001_33*/  
		data1_addressP2[6] = 4'b1110;/*1010_1010_170*/  data2_addressP2[6] = 4'b1111;/*1001_1101_157*/  
		data1_addressP2[7] = 4'b0010;/*1100_0000_192*/  data2_addressP2[7] = 4'b0011;/*0000_1111_15*/  
		data1_addressP2[8] = 4'b0011;/*0000_1111_15*/  	data2_addressP2[8] = 4'b0010;/*1100_0000_192*/  
		data1_addressP2[9] = 4'b0011;/*0000_1111_15*/  	data2_addressP2[9] = 4'b0011;/*0000_1111_15*/  
		#2 reset =0;
//		#30 $finish;
	end
	
	always@(posedge clk)
	begin:processor1
		if(status1 == `HALT)
		begin
//			$display("P1 HALTED");
//			vector_in1 = {4'b0000,4'b0000,4'b0000};
		end else
			begin
//				$display("P1 FETCHING");
				#2 vector_in1 = {alu_opcodesP1[instruction_counter1], data1_addressP1[instruction_counter1], data2_addressP1[instruction_counter1]};
				instruction_counter1 = instruction_counter1 + 4'b1;
				if(instruction_counter1 == NUM_OF_INSTR)
				begin
//					fetchingP1=0;		
//					disable processor1;
				end	
			end
	end
	
	always@(posedge clk)
	begin:processor2
		if(status2 == `HALT)
		begin
//			$display("P2 HALTED");
//			vector_in1 = {4'b0000,4'b0000,4'b0000};
		end else
			begin
//				$display("P2 FETCHING");
				#2 vector_in2 = {alu_opcodesP2[instruction_counter2], data1_addressP2[instruction_counter2], data2_addressP2[instruction_counter2]};
				instruction_counter2 = instruction_counter2 + 4'b1;
				if(instruction_counter2 == NUM_OF_INSTR)
				begin					
//					fetchingP2=0;
//					disable processor2;
				end
			end
	end
	
   always
		#1 clk = ~clk;

endmodule

