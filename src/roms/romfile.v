`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:32:01 07/13/2016 
// Design Name: 
// Module Name:    lookup 
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
module romfile #(
   parameter ROM_WIDTH = 18,
   parameter ROM_ADDR_BITS = 10,
	parameter FILENAME = "lookup.txt"
)(
    input wire                     clk,
	 input wire                     read_en,
    input wire [ROM_ADDR_BITS-1:0] read_addr,
    output reg [ROM_WIDTH-1:0]     data
    );

   reg [ROM_WIDTH-1:0] rom [(2**ROM_ADDR_BITS)-1:0];

   initial begin
      $readmemh({"../../../mp3_module/src/roms/",FILENAME}, rom, 0, (2**ROM_ADDR_BITS)-1);
	end

   always @(posedge clk) begin
      if (read_en) begin
         data <= rom[read_addr];
		end
	end
endmodule
