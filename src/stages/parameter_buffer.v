`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:59:48 08/02/2016 
// Design Name: 
// Module Name:    parameter_buffer 
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
module parameter_buffer #(
   parameter DATA_WIDTH = 36
)(
    input wire  clk,
	 input wire  rst,
	 
	 input wire  buffer_switch_event, 
	 
    input wire [DATA_WIDTH-1:0] write_data,
	 input wire                  write_enable,
	 
	 output wire [DATA_WIDTH-1:0] read_data
    );

	double_buffer #(
		.RAM_WIDTH(DATA_WIDTH),
		.RAM_ADDR_BITS(1)
	) double_buffer_ch0 (
    .clk(clk),
	 .rst(rst),
	 
	 .buffer_switch_event(buffer_switch_event), 
	 
    .read_addr(1'b0),
	 .read_data(read_data),	 

	 .write_enable(write_enable),
	 .write_addr(1'b0), 
	 .write_data(write_data)	
	);

endmodule
