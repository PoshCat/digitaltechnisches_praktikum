`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:08:18 07/19/2016 
// Design Name: 
// Module Name:    buffer 
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
module buffer #(
   parameter DATA_WIDTH = 36
)(
    input wire  clk,
	 input wire  rst,
	 
	 input wire  buffer_assign_event, 
	 
    input  wire [DATA_WIDTH-1:0] data_in,
	 output reg [DATA_WIDTH-1:0] data_out
    );
	 
	always @(posedge clk) begin
		if(rst) begin
			data_out <= 0;
		end 
		else begin
			if(buffer_assign_event) begin
				data_out <= data_in;
			end
		end
	end

endmodule
