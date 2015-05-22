`timescale 1ns / 1ps

`define READ		2'b01

`define LOG2(width) 	(width<=2)?1:\
							(width<=4)?2:\
							(width<=8)?3:\
							(width<=16)?4:\
							(width<=32)?5:\
							(width<=64)?6:\
							(width<=128)?7:\
							(width<=256)?8:\
							-1

module dualcore(
		status_out1, status_out2, alu_out1, alu_out2, alu_carry_output1, alu_zero_flag_output1, alu_carry_output2, alu_zero_flag_output2,
		vector_in1, vector_in2, fetchingP1, fetchingP2, reset, clk
		);

parameter TAG_WIDTH = 4;			// width of the tag
parameter DATA_WIDTH = 8;			// width of the data
parameter ENTRIES_WIDTH = 16;		// # of entries
parameter OPCODE_WIDTH = 2;		// width of opcode
parameter INSTRUCTION_WIDTH = TAG_WIDTH+TAG_WIDTH+TAG_WIDTH; // length of the input vector 
parameter ENTRIES_BIT_WIDTH = `LOG2(ENTRIES_WIDTH); // length of the input vector 
/// outputs
output status_out1;					// current status of processor1
output status_out2;					// current status of processor2
output [DATA_WIDTH-1:0] alu_out1;	// alu ouput from processor1
output [DATA_WIDTH-1:0] alu_out2;	// alu ouput from processor2
output alu_carry_output1;									// carry from ALU P1
output alu_zero_flag_output1;								// zero flag ALU P1
output alu_carry_output2;									// carry from ALU P2
output alu_zero_flag_output2;								// zero flag ALU P2
// inputs 
input clk;							// test bench clk
input [INSTRUCTION_WIDTH-1:0]vector_in1;	// test bench vector_in for processor1
input [INSTRUCTION_WIDTH-1:0]vector_in2;	// test bench vector_in for processor1
input reset;						// test bench reset for the whole system 
input fetchingP1;			// request coming in from processor2
input fetchingP2;			// request coming in from processor2

// connections
wire [DATA_WIDTH-1:0]data_out;		// data coming from the L2
wire grant_in1_from_arbiter;		// grant given to the processor1 via arbiter
wire grant_in2_from_arbiter;		// grant given to the processor2 via arbiter
wire request_out_from_p1;			// request coming in from processor1
wire request_out_from_p2;			// request coming in from processor2
wire [TAG_WIDTH-1:0]addr_out_from_p1;	// address for search in L2 from processor1
wire [TAG_WIDTH-1:0]addr_out_from_p2;	// address for search in L2 from processor2

// L2 cache connections
wire enable_forL2;							// enabling the L2
wire enable_forArbiter;							// enabling the L2
wire [TAG_WIDTH-1:0]addr_in_for_L2;		// address request for the L2
wire [DATA_WIDTH-1:0]data_in1_from_L2;	// separated data for processor1 
wire [DATA_WIDTH-1:0]data_in2_from_L2;	// separated data for processor2

// used to enable and disable the cache
assign enable_forL2 = (grant_in1_from_arbiter ^ grant_in2_from_arbiter);
// used to enable and disable the arbiter
assign enable_forArbiter = ~(request_out_from_p1 & request_out_from_p2);

// tri-state buffer for the address in the L2
assign addr_in_for_L2 = grant_in1_from_arbiter ? addr_out_from_p1 : {TAG_WIDTH{1'bz}};	
assign addr_in_for_L2 = grant_in2_from_arbiter ? addr_out_from_p2 : {TAG_WIDTH{1'bz}};

// tri-state buffer for the data out from the L2
assign data_in1_from_L2 = grant_in1_from_arbiter ? data_out : {DATA_WIDTH{1'bz}};	
assign data_in2_from_L2 = grant_in2_from_arbiter ? data_out : {DATA_WIDTH{1'bz}};

// component instantiations

processor processor1(
	.alu_out(alu_out1), .alu_carry_output(alu_carry_output1), .alu_zero_flag_output(alu_zero_flag_output1), .addr_out(addr_out_from_p1), .bus_request_out(request_out_from_p1), .status_out(status_out1),
	.vector_in(vector_in1), .bus_grant_in(grant_in1_from_arbiter), .reset_in(reset), .fetching(fetchingP1) ,.data_in(data_in1_from_L2), .clk(clk)
);
		
processor processor2(
 .alu_out(alu_out2), .alu_carry_output(alu_carry_output2), .alu_zero_flag_output(alu_zero_flag_output2), .addr_out(addr_out_from_p2), .bus_request_out(request_out_from_p2), .status_out(status_out2),
 .vector_in(vector_in2), .bus_grant_in(grant_in2_from_arbiter), .reset_in(reset), .fetching(fetchingP2), .data_in(data_in2_from_L2), .clk(clk)
);

cacheL2 #(TAG_WIDTH,DATA_WIDTH,ENTRIES_WIDTH) L2	(
	.data_out(data_out), .hit_miss_out(hit_miss_out), .vector_in({`READ,addr_in_for_L2,8'b0}), 	
	.enable(enable_forL2), .reset(reset), .clk(clk)
);
	
arbiter arbiter(		
	.request_p1(request_out_from_p1), .request_p2(request_out_from_p2),
	.grant1(grant_in1_from_arbiter), .grant2(grant_in2_from_arbiter), .enable(enable_forArbiter), .reset(reset), .clk(clk)
);
endmodule
