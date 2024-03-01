`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:49:13 07/15/2016 
// Design Name: 
// Module Name:    requantize 
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
module requantize(
    input  wire clk,
    input  wire rst,	 
	 
// ==================================================
// 576 lines
// --------------------------------------------------	 
	 
	 output wire  [9:0] granule_ch0_read_addr,
	 input  wire [17:0] granule_ch0_read_data,	 

	 output wire        granule_ch0_write_enable,
	 output wire  [9:0] granule_ch0_write_addr, 
	 output wire [17:0] granule_ch0_write_data,

// --------------------------------------------------

	 output wire  [9:0] granule_ch1_read_addr,
	 input  wire [17:0] granule_ch1_read_data,	

	 output wire        granule_ch1_write_enable,
	 output wire  [9:0] granule_ch1_write_addr, 
	 output wire [17:0] granule_ch1_write_data, 
	 
// ==================================================
// scale factors
// --------------------------------------------------	  	 

	 output wire  [1:0] scalfac_ch0_short_read_addr_window,
	 output wire  [3:0] scalfac_ch0_short_read_addr_index,			 
	 input  wire  [3:0] scalfac_ch0_short_read_data,
	 
	 output wire  [5:0] scalfac_ch0_long_read_addr,
	 input  wire  [3:0] scalfac_ch0_long_read_data,
	 
// --------------------------------------------------
	 
	 output wire  [1:0] scalfac_ch1_short_read_addr_window,
	 output wire  [3:0] scalfac_ch1_short_read_addr_index,			 
	 input  wire  [3:0] scalfac_ch1_short_read_data, 
	 
	 output wire  [5:0] scalfac_ch1_long_read_addr,
	 input  wire  [3:0] scalfac_ch1_long_read_data,

// ==================================================
// header information
// --------------------------------------------------	  
	 
	 input  wire  [1:0] header_sampling_frequency,
	 
// ==================================================
// sideinfo information
// --------------------------------------------------	  
	 
	 input  wire        sideinfo_ch0_scalefac_scale,
	 
	 input  wire  [1:0] sideinfo_ch0_block_type,
	 input  wire        sideinfo_ch0_window_switching_flag,
	 input  wire        sideinfo_ch0_mixed_block_flag,	 
	 
	 input  wire        sideinfo_ch0_preflag,
	 
	 input  wire  [7:0] sideinfo_ch0_global_gain,
	 input  wire  [2:0] sideinfo_ch0_subblock_gain_window0,
	 input  wire  [2:0] sideinfo_ch0_subblock_gain_window1,
	 input  wire  [2:0] sideinfo_ch0_subblock_gain_window2, 

// --------------------------------------------------	 
	 
	 input  wire        sideinfo_ch1_scalefac_scale,
	 
	 input  wire  [1:0] sideinfo_ch1_block_type,
	 input  wire        sideinfo_ch1_window_switching_flag,
	 input  wire        sideinfo_ch1_mixed_block_flag,	 
	 
	 input  wire        sideinfo_ch1_preflag,
	 
	 input  wire  [7:0] sideinfo_ch1_global_gain,
	 input  wire  [2:0] sideinfo_ch1_subblock_gain_window0,
	 input  wire  [2:0] sideinfo_ch1_subblock_gain_window1,
	 input  wire  [2:0] sideinfo_ch1_subblock_gain_window2, 	 
	 
// ==================================================
// stage signaling
// --------------------------------------------------	
	 
     input  wire        stage_ready,
     output wire        stage_done
    );
	 
	// real registers
	reg [1:0] state_done;
	
	// wires
	wire done_ch0, done_ch1;

	// processing of channel 0
	requantize_channel channel0 (
		.clk(clk),
		.rst(rst),	 
		.granule_read_addr(granule_ch0_read_addr),
		.granule_read_data(granule_ch0_read_data),	 
		.granule_write_enable(granule_ch0_write_enable),
		.granule_write_addr(granule_ch0_write_addr), 
		.granule_write_data(granule_ch0_write_data),
		.scalfac_short_read_addr_window(scalfac_ch0_short_read_addr_window),
		.scalfac_short_read_addr_index(scalfac_ch0_short_read_addr_index),
		.scalfac_short_read_data(scalfac_ch0_short_read_data),
		.scalfac_long_read_addr(scalfac_ch0_long_read_addr),
		.scalfac_long_read_data(scalfac_ch0_long_read_data),
		.header_sampling_frequency(header_sampling_frequency),
		.sideinfo_scalefac_scale(sideinfo_ch0_scalefac_scale),
	   .sideinfo_block_type(sideinfo_ch0_block_type),
		.sideinfo_window_switching_flag(sideinfo_ch0_window_switching_flag),
		.sideinfo_mixed_block_flag(sideinfo_ch0_mixed_block_flag),
		.sideinfo_preflag(sideinfo_ch0_preflag),
		.sideinfo_global_gain(sideinfo_ch0_global_gain),
		.sideinfo_subblock_gain_window0(sideinfo_ch0_subblock_gain_window0),
		.sideinfo_subblock_gain_window1(sideinfo_ch0_subblock_gain_window1),
		.sideinfo_subblock_gain_window2(sideinfo_ch0_subblock_gain_window2),
		.channel_ready(stage_ready),
		.channel_done(done_ch0)
	); 
	
	// processing of channel 1
	requantize_channel channel1 (
		.clk(clk),
		.rst(rst),	 
		.granule_read_addr(granule_ch1_read_addr),
		.granule_read_data(granule_ch1_read_data),	 
		.granule_write_enable(granule_ch1_write_enable),
		.granule_write_addr(granule_ch1_write_addr), 
		.granule_write_data(granule_ch1_write_data),	
		.scalfac_short_read_addr_window(scalfac_ch1_short_read_addr_window),
		.scalfac_short_read_addr_index(scalfac_ch1_short_read_addr_index),
		.scalfac_short_read_data(scalfac_ch1_short_read_data),
		.scalfac_long_read_addr(scalfac_ch1_long_read_addr),
		.scalfac_long_read_data(scalfac_ch1_long_read_data),
		.header_sampling_frequency(header_sampling_frequency),
	   .sideinfo_scalefac_scale(sideinfo_ch1_scalefac_scale),
	   .sideinfo_block_type(sideinfo_ch1_block_type),
		.sideinfo_window_switching_flag(sideinfo_ch1_window_switching_flag),
		.sideinfo_mixed_block_flag(sideinfo_ch1_mixed_block_flag),
		.sideinfo_preflag(sideinfo_ch1_preflag),
		.sideinfo_global_gain(sideinfo_ch1_global_gain),
		.sideinfo_subblock_gain_window0(sideinfo_ch1_subblock_gain_window0),
		.sideinfo_subblock_gain_window1(sideinfo_ch1_subblock_gain_window1),
		.sideinfo_subblock_gain_window2(sideinfo_ch1_subblock_gain_window2),
		.channel_ready(stage_ready),
		.channel_done(done_ch1)
	);
	
	// store the done events for each channel
	always @(posedge clk) begin
		if (rst) begin
			state_done <= 0;
		end else begin
			if (state_done == 2'b11)
				state_done <= 2'b00;
			else begin
				if (done_ch0)
					state_done[0] <= 1;
				if (done_ch1)
					state_done[1] <= 1;
			end
		end
	end
	 
	// stage is done when all channels are done
	assign stage_done = state_done == 2'b11;
	
endmodule
