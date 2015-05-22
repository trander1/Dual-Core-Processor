`timescale 1ns / 10ps // I have made changes in this file (Ilia). Fixed zero_flag for synthesis.
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:07:56 02/12/2015 
// Design Name: 
// Module Name:    top 
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

module alu	(
		final_output,carry_output, zero_flag,
		opcode_inputs, reset_in, clk
		);

parameter OPCODE_LENGTH = 4;
parameter DATA_WIDTH = 8;
parameter VECTOR_LENGTH = OPCODE_LENGTH + DATA_WIDTH + DATA_WIDTH;

parameter NOP = 4'b0000;
parameter ADD = 4'b0001;
parameter SUBTRACT = 4'b0010;
parameter MULT	= 4'b0011;
parameter DIVIDE = 4'b0100;
parameter AND = 4'b0110;
parameter OR = 4'b0111;
parameter ZERO_TEST = 4'b1001;
parameter GREATER_THAN = 4'b1010;
parameter EQUAL = 4'b1011;
parameter LESS_THAN = 4'b1100;

output reg [DATA_WIDTH-1:0] final_output;
output reg carry_output;
output zero_flag;

input [VECTOR_LENGTH-1:0] opcode_inputs;
input reset_in;
input clk;

reg [VECTOR_LENGTH-1:0] prev_opcode_inputs;
	
// including the necessary task files
task CRAFA_module(
    output reg sum,carry,
    input in1,in2,carry_in
    );

reg intermediate, gen, propagate;
begin
propagate = in1 ^ in2;
sum = propagate ^ carry_in;
gen = in1 & in2;
intermediate = propagate & carry_in;
carry = intermediate | gen;
end
endtask

task CRA4bit(
    output reg [3:0] cra_sum,
    output reg cra_carry_out,
    input [3:0] in1,in2,
    input carry_in
    );
reg carry1,carry2,carry3;
begin
CRAFA_module 	(cra_sum[0],carry1,in1[0],in2[0],carry_in);
CRAFA_module	(cra_sum[1],carry2,in1[1],in2[1],carry1);
CRAFA_module	(cra_sum[2],carry3,in1[2],in2[2],carry2);
CRAFA_module	(cra_sum[3],cra_carry_out,in1[3],in2[3],carry3);
end
endtask
	 	 
task CRA8bit(
    output reg [7:0] cra_sum,
    output reg cra_carry_out,
    input [7:0] in1,in2,
    input carry_in
    );
reg carry1;
begin
CRA4bit	(cra_sum[3:0],carry1,in1[3:0],in2[3:0],carry_in);
CRA4bit	(cra_sum[7:4],cra_carry_out,in1[7:4],in2[7:4],carry1);
end
endtask

task cra8_task(
    output [DATA_WIDTH-1:0] adder_output,
    output adder_carryout,
    input [DATA_WIDTH-1:0] adder_in1, adder_in2,
    input adder_carryin
    );
begin
	CRA8bit(adder_output,adder_carryout,adder_in1,adder_in2,adder_carryin);
end
endtask

task scra8_task(
    output [DATA_WIDTH-1:0] sub_output,
    output sub_c_b_out,
    input [DATA_WIDTH-1:0] sub_in1,sub_in2,
    input sub_c_b_in
    ); 
reg [DATA_WIDTH-1:0]temp;
begin
	temp = ~sub_in2 + 8'b1;
	CRA8bit(sub_output,sub_c_b_out, sub_in1, temp, sub_c_b_in);
end
endtask

task CSAFA_module(
    output reg sum,carry,
    input in1,in2,carry_in
    );

reg intermediate, gen, propagate;
begin
propagate = in1 ^ in2;
sum = propagate ^ carry_in;
gen = in1 & in2;
intermediate = propagate & carry_in;
carry = intermediate | gen;
end
endtask

task and_mux(
	output reg carry_out,
	input reg propagate1, propagate2, propagate3, propagate4, carry_in, csa_carry
	);
reg temp_and;	
begin
	temp_and = propagate1 & propagate2 & propagate3 & propagate4;
	if(temp_and)
	begin
		carry_out = carry_in;
	end else
		begin
			carry_out = csa_carry;
		end
end	
endtask

task gen_propagate(
	output reg [3:0]propagate,
	input [3:0]in1,in2
	);
begin	
	propagate[0] = in1[0] & in2[0];	
	propagate[1] = in1[1] & in2[1];	
	propagate[2] = in1[2] & in2[2];	
	propagate[3] = in1[3] & in2[3];	
end	
endtask

task CSA4bit(
    output reg [3:0] csa_sum,
    output reg csa_carry_out,
    input [3:0] in1,in2,
    input carry_in
    );
reg carry1,carry2,carry3,carry4;
reg [3:0]propagate;
begin
gen_propagate 	(propagate, in1, in2);
CSAFA_module 	(csa_sum[0],carry1,in1[0],in2[0],carry_in);
CSAFA_module	(csa_sum[1],carry2,in1[1],in2[1],carry1);
CSAFA_module	(csa_sum[2],carry3,in1[2],in2[2],carry2);
CSAFA_module	(csa_sum[3],carry4,in1[3],in2[3],carry3);
and_mux			(csa_carry_out,propagate[0],propagate[1],propagate[2],propagate[3],carry_in,carry4);
end
endtask
	 	 
task CSA8bit(
    output reg [7:0] csa_sum,
    output reg csa_carry_out,
    input [7:0] in1,in2,
    input carry_in
    );
reg carry1;
begin
CSA4bit	(csa_sum[3:0],carry1,in1[3:0],in2[3:0],carry_in);
CSA4bit	(csa_sum[7:4],csa_carry_out,in1[7:4],in2[7:4],carry1);
end
endtask

task csa8_task(
    output [DATA_WIDTH-1:0] adder_output,
    output adder_carryout,
    input [DATA_WIDTH-1:0] adder_in1, adder_in2,
    input adder_carryin
    );
begin
	CSA8bit(adder_output,adder_carryout,adder_in1,adder_in2,adder_carryin);
end
endtask

task scsa8_task(
    output [DATA_WIDTH-1:0] sub_output,
    output sub_c_b_out,
    input [DATA_WIDTH-1:0] sub_in1,sub_in2,
    input sub_c_b_in
    ); 
reg [DATA_WIDTH-1:0]temp;
begin
	temp = ~sub_in2 + 8'b1;
	CSA8bit(sub_output,sub_c_b_out, sub_in1, temp, sub_c_b_in);
end
endtask

reg [DATA_WIDTH-1:0]input1;	// storing the 1st operand from the input vector		
reg [DATA_WIDTH-1:0]input2;	// storing the 2nd operand from the input vector
reg [OPCODE_LENGTH-1:0]opcode;	// storing the opcode from the input vector
reg carry_in;		// initial carry in

always @(posedge clk)
begin	
	if(reset_in)
	begin
		carry_in = 1'b0;
		carry_output = 1'b0;
		final_output = 8'b0;
		prev_opcode_inputs = 0;
	end else
	begin
		if(prev_opcode_inputs != opcode_inputs)
		begin
			prev_opcode_inputs = opcode_inputs;	
			opcode = opcode_inputs[VECTOR_LENGTH-1:VECTOR_LENGTH-OPCODE_LENGTH];	// opcode from the input vector
			input1 = opcode_inputs[VECTOR_LENGTH-OPCODE_LENGTH-1:VECTOR_LENGTH-OPCODE_LENGTH-DATA_WIDTH];	// 1st operand from the input vector
			input2 = opcode_inputs[VECTOR_LENGTH-OPCODE_LENGTH-DATA_WIDTH-1:VECTOR_LENGTH-OPCODE_LENGTH-DATA_WIDTH-DATA_WIDTH];								// 2nd operand from the input vector	
			$display("opcode: %d", opcode);
			case (opcode)
			NOP: begin
					// $display ("NOP");
						// nop_task(final_output);
						final_output = 16'b0;
					end	
			ADD: begin
						// can be changed from the alu.vh file
						`ifdef CSA_ADDITION
							// $display ("CSA ADD");
							CSA8bit(final_output,carry_output,input1, input2, carry_in);					
						`else
							// $display ("CRA ADD");
							CRA8bit(final_output,carry_output, input1, input2, carry_in);
						`endif	
					end
			SUBTRACT: 	begin						
								`ifdef CSA_ADDITION
									// $display ("CSA SUB");
									scsa8_task(final_output,carry_output,input1, input2, carry_in);							
								`else
									// $display ("CRA SUB");
									scra8_task(final_output,carry_output,input1, input2, carry_in);
								`endif	
							end
			AND: begin
						// $display ("AND");
						// and_task(final_output, carry_output, input1, input2);
						carry_output = 1'b0;
						final_output = input1 & input2;
					end
			OR: 	begin
						// $display ("OR");
						// or_task(final_output, carry_output, input1, input2);
						carry_output = 1'b0;
						final_output = input1 | input2;
					end
			ZERO_TEST: begin
								// $display ("ZERO");
								// zero_test_task(final_output, carry_output, input1);
								carry_output = 1'b0;
								if(input1 == 16'b0)
									final_output = 16'b1;
								else 	
									final_output = 16'b0;
							end	
			GREATER_THAN: begin
									// $display ("GREATER THAN");							
									// greater_than_task(final_output, carry_output, input1, input2);
									carry_output = 1'b0;
									if(input1 > input2)	
										final_output = 16'b1;
									else 
										final_output = 16'b0;
								end		
			EQUAL: 	begin
							// $display ("EQUAL");
							// equal_task(final_output, carry_output, input1, input2);
							carry_output = 1'b0;
							if(input1 == input2)
								final_output = 16'b1;
							else 
								final_output = 16'b0;
						end					
			LESS_THAN: begin
								// $display ("LESS THAN");
								// less_than_task(final_output, carry_output, input1, input2);
								carry_output = 1'b0;
								if(input1 < input2)	
									final_output = 16'b1;
								else 	
									final_output = 16'b0;
							end
			default: final_output = final_output;
			endcase	
			// $display("final_out: %d, input1: %d, input1: %d", final_output, input1, input2);
		end
	end		
end

assign zero_flag = final_output ? 1'b0 : 1'b1;

endmodule
