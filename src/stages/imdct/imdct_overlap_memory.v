`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:47:09 07/27/2016 
// Design Name: 
// Module Name:    imdct_overlap_memory 
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
module imdct_overlap_memory(
	input wire clk,
	
	input  wire        read_enable,
	input  wire  [9:0] read_addr,
	output wire [17:0] read_data,
	
	input  wire        write_enable,
	input  wire  [9:0] write_addr,
	input  wire [17:0] write_data
    );
	 
	memory_twoport #(
		.RAM_WIDTH(18),
		.RAM_ADDR_BITS(10)
	) ram (
		.clk(clk),
		.read_en(read_enable),
		.read_addr(read_addr),
		.read_data(read_data),
		.write_en(write_enable),
		.write_addr(write_addr),
		.write_data(write_data)
	);


endmodule
