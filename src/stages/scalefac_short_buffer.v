`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:33:12 07/19/2016 
// Design Name: 
// Module Name:    scalefac_buffer 
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
module scalefac_short_buffer(
    input wire        clk,
	 input wire        rst,

	 input wire        buffer_switch_event, 
	 
    input  wire [1:0] scalfac_read_addr_window,
    input  wire [3:0] scalfac_read_addr_index,	 
	 output wire [3:0] scalfac_read_data,

	 input wire        scalfac_write_enable,
	 input wire  [1:0] scalfac_write_addr_window, 
	 input wire  [3:0] scalfac_write_addr_index, 	 
	 input wire  [3:0] scalfac_write_data
    );

	wire [5:0] write_addr = {scalfac_write_addr_window, scalfac_write_addr_index};
	wire [5:0] read_addr = {scalfac_read_addr_window, scalfac_read_addr_index};

	double_buffer #(
		.RAM_WIDTH(4),
		.RAM_ADDR_BITS(6)
	) double_buffer (
    .clk(clk),
	 .rst(rst),
	 
	 .buffer_switch_event(buffer_switch_event), 
	 
    .read_addr(read_addr),
	 .read_data(scalfac_read_data),	 

	 .write_enable(scalfac_write_enable),
	 .write_addr(write_addr), 
	 .write_data(scalfac_write_data)	
	);

endmodule
