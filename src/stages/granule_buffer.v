`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:49:16 07/15/2016 
// Design Name: 
// Module Name:    granule_buffer 
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
module granule_buffer(
    input wire         clk,
	 input wire         rst,

// --------------------------------------------------	
	 
	 input wire         buffer_switch_event, 
	 
// --------------------------------------------------	

	 input  wire  [9:0] granule_ch0_read_addr,
	 output wire [17:0] granule_ch0_read_data,
	 input  wire        granule_ch0_write_enable,
	 input  wire  [9:0] granule_ch0_write_addr, 
	 input  wire [17:0] granule_ch0_write_data,	 	 

	 input  wire  [9:0] granule_ch1_read_addr,
	 output wire [17:0] granule_ch1_read_data,
	 input  wire        granule_ch1_write_enable,
	 input  wire  [9:0] granule_ch1_write_addr, 
	 input  wire [17:0] granule_ch1_write_data	
    );

	double_buffer #(
		.RAM_WIDTH(18),
		.RAM_ADDR_BITS(10)
	) double_buffer_ch0 (
    .clk(clk),
	 .rst(rst),
	 
	 .buffer_switch_event(buffer_switch_event), 
	 
    .read_addr(granule_ch0_read_addr),
	 .read_data(granule_ch0_read_data),	 

	 .write_enable(granule_ch0_write_enable),
	 .write_addr(granule_ch0_write_addr), 
	 .write_data(granule_ch0_write_data)	
	);
	
	double_buffer #(
		.RAM_WIDTH(18),
		.RAM_ADDR_BITS(10)
	) double_buffer_ch1 (
    .clk(clk),
	 .rst(rst),
	 
	 .buffer_switch_event(buffer_switch_event), 
	 
    .read_addr(granule_ch1_read_addr),
	 .read_data(granule_ch1_read_data),	 

	 .write_enable(granule_ch1_write_enable),
	 .write_addr(granule_ch1_write_addr), 
	 .write_data(granule_ch1_write_data)	
	);

endmodule
