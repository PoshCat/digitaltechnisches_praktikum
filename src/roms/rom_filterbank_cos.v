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
module rom_filterbank_cos (
    input wire          clk,
	 input wire          enable,
	 input wire  [5:0]   i,
	 input wire  [4:0]   k,
    output wire [17:0]  data
    );

	romfile #(
		.ROM_WIDTH(18),
		.ROM_ADDR_BITS(11),
		.FILENAME("lookup_filterbank_cos.txt")
	) rom (
		.clk(clk),
		.read_en(enable),
		.read_addr({i, k}),
		.data(data)
	);
endmodule

