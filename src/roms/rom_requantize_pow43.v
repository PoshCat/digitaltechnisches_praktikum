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
module rom_requantize_pow43(
    input wire          clk,
	 input wire          enable,
    input wire  [12:0]  base,
    output wire [17:0]  data
    );

	romfile #(
		.ROM_WIDTH(18),
		.ROM_ADDR_BITS(13),
		.FILENAME("lookup_requantize_pow43.txt")
	) rom (
		.clk(clk),
		.read_en(enable),
		.read_addr(base),
		.data(data)
	);
endmodule

