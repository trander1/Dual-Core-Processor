`timescale 1ns / 1ps

`define FLASH		2'b00
`define READ		2'b01
`define WRITE		2'b10
`define INVALID	2'b11

`define NOP				4'b0000

`define MISS	1'b0
`define HIT		1'b1

`define CACHE_ENABLE		1'b0
`define CACHE_DISABLE	1'b1

`define HALT		1'b1
`define START		1'b0

`define BUS_REQUESTED		1'b1
`define BUS_NOT_REQUESTED	1'b0

`define BUS_GRANTED		1'b1
`define BUS_NOT_GRANTED	1'b0

`define FIFO_FULL 		1'b1
`define FIFO_NOT_FULL 	1'b0

`define FIFO_EMPTY 		1'b1
`define FIFO_NOT_EMPTY 	1'b0

`define LOG2(width) 	(width<=2)?1:\
							(width<=4)?2:\
							(width<=8)?3:\
							(width<=16)?4:\
							(width<=32)?5:\
							(width<=64)?6:\
							(width<=128)?7:\
							(width<=256)?8:\
							-1

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:54:07 04/08/2015 
// Design Name: 
// Module Name:    inst_decoder 
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
module processor( 
		alu_out, alu_carry_output, alu_zero_flag_output, addr_out, bus_request_out, status_out,
		vector_in, bus_grant_in, reset_in, fetching, data_in, clk
    );
// parameters for the module	
parameter CONTROL_WIDTH = 4;		// width of the alu control
parameter ADDR_WIDTH = 4;			// width of tag/adress for cache access
parameter DATA_WIDTH	= 8;			// width of data coming from cache
parameter ENTRIES_WIDTH	= 4;		// # of entries in cache
parameter OPCODE_WIDTH	= 2;		// width of the opcode
parameter BUFFER_SPACE	= 2;		// index of the instruction
parameter FIFO_ENTRIES = 2;
parameter EXTRA_BIT_FOR_FIFO = 1;
parameter INSTR_LINE_WIDTH = CONTROL_WIDTH+ADDR_WIDTH+ADDR_WIDTH; // length of the input vector DECODER
parameter CACHE_LINE_WIDTH = OPCODE_WIDTH+ADDR_WIDTH+DATA_WIDTH; // length of the input vector CACHE
parameter ALU_VECTOR_WIDTH = CONTROL_WIDTH+DATA_WIDTH+DATA_WIDTH; // length of the input vector ALU
parameter FIFO_VECTOR_WIDTH = OPCODE_WIDTH+ADDR_WIDTH+EXTRA_BIT_FOR_FIFO; // length of the input vector FIFO

parameter WAIT_FOR_ONE_CYCLE = 0;
parameter ADDRESS_FOR_REQUEST = 1;
parameter L2_FIRST_ACCESS = 2;
parameter L2_FINAL_ACCESS = 3;
parameter CACHE_SWAP_WAIT = 4;
parameter BUS_REQUEST_WAIT = 5;
parameter WAIT_FOR_SECOND_CYCLE = 6;

// outputs of the module
output [DATA_WIDTH-1:0]alu_out;		// address out for the L2 access
output alu_carry_output;									// carry from ALU
output alu_zero_flag_output;								// zero flag ALU
output reg [ADDR_WIDTH-1:0]addr_out;	// address out for the L2 access
output reg bus_request_out;				// bus request signal
output status_out;						// status for the testbench feedback
// inputs of the module
input [INSTR_LINE_WIDTH-1:0]vector_in;		// input vector
input bus_grant_in;								// bus grant signal
input reset_in;									// input reset 
input fetching;									// input reset 
input [DATA_WIDTH-1:0]data_in;				// data coming in from L2 cache
input clk;											// input clk 
// local module variables
//reg [BUFFER_SPACE-1:0]buffer_index;								// tag bits for the module obtained from the input vector
//reg [CONTROL_WIDTH-1:0]control_in[BUFFER_SPACE-1:0];	// tag bits for the module obtained from the input vector
//reg [ADDR_WIDTH-1:0]data_addr1[BUFFER_SPACE-1:0];		// 1st data address to be fetched from cache
//reg [ADDR_WIDTH-1:0]data_addr2[BUFFER_SPACE-1:0];		// 2nd data address to be fetched from cache
// local module variables
reg [BUFFER_SPACE-1:0]buffer_index;								// tag bits for the module obtained from the input vector
reg [CONTROL_WIDTH-1:0]control_in;	// tag bits for the module obtained from the input vector
reg [ADDR_WIDTH-1:0]data_addr1;		// 1st data address to be fetched from cache
reg [ADDR_WIDTH-1:0]data_addr2;		// 2nd data address to be fetched from cache
// ALU variables
reg [ALU_VECTOR_WIDTH-1:0]ALU_vector_in;			// ALU input vector
reg [DATA_WIDTH-1:0]data_alu1[BUFFER_SPACE-1:0];// 1st data fetched from cache to ALU
reg [DATA_WIDTH-1:0]data_alu2[BUFFER_SPACE-1:0];// 2nd data fetched from cache to ALU
// control enable for the cache 
reg L1_enable;								// L1 enable
// variables for the cache module
wire [DATA_WIDTH-1:0]data_out;	// final output of the block
wire hit_miss_out;					// outputs the hit/miss of the block
// temporary variables used somewhere
reg [CACHE_LINE_WIDTH-1:0]L1_vector_in;	// L1 input vector used in the state machine
reg [DATA_WIDTH-1:0]temp_data_in;			// temp data vector for L1 cache
// state machine variables
reg [3:0]state;			// current state of the SM
reg [3:0]next_state;		// next state for the SM
// fifo variables
wire [ADDR_WIDTH-1:0]instr_fifo_data_out;
wire instr_fifo_empty_flag;
wire instr_fifo_full_flag;
reg [FIFO_VECTOR_WIDTH-1:0]instr_fifo_vector_in;

wire [ADDR_WIDTH-1:0]addr1_fifo_data_out;
wire addr1_fifo_empty_flag;
wire addr1_fifo_full_flag;
reg [FIFO_VECTOR_WIDTH-1:0]addr1_fifo_vector_in;

wire [ADDR_WIDTH-1:0]addr2_fifo_data_out;
wire addr2_fifo_empty_flag;
wire addr2_fifo_full_flag;
reg [FIFO_VECTOR_WIDTH-1:0]addr2_fifo_vector_in;

reg [ADDR_WIDTH-1:0]instr_fifo_flag;
reg [ADDR_WIDTH-1:0]addr2_fifo_flag;
reg [ADDR_WIDTH-1:0]addr1_fifo_flag;
reg extra_bit_flag;

cache #(ADDR_WIDTH,DATA_WIDTH,ENTRIES_WIDTH) L1	(
	.data_out(data_out), .hit_miss_out(hit_miss_out), .vector_in(L1_vector_in), 	
	.enable(L1_enable), .reset(reset_in), .clk(clk)
);

alu #(CONTROL_WIDTH,DATA_WIDTH) alu (
	.final_output(alu_out),	.carry_output(alu_carry_output),	.zero_flag(alu_zero_flag_output), 
	.opcode_inputs(ALU_vector_in), .reset_in(reset_in), .clk(clk)	 
);

fifo #(ADDR_WIDTH, FIFO_ENTRIES) instr_fifo (
	.data_out(instr_fifo_data_out), .empty_flag(instr_fifo_empty_flag), .full_flag(status_out), 
	.vector_in(instr_fifo_vector_in), .reset(reset_in), .clk(clk)
);

fifo #(ADDR_WIDTH, FIFO_ENTRIES) addr1_fifo (
	.data_out(addr1_fifo_data_out), .empty_flag(addr1_fifo_empty_flag), .full_flag(addr1_fifo_full_flag), 
	.vector_in(addr1_fifo_vector_in), .reset(reset_in), .clk(clk)
);

fifo #(ADDR_WIDTH, FIFO_ENTRIES) addr2_fifo (
	.data_out(addr2_fifo_data_out), .empty_flag(addr2_fifo_empty_flag), .full_flag(addr2_fifo_full_flag), 
	.vector_in(addr2_fifo_vector_in), .reset(reset_in), .clk(clk)
);

always @(posedge clk)
begin
	if (reset_in)		
	begin
		state = WAIT_FOR_ONE_CYCLE;
		L1_vector_in = {`INVALID,4'b0,8'b0};
		L1_enable = `CACHE_DISABLE;
		temp_data_in = {DATA_WIDTH{1'b0}};
//		alu_out = {DATA_WIDTH-1{1'b0}};
		buffer_index = {BUFFER_SPACE{1'b0}};
		bus_request_out = `BUS_NOT_REQUESTED;
//		status_out = `START;		
		ALU_vector_in = {`NOP,data_alu1[0],data_alu2[0]};
		instr_fifo_flag = 4'b0;
		addr1_fifo_flag = 4'b0;
		addr2_fifo_flag = 4'b0;	
		extra_bit_flag = 1'b0;
		control_in = 4'b0;
		data_addr1 = 4'b0;
		data_addr2 = 4'b0;
	end else 
	begin	
		if(fetching) begin
			if(instr_fifo_empty_flag == `FIFO_EMPTY && status_out != `HALT)
	//		if(status_out == `START)
			begin
				control_in = vector_in[INSTR_LINE_WIDTH-1:INSTR_LINE_WIDTH-CONTROL_WIDTH];
				instr_fifo_vector_in = {`WRITE,control_in,extra_bit_flag};
//				$display("control_in:%d ",control_in);
			end
	//		else
	//			status_out = `HALT;
			
			if(addr1_fifo_empty_flag == `FIFO_EMPTY && addr2_fifo_empty_flag == `FIFO_EMPTY && status_out != `HALT)
	//		if(status_out == `START)
			begin
				data_addr1 = vector_in[INSTR_LINE_WIDTH-CONTROL_WIDTH-1:INSTR_LINE_WIDTH-CONTROL_WIDTH-ADDR_WIDTH];
				addr1_fifo_vector_in = {`WRITE,data_addr1,extra_bit_flag};			
				data_addr2 = vector_in[INSTR_LINE_WIDTH-CONTROL_WIDTH-ADDR_WIDTH-1:INSTR_LINE_WIDTH-CONTROL_WIDTH-ADDR_WIDTH-ADDR_WIDTH];
				addr2_fifo_vector_in = {`WRITE,data_addr2,extra_bit_flag};
//				$display("data_addr1:%d, data_addr2:%d ",data_addr1,data_addr2);
	//			@(posedge clk);
	//			status_out = `HALT;
	//			addr1_fifo_vector_in = {2'b00,data_addr2};
	//			addr2_fifo_vector_in = {2'b00,data_addr2};
			end		
		end
//		else
//			status_out = `HALT;			
/*			
		control_in[buffer_index] = vector_in[INSTR_LINE_WIDTH-1:INSTR_LINE_WIDTH-CONTROL_WIDTH];
		if(buffer_index < BUFFER_SPACE - 2)
		begin
			data_addr1[buffer_index] = vector_in[INSTR_LINE_WIDTH-CONTROL_WIDTH-1:INSTR_LINE_WIDTH-CONTROL_WIDTH-ADDR_WIDTH];
			data_addr2[buffer_index] = vector_in[INSTR_LINE_WIDTH-CONTROL_WIDTH-ADDR_WIDTH-1:INSTR_LINE_WIDTH-CONTROL_WIDTH-ADDR_WIDTH-ADDR_WIDTH];				
		end 
		$display("buffer_index:%d, control: %d,data_addr1: %d,data_addr2: %d",buffer_index, control_in[buffer_index], data_addr1[buffer_index], data_addr2[buffer_index]);	
		buffer_index = buffer_index + 1;
*/			
			case(state)
/*			
			L1_CACHE_ACCESS:
				begin
					$display("L1_CACHE_ACCESS");					
					L1_enable = `CACHE_ENABLE;	
					L1_vector_in = {`READ,data_addr1[0],temp_data_in};
					status_out = `HALT;
					next_state = L1_ACCESS_CHECK;
				end
			L1_ACCESS_CHECK:
				begin
				@(posedge clk);
					$display("data_out:%d, hit_miss_out:%d",data_out,hit_miss_out);
					if(hit_miss_out == `MISS)
					begin					
						L1_enable = `CACHE_DISABLE;
						status_out = `HALT;
						bus_request_out = `BUS_REQUESTED;
						next_state = BUS_REQUEST_WAIT;
					end	
				end
*/			
			WAIT_FOR_ONE_CYCLE:
				begin
					next_state = WAIT_FOR_SECOND_CYCLE;
				end
			WAIT_FOR_SECOND_CYCLE:
				begin
					next_state = ADDRESS_FOR_REQUEST;
				end			
			ADDRESS_FOR_REQUEST:
				begin					
//					$display("GETTING THE ADDRESS");
					// bus being requested
					bus_request_out = `BUS_REQUESTED;
					// address for the L2 request being read out from the fifo
					addr1_fifo_vector_in = {`READ,addr1_fifo_flag,extra_bit_flag};
					addr1_fifo_flag = addr1_fifo_flag + 4'b1;
					// feedback for the testbench
//					status_out = `HALT;
					next_state = BUS_REQUEST_WAIT;
				end
			BUS_REQUEST_WAIT:
				begin					
//					$display("WAITING FOR BUS");											
					if(bus_grant_in == `BUS_GRANTED)
					begin
						// address for the L2 request from arrived from the fifo
						addr_out = addr1_fifo_data_out;
//						$display("addr_out:%d", addr_out);
						// address for the L2 request being read out from the fifo
						addr2_fifo_vector_in = {`READ,addr2_fifo_flag,extra_bit_flag};
						addr2_fifo_flag = addr2_fifo_flag + 4'b1;
						// instruction being read out from the fifo for the alu operation
						instr_fifo_vector_in	= {`READ,instr_fifo_flag,extra_bit_flag};
						instr_fifo_flag = instr_fifo_flag + 4'b1;
						next_state = L2_FIRST_ACCESS;
//						$display("BUS GRANTED");
					end	
				end					
			L2_FIRST_ACCESS:
				begin
//					$display("L2_FIRST_ACCESS");
					// data should have arrived in the clock cycle
					data_alu1[0] = data_in;
					// send the second access address
					addr_out = addr2_fifo_data_out;					
					next_state = L2_FINAL_ACCESS;
//					$display("data_alu1[0]:%d, addr_out:%d", data_alu1[0],addr_out);
				end
			L2_FINAL_ACCESS:
				begin
//					$display("L2_FINAL_ACCESS");
					// get the second data
					data_alu1[1] = data_in;
					// also start new decoding
//					status_out = `START;					
					// start the alu process
					ALU_vector_in = {instr_fifo_data_out,data_alu1[0],data_alu1[1]};
					// start the buffer_index from 0
					// buffer_index = {BUFFER_SPACE-1{1'b0}};
					// bus request removed
					bus_request_out = `BUS_NOT_REQUESTED;
					// go back to the start for the l1 cache access
					next_state = WAIT_FOR_ONE_CYCLE;
//					$display("data_alu1[1]:%d, control_in:%d", data_alu1[1],instr_fifo_data_out);
				end
			default: $display("WRONG PLACE DUDE");			
		endcase
		state = next_state;
		extra_bit_flag	= extra_bit_flag + 1'b1;	
	end
end
endmodule
