`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:20:01 07/19/2016 
// Design Name: 
// Module Name:    double_buffer 
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
module double_buffer #(
   parameter RAM_WIDTH = 36,
   parameter RAM_ADDR_BITS = 11
)(
    input wire  clk,
	 input wire  rst,
	 
	 input wire  buffer_switch_event, 
	 
    input  wire [RAM_ADDR_BITS-1:0] read_addr,
	 output wire [RAM_WIDTH-1:0]     read_data,	 

	 input wire                      write_enable,
	 input wire  [RAM_ADDR_BITS-1:0] write_addr, 
	 input wire  [RAM_WIDTH-1:0]     write_data
    );



	reg memory_switch_flag;
	
	always @(posedge clk) begin
		if(rst) begin
			memory_switch_flag <= 0;
		end 
		else begin
			if(buffer_switch_event) begin
				memory_switch_flag <= !memory_switch_flag;
			end
		end
	end


	wire [RAM_ADDR_BITS:0] memory_read_addr  =  memory_switch_flag? {1'b0, read_addr}  : {1'b1, read_addr};
	wire [RAM_ADDR_BITS:0] memory_write_addr =  memory_switch_flag? {1'b1, write_addr} : {1'b0, write_addr};


	memory_twoport #(
		.RAM_WIDTH(RAM_WIDTH),
		.RAM_ADDR_BITS(RAM_ADDR_BITS+1)
	) memory (
    .clk(clk),
	 
	 .read_en(1'b1),
    .read_addr(memory_read_addr),
    .read_data(read_data),
	 
	 .write_en(write_enable),
    .write_addr(memory_write_addr),
    .write_data(write_data)
	); 

endmodule
