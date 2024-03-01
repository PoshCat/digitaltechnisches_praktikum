`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:20:43 07/14/2016 
// Design Name: 
// Module Name:    rom_requantize_d 
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
module rom_imdct_sinwindow(
    input wire          clk,
	 input wire          enable,
	 input wire  [1:0]   window,
	 input wire  [5:0]   n,
    output wire [17:0]  data
    );

	romfile #(
		.ROM_WIDTH(18),
		.ROM_ADDR_BITS(8),
		.FILENAME("lookup_imdct_sinwindow.txt")
	) rom (
		.clk(clk),
		.read_en(enable),
		.read_addr({window, n}),
		.data(data)
	);
endmodule

