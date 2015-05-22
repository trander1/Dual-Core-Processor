`timescale 1ns / 1ps
`define LOG2(width) 	(width<=2)?1:\
							(width<=4)?2:\
							-1							
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:33:56 03/25/2015 
// Design Name: 
// Module Name:    fifo_top 
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
module fifo(
    data_out, empty_flag, full_flag,
    vector_in, reset, clk
    );
parameter DATA_WIDTH = 4;
parameter NUM_ENTRIES = 2;
parameter OPCODE_WIDTH = 2;
parameter EXTRA_BIT = 1;
parameter LINE_WIDTH = DATA_WIDTH+OPCODE_WIDTH+EXTRA_BIT; // length of the input vector 
parameter INITIAL_VALUE = 'b0; 
parameter NUM_ENTRIES_BIT = `LOG2(NUM_ENTRIES); 

parameter READ = 2'b01;
parameter WRITE = 2'b10;
parameter DO_NOTHING = 2'b00;

parameter DATA_VALID	= 1'b1;
parameter DATA_INVALID = 1'b0;

parameter FIFO_FULL = 1'b1;
parameter FIFO_NOT_FULL	= 1'b0;

parameter FIFO_EMPTY = 1'b1;
parameter FIFO_NOT_EMPTY = 1'b0;

output reg [DATA_WIDTH-1:0]data_out;
output reg empty_flag;
output reg full_flag;
input [LINE_WIDTH-1:0]vector_in;
input reset;
input clk;

reg [DATA_WIDTH-1:0]fifo_data[NUM_ENTRIES-1:0];
reg [NUM_ENTRIES-1:0]fifo_valid_invalid_bit;

reg [OPCODE_WIDTH-1:0]control_in;	// control bits for the module obtained from the input vector
reg [DATA_WIDTH-1:0]data_in;			// data bits for the module obtained from the input vector

reg [NUM_ENTRIES_BIT-1:0]fifo_head_pos;
reg [NUM_ENTRIES_BIT-1:0]fifo_tail_pos;

reg [NUM_ENTRIES_BIT-1:0]loop_variable;

always@(vector_in or reset)
//always@(posedge clk)
begin	
	if(reset)
	begin
		data_out = INITIAL_VALUE;
		fifo_head_pos = INITIAL_VALUE;
		fifo_tail_pos = INITIAL_VALUE;
		loop_variable = INITIAL_VALUE;
		control_in = INITIAL_VALUE;
		data_in = INITIAL_VALUE;
		fifo_valid_invalid_bit = INITIAL_VALUE;
		empty_flag = FIFO_EMPTY;
		full_flag = FIFO_NOT_FULL;
	end else
		begin					
			// $display("fifo_head_pos:%d, fifo_tail_pos:%d, empty_flag:%d, full_flag:%d", fifo_head_pos, fifo_tail_pos, empty_flag,full_flag);
			control_in = vector_in[LINE_WIDTH-1:LINE_WIDTH-OPCODE_WIDTH];	
			data_in = vector_in[LINE_WIDTH-OPCODE_WIDTH-1:LINE_WIDTH-OPCODE_WIDTH-DATA_WIDTH];
			// $display("control: %d,data_in: %d",control_in, data_in);	
			case(control_in)			
				READ: 
					begin
						// $display("FIFO READ");						
						if(fifo_valid_invalid_bit[fifo_tail_pos] == DATA_VALID)
						begin
							data_out = fifo_data[fifo_tail_pos];
							fifo_valid_invalid_bit[fifo_tail_pos] = DATA_INVALID;
							fifo_tail_pos = fifo_tail_pos + 1'b1;							
						end else
							begin
								data_out = 'bx;
							end
					end	
				WRITE: 
					begin
						// $display("FIFO WRITE");
						if(empty_flag == FIFO_EMPTY && full_flag == FIFO_NOT_FULL)
						begin
							fifo_data[fifo_head_pos] = data_in;
							fifo_valid_invalid_bit[fifo_head_pos] = DATA_VALID;
							if(fifo_head_pos == NUM_ENTRIES-1)
								fifo_head_pos = 0;
							else	
								fifo_head_pos = fifo_head_pos + 1'b1;
						end 
//								else
							// $display("CACHE FULL, empty_flag:%d, full_flag:%d",empty_flag,full_flag);
					end
				default: data_out = {DATA_WIDTH{1'bz}};
			endcase				
		end		
end

always@(fifo_tail_pos or fifo_head_pos)
begin
	// if the tail and head are at the same location
	if(fifo_tail_pos == fifo_head_pos)begin
		// check if the data contained in that location is VALID/INVALID
		if(fifo_valid_invalid_bit[fifo_tail_pos] == DATA_INVALID && fifo_valid_invalid_bit[fifo_head_pos] == DATA_INVALID)
			begin
			// if INVALID, fifo empty
			// $display("INVALID, EMPTY");
			empty_flag = FIFO_EMPTY;
			full_flag = FIFO_NOT_FULL;
		end else
			begin
				// else, fifo full
				// $display("VALID, FULL");
				empty_flag = FIFO_NOT_EMPTY;
				full_flag = FIFO_FULL;					
			end	
	end else 				
		begin
			// $display("DIFFERENT LOCATIONS");
			empty_flag = FIFO_EMPTY;
			full_flag = FIFO_NOT_FULL;
		end
end
endmodule
