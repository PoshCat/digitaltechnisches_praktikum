`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:04:56 07/15/2016 
// Design Name: 
// Module Name:    common_pulse 
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
module common_pulse #(
   parameter INIT_PULSE = 0
)(
    input wire clk,
	 input wire rst,
	 
	 input wire in1_pulse,
	 input wire in2_pulse,	 
	 
	 output reg out_pulse
    );

	reg in1_flag;
	reg in2_flag;

   always @(posedge clk) begin
		if(rst) begin
			out_pulse <= 0;
			in1_flag <= INIT_PULSE;
			in2_flag <= INIT_PULSE;
		end 
		else begin
			out_pulse <= 0;			
			
			if(in1_pulse) begin
				in1_flag <= 1;
			end
			
			if(in2_pulse) begin
				in2_flag <= 1;
			end			
			
			if(in1_pulse && in2_pulse) begin
				out_pulse <= 1;
				in1_flag <= 0;
				in2_flag <= 0;
			end

			if(in1_pulse && in2_flag) begin
				out_pulse <= 1;
				in1_flag <= 0;
				in2_flag <= 0;
			end

			if(in1_flag && in2_pulse) begin
				out_pulse <= 1;
				in1_flag <= 0;
				in2_flag <= 0;
			end
			
			if(in1_flag && in2_flag) begin
				out_pulse <= 1;
				in1_flag <= 0;
				in2_flag <= 0;
			end			
		end
	end
endmodule
