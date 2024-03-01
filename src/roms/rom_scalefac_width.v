`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:37:40 07/18/2016 
// Design Name: 
// Module Name:    rom_scalefac_width 
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
module rom_scalefac_width(
    input wire         clk,
    input wire         enable,
    input wire  [1:0]  mode,
    input wire  [1:0]  freq,
    input wire  [4:0]  ch_width,
    output wire [7:0]  data
    );

	romfile #(
		.ROM_WIDTH(8),
		.ROM_ADDR_BITS(9),
		.FILENAME("lookup_scalefac_width.txt")
	) rom (
		.clk(clk),
		.read_en(enable),
		.read_addr( { mode, freq, ch_width } ),
		.data(data)
	);


endmodule
