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
module rom_requantize_pretab(
    input wire          clk,
	 input wire          enable,
    input wire  [4:0]   cb,
    output wire [1:0]   data
    );

	romfile #(
		.ROM_WIDTH(2),
		.ROM_ADDR_BITS(5),
		.FILENAME("lookup_requantize_pretab.txt")
	) rom (
		.clk(clk),
		.read_en(enable),
		.read_addr(cb),
		.data(data)
	);
endmodule

