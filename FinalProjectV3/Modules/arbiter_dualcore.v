`timescale 1ns / 1ps

`define BUS_REQUESTED		1'b1
`define BUS_NOT_REQUESTED	1'b0

`define BUS_GRANTED		1'b1
`define BUS_NOT_GRANTED	1'b0

module arbiter(
		grant1, grant2, 
		request_p1, request_p2, enable, reset, clk
		);
  
// outputs from the module
output reg grant1;
output reg grant2;

// inputs to the module
input request_p1;		// request coming from P1
input request_p2;		// request coming from P2
input enable;
input reset;
input clk;

// reg [1:0]choose_bit2;
// reg [1:0]choose_bit1;
 


always @(reset) begin
	if (reset) begin
		// choose_bit1 = 2'b00;
		// choose_bit2= 2'b00;
	end
end


always @*
begin	
	if(enable)
	begin		
//		$display("request_p1:%d, request_p2:%d",request_p1, request_p2);
		case ({request_p1,request_p2})
			2'b11: 	begin
						grant1 = `BUS_GRANTED;
						grant2 = `BUS_NOT_GRANTED;
					end
			2'b01:	begin
						grant1 = `BUS_NOT_GRANTED;
						grant2 = `BUS_GRANTED;
					end
			2'b10:	begin
						grant1 = `BUS_GRANTED;
						grant2 = `BUS_NOT_GRANTED;
					end
			default: 	begin
							grant1 = `BUS_GRANTED;
							grant2 = `BUS_NOT_GRANTED;
						end
				
		endcase	
		// if (request_p1 == `BUS_REQUESTED  && request_p2 == `BUS_REQUESTED)
		// begin
			// grant1 = `BUS_GRANTED;
			// grant2 = `BUS_NOT_GRANTED;
		// end else 
			// begin
				// if (request_p1 == `BUS_REQUESTED  && request_p2 == `BUS_NOT_REQUESTED)
				// begin
					// grant1 = `BUS_GRANTED;
					// grant2 = `BUS_NOT_GRANTED;
				// end else
				// begin
					// if (request_p1 == `BUS_NOT_REQUESTED && request_p2 == `BUS_REQUESTED)
					// begin
						// grant1 = `BUS_NOT_GRANTED;
						// grant2 = `BUS_GRANTED;
					// end
				// end	
			// end
//		$display("grant1:%d, grant2:%d",grant1, grant2);
	end	
	// $display("enableArbiter:%d",enable);
end

// always @(posedge clk) begin
  // if (request_p1 == `BUS_REQUESTED  && request_p2 == `BUS_REQUESTED) begin
    // if (choose_bit1 == 2'b00 || choose_bit1 == 2'b01) begin
     // // selected_tag = tag_p1;
      // grant1 = `BUS_GRANTED;
      // grant2 = `BUS_NOT_GRANTED;
      // choose_bit1 = choose_bit1 + 1'b1;
      // if (choose_bit2 == 2'b01) begin
        // choose_bit2 = 2'b00;
      // end else begin end
    // end else begin
     // // selected_tag = tag_p2;
      // grant1 = `BUS_NOT_GRANTED;
      // grant2 = `BUS_GRANTED;
      // choose_bit1 = choose_bit1 + 1'b1;
      // if (choose_bit2 == 2'b01) begin
        // choose_bit2 = 2'b00;
      // end else begin end
    // end 
  // end else if (request_p1 == `BUS_REQUESTED && request_p2 == `BUS_NOT_REQUESTED) begin
  // if (choose_bit2 == 2'b00) begin
    // choose_bit1 = 2'b00;
    // choose_bit2 = 2'b01;
  // end else begin
    // choose_bit2 = 2'b00;
  // end
   // // selected_tag = tag_p1;
    // grant1 = `BUS_GRANTED;
    // grant2 = `BUS_NOT_GRANTED;
    // choose_bit1 = choose_bit1 + 1'b1;
  // end else if (request_p1 == `BUS_NOT_REQUESTED && request_p2 == `BUS_REQUESTED) begin
  // if (choose_bit2 == 1) begin
    // choose_bit1 = 2'b00;
    // choose_bit2 = 2'b01;
  // end else begin
    // choose_bit2 = 2'b00;
  // end
  // //  selected_tag = tag_p2;
    // grant1 = `BUS_NOT_GRANTED;
    // grant2 = `BUS_GRANTED;
    // choose_bit1 = choose_bit1 + 1'b1;
  // end else begin end
// end
endmodule
  
