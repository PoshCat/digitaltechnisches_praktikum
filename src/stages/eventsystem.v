`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:01:05 07/18/2016 
// Design Name: 
// Module Name:    buffer_eventsystem 
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
module eventsystem#(
	parameter STAGES=6
)(
	input  wire clk,
	input  wire rst,

	input  wire [STAGES-1:0] stage_done,
	
	output wire [STAGES-1:0] stage_ready,
	output wire [STAGES-2:0] buffer_switch
);

	localparam STAGE_READY_DELAY = 1;


	wire [STAGES-1:0] stage_ready_nodelay;
	reg  [STAGES-1:0] stage_ready_delayed [STAGE_READY_DELAY-1:0];


	genvar i;
	
	generate
		for (i = 0; i < STAGES-1; i = i + 1) begin :memory_switch_pulse
			common_pulse #(
				.INIT_PULSE(1)
			)pulse(
				.clk(clk),
				.rst(rst),
				
				.in1_pulse(stage_done[i]),
				.in2_pulse(stage_done[i+1]),
				.out_pulse(buffer_switch[i])
			);		  
		end
	endgenerate   

	generate
		for (i = 0; i < STAGES-2; i = i + 1) begin :stage_ready_pulse
			common_pulse #(
				.INIT_PULSE(0)
			)pulse(
				.clk(clk),
				.rst(rst),
				
				.in1_pulse(buffer_switch[i]),
				.in2_pulse(buffer_switch[i+1]),
				.out_pulse(stage_ready_nodelay[i+1])
			);		  
		end
	endgenerate  

	assign stage_ready_nodelay[0]        = buffer_switch[0];
	assign stage_ready_nodelay[STAGES-1] = buffer_switch[STAGES-2];

	generate
		for (i = 0; i < STAGE_READY_DELAY; i = i + 1) begin :stage_ready_delay
			if( i == 0) begin
				always @(posedge clk) begin
					if(rst) begin
						stage_ready_delayed[i] <= 0;				
					end
					else begin
						stage_ready_delayed[i] <= stage_ready_nodelay;
					end
				end			
			end
			else begin
				always @(posedge clk) begin
					if(rst) begin
						stage_ready_delayed[i] <= 0;				
					end
					else begin
						stage_ready_delayed[i] <= stage_ready_delayed[i-1];
					end
				end
			end
		end
	endgenerate  

	assign stage_ready = stage_ready_delayed[STAGE_READY_DELAY-1];

endmodule
