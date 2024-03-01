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
module rom_filterbank_d (
    input wire          clk,
	 input wire          enable,
	 input wire  [8:0]   i,
    output wire [17:0]  data
    );

	romfile #(
		.ROM_WIDTH(18),
		.ROM_ADDR_BITS(9),
		.FILENAME("lookup_filterbank_d.txt")
	) rom (
		.clk(clk),
		.read_en(enable),
		.read_addr(i),
		.data(data)
	);
endmodule

