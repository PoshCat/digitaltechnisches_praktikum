`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:00:13 07/15/2016 
// Design Name: 
// Module Name:    processing 
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

`include "mp3_parameter.vh"


module decoding_chain_parameter #(
	parameter STAGES = 9
)(
		input wire         clk,
		input wire         rst,

		// ===========================================

		input wire        granule_ch0_write_enable,
		input wire  [9:0] granule_ch0_write_addr,
		input wire [17:0] granule_ch0_write_data,	

		input wire        granule_ch1_write_enable,
		input wire  [9:0] granule_ch1_write_addr,
		input wire [17:0] granule_ch1_write_data,	

		// ===========================================

		input wire         scalefac_ch0_short_write_enable,
		input wire   [1:0] scalefac_ch0_short_write_addr_window,
		input wire   [3:0] scalefac_ch0_short_write_addr_index,		
		input wire   [3:0] scalefac_ch0_short_write_data,

		input wire         scalefac_ch1_short_write_enable,
		input wire   [1:0] scalefac_ch1_short_write_addr_window,
		input wire   [3:0] scalefac_ch1_short_write_addr_index,		
		input wire   [3:0] scalefac_ch1_short_write_data,

		input wire         scalefac_ch0_long_write_enable,
		input wire   [5:0] scalefac_ch0_long_write_addr,	
		input wire   [3:0] scalefac_ch0_long_write_data,

		input wire         scalefac_ch1_long_write_enable,
		input wire   [5:0] scalefac_ch1_long_write_addr,	
		input wire   [3:0] scalefac_ch1_long_write_data,

		// ===========================================

		input wire                        parameter_enable,
		input wire [`PARAMETER_WIDTH-1:0] parameter_data,	

		// ===========================================

		output wire        stage_ready,
		input  wire        stage_done,

		// ===========================================
		// ===========================================
		
		input  wire [9:0]  pcm_read_addr,
		output wire [17:0] pcm_read_data_ch0,
		output wire [17:0] pcm_read_data_ch1,

		// ===========================================

		output wire        pcm_ready,
		input  wire        pcm_done

		// -------------------------------------------
    );
		
	// =======================================================================	 
	
	wire [STAGES-1:0] eventsystem_stage_done;
	wire [STAGES-1:0] eventsystem_stage_ready;
	wire [STAGES-2:0] eventsystem_buffer_switch;
		
	eventsystem #(
		.STAGES(STAGES)
	) eventsystem(
		.clk(clk),
		.rst(rst),

		.stage_done(eventsystem_stage_done),
		
		.stage_ready(eventsystem_stage_ready),
		.buffer_switch(eventsystem_buffer_switch)
	);	
		
	assign stage_ready = eventsystem_stage_ready[0];
	assign eventsystem_stage_done[0] = stage_done;
		
	assign pcm_ready = eventsystem_stage_ready[STAGES-1];
	assign eventsystem_stage_done[STAGES-1] = pcm_done;
	
	// =======================================================================	 	
	
   wire  [9:0] requantize_granule_ch0_read_addr;
	wire [17:0] requantize_granule_ch0_read_data;
	wire        requantize_granule_ch0_write_enable;
	wire  [9:0] requantize_granule_ch0_write_addr; 
	wire [17:0] requantize_granule_ch0_write_data;	

   wire  [9:0] requantize_granule_ch1_read_addr;
	wire [17:0] requantize_granule_ch1_read_data;
	wire        requantize_granule_ch1_write_enable;
	wire  [9:0] requantize_granule_ch1_write_addr; 
	wire [17:0] requantize_granule_ch1_write_data;	

	wire  [1:0] requantize_scalfac_ch0_short_read_addr_window;
	wire  [3:0] requantize_scalfac_ch0_short_read_addr_index;			 
	wire  [3:0] requantize_scalfac_ch0_short_read_data;
	wire  [5:0] requantize_scalfac_ch0_long_read_addr;
	wire  [3:0] requantize_scalfac_ch0_long_read_data;

	wire  [1:0] requantize_scalfac_ch1_short_read_addr_window;
	wire  [3:0] requantize_scalfac_ch1_short_read_addr_index;			 
	wire  [3:0] requantize_scalfac_ch1_short_read_data;
	wire  [5:0] requantize_scalfac_ch1_long_read_addr;
	wire  [3:0] requantize_scalfac_ch1_long_read_data;

	wire [`PARAMETER_WIDTH-1:0] requantize_parameter_data;


	scalefac_short_buffer requantize_scalefac_ch0_short_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[0]),

		.scalfac_write_enable(scalefac_ch0_short_write_enable),
		.scalfac_write_addr_window(scalefac_ch0_short_write_addr_window), 		
		.scalfac_write_addr_index(scalefac_ch0_short_write_addr_index), 	 
		.scalfac_write_data(scalefac_ch0_short_write_data), 
	
		.scalfac_read_addr_window(requantize_scalfac_ch0_short_read_addr_window),
		.scalfac_read_addr_index(requantize_scalfac_ch0_short_read_addr_index),
		.scalfac_read_data(requantize_scalfac_ch0_short_read_data)
	);
	
	
	scalefac_short_buffer requantize_scalefac_ch1_short_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[0]),

		.scalfac_write_enable(scalefac_ch1_short_write_enable),
		.scalfac_write_addr_window(scalefac_ch1_short_write_addr_window), 		
		.scalfac_write_addr_index(scalefac_ch1_short_write_addr_index), 	 
		.scalfac_write_data(scalefac_ch1_short_write_data), 
	
		.scalfac_read_addr_window(requantize_scalfac_ch1_short_read_addr_window),
		.scalfac_read_addr_index(requantize_scalfac_ch1_short_read_addr_index),
		.scalfac_read_data(requantize_scalfac_ch1_short_read_data)
	);


	scalefac_long_buffer requantize_scalefac_ch0_long_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[0]),

		.scalfac_write_enable(scalefac_ch0_long_write_enable),
		.scalfac_write_addr(scalefac_ch0_long_write_addr), 
		.scalfac_write_data(scalefac_ch0_long_write_data), 
	
		.scalfac_read_addr(requantize_scalfac_ch0_long_read_addr),
		.scalfac_read_data(requantize_scalfac_ch0_long_read_data)
	);


	scalefac_long_buffer requantize_scalefac_ch1_long_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[0]),

		.scalfac_write_enable(scalefac_ch1_long_write_enable),
		.scalfac_write_addr(scalefac_ch1_long_write_addr), 
		.scalfac_write_data(scalefac_ch1_long_write_data), 
	
		.scalfac_read_addr(requantize_scalfac_ch1_long_read_addr),
		.scalfac_read_data(requantize_scalfac_ch1_long_read_data)
	);


	parameter_buffer #(
		.DATA_WIDTH(`PARAMETER_WIDTH)
	) requantize_parameter_buffer (
		.clk(clk),
		.rst(rst),	
	
		.buffer_switch_event(eventsystem_buffer_switch[0]), 
	 
		.write_data(parameter_data),
		.write_enable(parameter_enable),
		
		.read_data(requantize_parameter_data)
	);


	granule_buffer requantize_granule_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[0]), 

		.granule_ch0_write_enable(granule_ch0_write_enable),
		.granule_ch0_write_addr(granule_ch0_write_addr), 
		.granule_ch0_write_data(granule_ch0_write_data),
		.granule_ch0_read_addr(requantize_granule_ch0_read_addr),
		.granule_ch0_read_data(requantize_granule_ch0_read_data),	 

		.granule_ch1_write_enable(granule_ch1_write_enable),
		.granule_ch1_write_addr(granule_ch1_write_addr), 
		.granule_ch1_write_data(granule_ch1_write_data),	
		.granule_ch1_read_addr(requantize_granule_ch1_read_addr),
		.granule_ch1_read_data(requantize_granule_ch1_read_data)	
	);
	 
	 
	requantize requantize_stage(
		.clk(clk),
		.rst(rst),	 

		.granule_ch0_read_addr(requantize_granule_ch0_read_addr),
		.granule_ch0_read_data(requantize_granule_ch0_read_data), 
		.granule_ch0_write_enable(requantize_granule_ch0_write_enable),
		.granule_ch0_write_addr(requantize_granule_ch0_write_addr), 
		.granule_ch0_write_data(requantize_granule_ch0_write_data),
		
		.granule_ch1_read_addr(requantize_granule_ch1_read_addr),
		.granule_ch1_read_data(requantize_granule_ch1_read_data), 
		.granule_ch1_write_enable(requantize_granule_ch1_write_enable),
		.granule_ch1_write_addr(requantize_granule_ch1_write_addr), 
		.granule_ch1_write_data(requantize_granule_ch1_write_data),

		.scalfac_ch0_short_read_addr_window(requantize_scalfac_ch0_short_read_addr_window),
		.scalfac_ch0_short_read_addr_index(requantize_scalfac_ch0_short_read_addr_index),			 
		.scalfac_ch0_short_read_data(requantize_scalfac_ch0_short_read_data),
		.scalfac_ch0_long_read_addr(requantize_scalfac_ch0_long_read_addr),
		.scalfac_ch0_long_read_data(requantize_scalfac_ch0_long_read_data),
			  
		.scalfac_ch1_short_read_addr_window(requantize_scalfac_ch1_short_read_addr_window),
		.scalfac_ch1_short_read_addr_index(requantize_scalfac_ch1_short_read_addr_index),			 
		.scalfac_ch1_short_read_data(requantize_scalfac_ch1_short_read_data), 
		.scalfac_ch1_long_read_addr(requantize_scalfac_ch1_long_read_addr),
		.scalfac_ch1_long_read_data(requantize_scalfac_ch1_long_read_data),

		.header_sampling_frequency(`header_sampling_frequency(requantize_parameter_data)),
			 
		.sideinfo_ch0_scalefac_scale(`sideinfo_ch0_scalefac_scale(requantize_parameter_data)),
		.sideinfo_ch0_block_type(`sideinfo_ch0_block_type(requantize_parameter_data)),
		.sideinfo_ch0_window_switching_flag(`sideinfo_ch0_window_switching_flag(requantize_parameter_data)),
		.sideinfo_ch0_mixed_block_flag(`sideinfo_ch0_mixed_block_flag(requantize_parameter_data)),	 
		.sideinfo_ch0_preflag(`sideinfo_ch0_preflag(requantize_parameter_data)),
		.sideinfo_ch0_global_gain(`sideinfo_ch0_global_gain(requantize_parameter_data)),
		.sideinfo_ch0_subblock_gain_window0(`sideinfo_ch0_subblock_gain_window0(requantize_parameter_data)),
		.sideinfo_ch0_subblock_gain_window1(`sideinfo_ch0_subblock_gain_window1(requantize_parameter_data)),
		.sideinfo_ch0_subblock_gain_window2(`sideinfo_ch0_subblock_gain_window2(requantize_parameter_data)), 

		.sideinfo_ch1_scalefac_scale(`sideinfo_ch1_scalefac_scale(requantize_parameter_data)),
		.sideinfo_ch1_block_type(`sideinfo_ch1_block_type(requantize_parameter_data)),
		.sideinfo_ch1_window_switching_flag(`sideinfo_ch1_window_switching_flag(requantize_parameter_data)),
		.sideinfo_ch1_mixed_block_flag(`sideinfo_ch1_mixed_block_flag(requantize_parameter_data)),	 
		.sideinfo_ch1_preflag(`sideinfo_ch1_preflag(requantize_parameter_data)),
		.sideinfo_ch1_global_gain(`sideinfo_ch1_global_gain(requantize_parameter_data)),
		.sideinfo_ch1_subblock_gain_window0(`sideinfo_ch1_subblock_gain_window0(requantize_parameter_data)),
		.sideinfo_ch1_subblock_gain_window1(`sideinfo_ch1_subblock_gain_window1(requantize_parameter_data)),
		.sideinfo_ch1_subblock_gain_window2(`sideinfo_ch1_subblock_gain_window2(requantize_parameter_data)), 

		.stage_ready(eventsystem_stage_ready[1]),
		.stage_done(eventsystem_stage_done[1]) 
	);	 


// =======================================================================	 
	
   wire  [9:0] reorder_granule_ch0_read_addr;
	wire [17:0] reorder_granule_ch0_read_data;
	wire        reorder_granule_ch0_write_enable;
	wire  [9:0] reorder_granule_ch0_write_addr; 
	wire [17:0] reorder_granule_ch0_write_data;	

   wire  [9:0] reorder_granule_ch1_read_addr;
	wire [17:0] reorder_granule_ch1_read_data;
	wire        reorder_granule_ch1_write_enable;
	wire  [9:0] reorder_granule_ch1_write_addr; 
	wire [17:0] reorder_granule_ch1_write_data;		
	
	
	wire [`PARAMETER_WIDTH-1:0] reorder_parameter_data;


	parameter_buffer #(
		.DATA_WIDTH(`PARAMETER_WIDTH)
	) reorder_parameter_buffer (
		.clk(clk),
		.rst(rst),	
	
		.buffer_switch_event(eventsystem_buffer_switch[1]), 
	 
		.write_data(requantize_parameter_data),
		.write_enable(eventsystem_stage_done[1]),		
		
		.read_data(reorder_parameter_data)
	);

	granule_buffer reorder_granule_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[1]), 

		.granule_ch0_write_enable(requantize_granule_ch0_write_enable),
		.granule_ch0_write_addr(requantize_granule_ch0_write_addr), 
		.granule_ch0_write_data(requantize_granule_ch0_write_data),
		.granule_ch0_read_addr(reorder_granule_ch0_read_addr),
		.granule_ch0_read_data(reorder_granule_ch0_read_data),	 

		.granule_ch1_write_enable(requantize_granule_ch1_write_enable),
		.granule_ch1_write_addr(requantize_granule_ch1_write_addr), 
		.granule_ch1_write_data(requantize_granule_ch1_write_data),	
		.granule_ch1_read_addr(reorder_granule_ch1_read_addr),
		.granule_ch1_read_data(reorder_granule_ch1_read_data)
	);
	 
	 
	reorder reorder_stage(
		.clk(clk),
		.rst(rst),	 

		.granule_ch0_read_addr(reorder_granule_ch0_read_addr),
		.granule_ch0_read_data(reorder_granule_ch0_read_data), 
		.granule_ch0_write_enable(reorder_granule_ch0_write_enable),
		.granule_ch0_write_addr(reorder_granule_ch0_write_addr), 
		.granule_ch0_write_data(reorder_granule_ch0_write_data),
		
		.granule_ch1_read_addr(reorder_granule_ch1_read_addr),
		.granule_ch1_read_data(reorder_granule_ch1_read_data), 
		.granule_ch1_write_enable(reorder_granule_ch1_write_enable),
		.granule_ch1_write_addr(reorder_granule_ch1_write_addr), 
		.granule_ch1_write_data(reorder_granule_ch1_write_data),
 
		.header_sampling_frequency(`header_sampling_frequency(reorder_parameter_data)),
			 
		.sideinfo_ch0_block_type(`sideinfo_ch0_block_type(reorder_parameter_data)),
		.sideinfo_ch0_window_switching_flag(`sideinfo_ch0_window_switching_flag(reorder_parameter_data)),
		.sideinfo_ch0_mixed_block_flag(`sideinfo_ch0_mixed_block_flag(reorder_parameter_data)),	 
	 
		.sideinfo_ch1_block_type(`sideinfo_ch1_block_type(reorder_parameter_data)),
		.sideinfo_ch1_window_switching_flag(`sideinfo_ch1_window_switching_flag(reorder_parameter_data)),
		.sideinfo_ch1_mixed_block_flag(`sideinfo_ch1_mixed_block_flag(reorder_parameter_data)),	 	 
	 
		.stage_ready(eventsystem_stage_ready[2]),
		.stage_done(eventsystem_stage_done[2]) 
	);	 

// =======================================================================	 
	
   wire  [9:0] stereo_granule_ch0_read_addr;
	wire [17:0] stereo_granule_ch0_read_data;
	wire        stereo_granule_ch0_write_enable;
	wire  [9:0] stereo_granule_ch0_write_addr; 
	wire [17:0] stereo_granule_ch0_write_data;	

   wire  [9:0] stereo_granule_ch1_read_addr;
	wire [17:0] stereo_granule_ch1_read_data;
	wire        stereo_granule_ch1_write_enable;
	wire  [9:0] stereo_granule_ch1_write_addr; 
	wire [17:0] stereo_granule_ch1_write_data;		
	
	wire [`PARAMETER_WIDTH-1:0] stereo_parameter_data;


	parameter_buffer #(
		.DATA_WIDTH(`PARAMETER_WIDTH)
	) stereo_parameter_buffer (
		.clk(clk),
		.rst(rst),	
	
		.buffer_switch_event(eventsystem_buffer_switch[2]), 
	 
		.write_data(reorder_parameter_data),
		.write_enable(eventsystem_stage_done[2]),		
		
		.read_data(stereo_parameter_data)
	);


	granule_buffer stereo_granule_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[2]), 

		.granule_ch0_write_enable(reorder_granule_ch0_write_enable),
		.granule_ch0_write_addr(reorder_granule_ch0_write_addr), 
		.granule_ch0_write_data(reorder_granule_ch0_write_data),
		.granule_ch0_read_addr(stereo_granule_ch0_read_addr),
		.granule_ch0_read_data(stereo_granule_ch0_read_data),	 

		.granule_ch1_write_enable(reorder_granule_ch1_write_enable),
		.granule_ch1_write_addr(reorder_granule_ch1_write_addr), 
		.granule_ch1_write_data(reorder_granule_ch1_write_data),	
		.granule_ch1_read_addr(stereo_granule_ch1_read_addr),
		.granule_ch1_read_data(stereo_granule_ch1_read_data) 
	);
	 
	 
	stereo stereo_stage(
		.clk(clk),
		.rst(rst),	 

		.granule_ch0_read_addr(stereo_granule_ch0_read_addr),
		.granule_ch0_read_data(stereo_granule_ch0_read_data), 
		.granule_ch0_write_enable(stereo_granule_ch0_write_enable),
		.granule_ch0_write_addr(stereo_granule_ch0_write_addr), 
		.granule_ch0_write_data(stereo_granule_ch0_write_data),
		
		.granule_ch1_read_addr(stereo_granule_ch1_read_addr),
		.granule_ch1_read_data(stereo_granule_ch1_read_data), 
		.granule_ch1_write_enable(stereo_granule_ch1_write_enable),
		.granule_ch1_write_addr(stereo_granule_ch1_write_addr), 
		.granule_ch1_write_data(stereo_granule_ch1_write_data), 

		.header_sampling_frequency(`header_sampling_frequency(stereo_parameter_data)),
		.header_mode(`header_mode(stereo_parameter_data)),
		.header_mode_extension(`header_mode_extension(stereo_parameter_data)),

		.stage_ready(eventsystem_stage_ready[3]),
		.stage_done(eventsystem_stage_done[3]) 
	);	 	 

	// =======================================================================	 
	
   wire  [9:0] alias_reduction_granule_ch0_read_addr;
	wire [17:0] alias_reduction_granule_ch0_read_data;
	wire        alias_reduction_granule_ch0_write_enable;
	wire  [9:0] alias_reduction_granule_ch0_write_addr; 
	wire [17:0] alias_reduction_granule_ch0_write_data;	

   wire  [9:0] alias_reduction_granule_ch1_read_addr;
	wire [17:0] alias_reduction_granule_ch1_read_data;
	wire        alias_reduction_granule_ch1_write_enable;
	wire  [9:0] alias_reduction_granule_ch1_write_addr; 
	wire [17:0] alias_reduction_granule_ch1_write_data;	


	wire [`PARAMETER_WIDTH-1:0] alias_reduction_parameter_data;


	parameter_buffer #(
		.DATA_WIDTH(`PARAMETER_WIDTH)
	) alias_reduction_parameter_buffer (
		.clk(clk),
		.rst(rst),	
	
		.buffer_switch_event(eventsystem_buffer_switch[3]), 
	 
		.write_data(stereo_parameter_data),
		.write_enable(eventsystem_stage_done[3]),		
		
		.read_data(alias_reduction_parameter_data)
	);	
	

	granule_buffer alias_reduction_granule_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[3]), 

		.granule_ch0_write_enable(stereo_granule_ch0_write_enable),
		.granule_ch0_write_addr(stereo_granule_ch0_write_addr), 
		.granule_ch0_write_data(stereo_granule_ch0_write_data),
		.granule_ch0_read_addr(alias_reduction_granule_ch0_read_addr),
		.granule_ch0_read_data(alias_reduction_granule_ch0_read_data),	 

		.granule_ch1_write_enable(stereo_granule_ch1_write_enable),
		.granule_ch1_write_addr(stereo_granule_ch1_write_addr), 
		.granule_ch1_write_data(stereo_granule_ch1_write_data),	
		.granule_ch1_read_addr(alias_reduction_granule_ch1_read_addr),
		.granule_ch1_read_data(alias_reduction_granule_ch1_read_data) 	 
	);
	 
	 
	alias_reduction alias_reduction_stage(
		.clk(clk),
		.rst(rst),	 

		.granule_ch0_read_addr(alias_reduction_granule_ch0_read_addr),
		.granule_ch0_read_data(alias_reduction_granule_ch0_read_data), 
		.granule_ch0_write_enable(alias_reduction_granule_ch0_write_enable),
		.granule_ch0_write_addr(alias_reduction_granule_ch0_write_addr), 
		.granule_ch0_write_data(alias_reduction_granule_ch0_write_data),
		
		.granule_ch1_read_addr(alias_reduction_granule_ch1_read_addr),
		.granule_ch1_read_data(alias_reduction_granule_ch1_read_data), 
		.granule_ch1_write_enable(alias_reduction_granule_ch1_write_enable),
		.granule_ch1_write_addr(alias_reduction_granule_ch1_write_addr), 
		.granule_ch1_write_data(alias_reduction_granule_ch1_write_data), 

		.sideinfo_ch0_block_type(`sideinfo_ch0_block_type(alias_reduction_parameter_data)),
		.sideinfo_ch0_window_switching_flag(`sideinfo_ch0_window_switching_flag(alias_reduction_parameter_data)),
		.sideinfo_ch0_mixed_block_flag(`sideinfo_ch0_mixed_block_flag(alias_reduction_parameter_data)),	 

		.sideinfo_ch1_block_type(`sideinfo_ch1_block_type(alias_reduction_parameter_data)),
		.sideinfo_ch1_window_switching_flag(`sideinfo_ch1_window_switching_flag(alias_reduction_parameter_data)),
		.sideinfo_ch1_mixed_block_flag(`sideinfo_ch1_mixed_block_flag(alias_reduction_parameter_data)),	 

		.stage_ready(eventsystem_stage_ready[4]),
		.stage_done(eventsystem_stage_done[4]) 
	);	 	 

	// =======================================================================	 

   wire  [9:0] imdct_granule_ch0_read_addr;
	wire [17:0] imdct_granule_ch0_read_data;
	wire        imdct_granule_ch0_write_enable;
	wire  [9:0] imdct_granule_ch0_write_addr; 
	wire [17:0] imdct_granule_ch0_write_data;	

   wire  [9:0] imdct_granule_ch1_read_addr;
	wire [17:0] imdct_granule_ch1_read_data;
	wire        imdct_granule_ch1_write_enable;
	wire  [9:0] imdct_granule_ch1_write_addr; 
	wire [17:0] imdct_granule_ch1_write_data;		

	wire [`PARAMETER_WIDTH-1:0] imdct_parameter_data;


	parameter_buffer #(
		.DATA_WIDTH(`PARAMETER_WIDTH)
	) imdct_parameter_buffer (
		.clk(clk),
		.rst(rst),	
	
		.buffer_switch_event(eventsystem_buffer_switch[4]), 
	 
		.write_data(alias_reduction_parameter_data),
		.write_enable(eventsystem_stage_done[4]),		
		
		.read_data(imdct_parameter_data)
	);	


	granule_buffer imdct_granule_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[4]), 

		.granule_ch0_write_enable(alias_reduction_granule_ch0_write_enable),
		.granule_ch0_write_addr(alias_reduction_granule_ch0_write_addr), 
		.granule_ch0_write_data(alias_reduction_granule_ch0_write_data),
		.granule_ch0_read_addr(imdct_granule_ch0_read_addr),
		.granule_ch0_read_data(imdct_granule_ch0_read_data),	 

		.granule_ch1_write_enable(alias_reduction_granule_ch1_write_enable),
		.granule_ch1_write_addr(alias_reduction_granule_ch1_write_addr), 
		.granule_ch1_write_data(alias_reduction_granule_ch1_write_data),	
		.granule_ch1_read_addr(imdct_granule_ch1_read_addr),
		.granule_ch1_read_data(imdct_granule_ch1_read_data)	 
	);
	 
	 
	imdct imdct_stage(
		.clk(clk),
		.rst(rst),	 

		.granule_ch0_read_addr(imdct_granule_ch0_read_addr),
		.granule_ch0_read_data(imdct_granule_ch0_read_data), 
		.granule_ch0_write_enable(imdct_granule_ch0_write_enable),
		.granule_ch0_write_addr(imdct_granule_ch0_write_addr), 
		.granule_ch0_write_data(imdct_granule_ch0_write_data),
		
		.granule_ch1_read_addr(imdct_granule_ch1_read_addr),
		.granule_ch1_read_data(imdct_granule_ch1_read_data), 
		.granule_ch1_write_enable(imdct_granule_ch1_write_enable),
		.granule_ch1_write_addr(imdct_granule_ch1_write_addr), 
		.granule_ch1_write_data(imdct_granule_ch1_write_data),	 

		.sideinfo_ch0_block_type(`sideinfo_ch0_block_type(imdct_parameter_data)),
		.sideinfo_ch0_window_switching_flag(`sideinfo_ch0_window_switching_flag(imdct_parameter_data)),
		.sideinfo_ch0_mixed_block_flag(`sideinfo_ch0_mixed_block_flag(imdct_parameter_data)),

		.sideinfo_ch1_block_type(`sideinfo_ch1_block_type(imdct_parameter_data)),
		.sideinfo_ch1_window_switching_flag(`sideinfo_ch1_window_switching_flag(imdct_parameter_data)),
		.sideinfo_ch1_mixed_block_flag(`sideinfo_ch1_mixed_block_flag(imdct_parameter_data)),

		.stage_ready(eventsystem_stage_ready[5]),
		.stage_done(eventsystem_stage_done[5]) 
	);

	// =======================================================================	 
	
   wire  [9:0] frequency_inversion_granule_ch0_read_addr;
	wire [17:0] frequency_inversion_granule_ch0_read_data;
	wire        frequency_inversion_granule_ch0_write_enable;
	wire  [9:0] frequency_inversion_granule_ch0_write_addr; 
	wire [17:0] frequency_inversion_granule_ch0_write_data;	

   wire  [9:0] frequency_inversion_granule_ch1_read_addr;
	wire [17:0] frequency_inversion_granule_ch1_read_data;
	wire        frequency_inversion_granule_ch1_write_enable;
	wire  [9:0] frequency_inversion_granule_ch1_write_addr; 
	wire [17:0] frequency_inversion_granule_ch1_write_data;	


	granule_buffer frequency_inversion_granule_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[5]), 

		.granule_ch0_write_enable(imdct_granule_ch0_write_enable),
		.granule_ch0_write_addr(imdct_granule_ch0_write_addr), 
		.granule_ch0_write_data(imdct_granule_ch0_write_data),
		.granule_ch0_read_addr(frequency_inversion_granule_ch0_read_addr),
		.granule_ch0_read_data(frequency_inversion_granule_ch0_read_data),	 

		.granule_ch1_write_enable(imdct_granule_ch1_write_enable),
		.granule_ch1_write_addr(imdct_granule_ch1_write_addr), 
		.granule_ch1_write_data(imdct_granule_ch1_write_data),	
		.granule_ch1_read_addr(frequency_inversion_granule_ch1_read_addr),
		.granule_ch1_read_data(frequency_inversion_granule_ch1_read_data) 
	);
	 
	 
	frequency_inversion frequency_inversion_stage(
		.clk(clk),
		.rst(rst),	 

		.granule_ch0_read_addr(frequency_inversion_granule_ch0_read_addr),
		.granule_ch0_read_data(frequency_inversion_granule_ch0_read_data), 
		.granule_ch0_write_enable(frequency_inversion_granule_ch0_write_enable),
		.granule_ch0_write_addr(frequency_inversion_granule_ch0_write_addr), 
		.granule_ch0_write_data(frequency_inversion_granule_ch0_write_data),
		
		.granule_ch1_read_addr(frequency_inversion_granule_ch1_read_addr),
		.granule_ch1_read_data(frequency_inversion_granule_ch1_read_data), 
		.granule_ch1_write_enable(frequency_inversion_granule_ch1_write_enable),
		.granule_ch1_write_addr(frequency_inversion_granule_ch1_write_addr), 
		.granule_ch1_write_data(frequency_inversion_granule_ch1_write_data), 

		.stage_ready(eventsystem_stage_ready[6]),
		.stage_done(eventsystem_stage_done[6]) 
	);	 	 


	// =======================================================================	 
	
   wire  [9:0] synthetic_filter_granule_ch0_read_addr;
	wire [17:0] synthetic_filter_granule_ch0_read_data;
	wire        synthetic_filter_granule_ch0_write_enable;
	wire  [9:0] synthetic_filter_granule_ch0_write_addr; 
	wire [17:0] synthetic_filter_granule_ch0_write_data;	

   wire  [9:0] synthetic_filter_granule_ch1_read_addr;
	wire [17:0] synthetic_filter_granule_ch1_read_data;
	wire        synthetic_filter_granule_ch1_write_enable;
	wire  [9:0] synthetic_filter_granule_ch1_write_addr; 
	wire [17:0] synthetic_filter_granule_ch1_write_data;	
	

	granule_buffer synthetic_filter_bank_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[6]), 

		.granule_ch0_write_enable(frequency_inversion_granule_ch0_write_enable),
		.granule_ch0_write_addr(frequency_inversion_granule_ch0_write_addr), 
		.granule_ch0_write_data(frequency_inversion_granule_ch0_write_data),
		.granule_ch0_read_addr(synthetic_filter_granule_ch0_read_addr),
		.granule_ch0_read_data(synthetic_filter_granule_ch0_read_data),	 

		.granule_ch1_write_enable(frequency_inversion_granule_ch1_write_enable),
		.granule_ch1_write_addr(frequency_inversion_granule_ch1_write_addr), 
		.granule_ch1_write_data(frequency_inversion_granule_ch1_write_data),	
		.granule_ch1_read_addr(synthetic_filter_granule_ch1_read_addr),
		.granule_ch1_read_data(synthetic_filter_granule_ch1_read_data)  
	);
	 
	 
	synthetic_filter_bank synthetic_filter_bank_stage(
		.clk(clk),
		.rst(rst),	 

		.granule_ch0_read_addr(synthetic_filter_granule_ch0_read_addr),
		.granule_ch0_read_data(synthetic_filter_granule_ch0_read_data), 
		.granule_ch0_write_enable(synthetic_filter_granule_ch0_write_enable),
		.granule_ch0_write_addr(synthetic_filter_granule_ch0_write_addr), 
		.granule_ch0_write_data(synthetic_filter_granule_ch0_write_data),
		
		.granule_ch1_read_addr(synthetic_filter_granule_ch1_read_addr),
		.granule_ch1_read_data(synthetic_filter_granule_ch1_read_data), 
		.granule_ch1_write_enable(synthetic_filter_granule_ch1_write_enable),
		.granule_ch1_write_addr(synthetic_filter_granule_ch1_write_addr), 
		.granule_ch1_write_data(synthetic_filter_granule_ch1_write_data), 

		.stage_ready(eventsystem_stage_ready[7]),
		.stage_done(eventsystem_stage_done[7]) 
	);	 	 


	// =======================================================================	 

	granule_buffer pcm_buffer(
		.clk(clk),
		.rst(rst),

		.buffer_switch_event(eventsystem_buffer_switch[7]),

		.granule_ch0_write_enable(synthetic_filter_granule_ch0_write_enable),
		.granule_ch0_write_addr(synthetic_filter_granule_ch0_write_addr), 
		.granule_ch0_write_data(synthetic_filter_granule_ch0_write_data),
		.granule_ch0_read_addr(pcm_read_addr),
		.granule_ch0_read_data(pcm_read_data_ch0),	 

		.granule_ch1_write_enable(synthetic_filter_granule_ch1_write_enable),
		.granule_ch1_write_addr(synthetic_filter_granule_ch1_write_addr), 
		.granule_ch1_write_data(synthetic_filter_granule_ch1_write_data),	
		.granule_ch1_read_addr(pcm_read_addr),
		.granule_ch1_read_data(pcm_read_data_ch1) 	 
	);

endmodule
