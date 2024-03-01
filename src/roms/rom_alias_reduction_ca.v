`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:16:17 07/14/2016 
// Design Name: 
// Module Name:    rom_alias_reduction_ca 
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
module rom_alias_reduction_ca(
    input wire          clk,
	 input wire          enable,
    input wire  [2:0]   index,
    output wire [17:0]  data
    );

	romfile #(
		.ROM_WIDTH(18),
		.ROM_ADDR_BITS(3),
		.FILENAME("lookup_alias_reduction_ca.txt")
	) rom (
		.clk(clk),
		.read_en(enable),
		.read_addr(index),
		.data(data)
	);
endmodule
