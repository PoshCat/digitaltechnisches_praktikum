`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:27:56 07/15/2016 
// Design Name: 
// Module Name:    memory 
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
module memory_twoport #(
   parameter RAM_WIDTH = 18,
   parameter RAM_ADDR_BITS = 10
)(
    input wire                     clk,
	 
	 input wire                     read_en,
    input wire [RAM_ADDR_BITS-1:0] read_addr,
    output reg [RAM_WIDTH-1:0]     read_data,
	 
	 input wire                     write_en,
    input wire [RAM_ADDR_BITS-1:0] write_addr,
    input wire [RAM_WIDTH-1:0]     write_data
);

   (* RAM_STYLE="BLOCK" *)
   reg [RAM_WIDTH-1:0] memory [(2**RAM_ADDR_BITS)-1:0];


   //  The forllowing code is only necessary if you wish to initialize the RAM 
   //  contents via an external file (use $readmemb for binary data)
   initial begin :RAM
	  integer i;
	  for(i=0; i < (2**RAM_ADDR_BITS); i = i + 1)
	  begin
	  	  memory[i] = 0;
	  end
	end

   always @(posedge clk) begin
      if (write_en) begin
          memory[write_addr] <= write_data;
		end

      if (read_en) begin
         read_data <= memory[read_addr];
		end
   end
						
endmodule
