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


module decoding_chain (
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

		input wire [1:0] header_mode,
		input wire       header_mode_we,
		
		input wire [1:0] header_mode_extension,
		input wire       header_mode_extension_we,
		
		input wire [1:0] header_sampling_frequency,
		input wire       header_sampling_frequency_we,
		
		// -------------------------------------------
		
		input wire [7:0] sideinfo_ch0_global_gain,
		input wire       sideinfo_ch0_global_gain_we,		

		input wire       sideinfo_ch0_window_switching_flag,
		input wire       sideinfo_ch0_window_switching_flag_we,
		
		input wire [1:0] sideinfo_ch0_block_type,
		input wire       sideinfo_ch0_block_type_we,
		
		input wire       sideinfo_ch0_mixed_block_flag,
		input wire       sideinfo_ch0_mixed_block_flag_we,
		
		input wire       sideinfo_ch0_preflag,
		input wire       sideinfo_ch0_preflag_we,		

		input wire       sideinfo_ch0_scalefac_scale,
		input wire       sideinfo_ch0_scalefac_scale_we,

		input wire [2:0] sideinfo_ch0_subblock_gain_window0,
		input wire       sideinfo_ch0_subblock_gain_window0_we,		

		input wire [2:0] sideinfo_ch0_subblock_gain_window1,
		input wire       sideinfo_ch0_subblock_gain_window1_we,
		
		input wire [2:0] sideinfo_ch0_subblock_gain_window2,
		input wire       sideinfo_ch0_subblock_gain_window2_we,	
		
		// -------------------------------------------		
		
		input wire [7:0] sideinfo_ch1_global_gain,
		input wire       sideinfo_ch1_global_gain_we,		

		input wire       sideinfo_ch1_window_switching_flag,
		input wire       sideinfo_ch1_window_switching_flag_we,
		
		input wire [1:0] sideinfo_ch1_block_type,
		input wire       sideinfo_ch1_block_type_we,
		
		input wire       sideinfo_ch1_mixed_block_flag,
		input wire       sideinfo_ch1_mixed_block_flag_we,
		
		input wire       sideinfo_ch1_preflag,
		input wire       sideinfo_ch1_preflag_we,		

		input wire       sideinfo_ch1_scalefac_scale,
		input wire       sideinfo_ch1_scalefac_scale_we,

		input wire [2:0] sideinfo_ch1_subblock_gain_window0,
		input wire       sideinfo_ch1_subblock_gain_window0_we,		

		input wire [2:0] sideinfo_ch1_subblock_gain_window1,
		input wire       sideinfo_ch1_subblock_gain_window1_we,
		
		input wire [2:0] sideinfo_ch1_subblock_gain_window2,
		input wire       sideinfo_ch1_subblock_gain_window2_we,			
		
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
	
	wire [`PARAMETER_WIDTH-1:0] parameter_data;
	
	buffer #(
		.DATA_WIDTH(2)
	) parameter_header_mode_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(header_mode_we), 
	 
		.data_in(header_mode),
		.data_out(`header_mode(parameter_data))
	);	
	
	buffer #(
		.DATA_WIDTH(2)
	) parameter_header_mode_extension_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(header_mode_extension_we), 
	 
		.data_in(header_mode_extension),
		.data_out(`header_mode_extension(parameter_data))
	);	
		
	buffer #(
		.DATA_WIDTH(2)
	) parameter_header_sampling_frequency_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(header_sampling_frequency_we), 
	 
		.data_in(header_sampling_frequency),
		.data_out(`header_sampling_frequency(parameter_data))
	);		
	
	// ---------------------------------------------------------	
	
	buffer #(
		.DATA_WIDTH(8)
	) parameter_sideinfo_ch0_global_gain_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_global_gain_we), 
	 
		.data_in(sideinfo_ch0_global_gain),
		.data_out(`sideinfo_ch0_global_gain(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch0_window_switching_flag_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_window_switching_flag_we), 
	 
		.data_in(sideinfo_ch0_window_switching_flag),
		.data_out(`sideinfo_ch0_window_switching_flag(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(2)
	) parameter_sideinfo_ch0_block_type_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_block_type_we), 
	 
		.data_in(sideinfo_ch0_block_type),
		.data_out(`sideinfo_ch0_block_type(parameter_data))
	);
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch0_mixed_block_flag_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_mixed_block_flag_we), 
	 
		.data_in(sideinfo_ch0_mixed_block_flag),
		.data_out(`sideinfo_ch0_mixed_block_flag(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch0_preflag_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_preflag_we), 
	 
		.data_in(sideinfo_ch0_preflag),
		.data_out(`sideinfo_ch0_preflag(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch0_scalefac_scale_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_scalefac_scale_we), 
	 
		.data_in(sideinfo_ch0_scalefac_scale),
		.data_out(`sideinfo_ch0_scalefac_scale(parameter_data))
	);		

	buffer #(
		.DATA_WIDTH(3)
	) parameter_sideinfo_ch0_subblock_gain_window0_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_subblock_gain_window0_we), 
	 
		.data_in(sideinfo_ch0_subblock_gain_window0),
		.data_out(`sideinfo_ch0_subblock_gain_window0(parameter_data))
	);		

	buffer #(
		.DATA_WIDTH(3)
	) parameter_sideinfo_ch0_subblock_gain_window1_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_subblock_gain_window1_we), 
	 
		.data_in(sideinfo_ch0_subblock_gain_window1),
		.data_out(`sideinfo_ch0_subblock_gain_window1(parameter_data))
	);

	buffer #(
		.DATA_WIDTH(3)
	) parameter_sideinfo_ch0_subblock_gain_window2_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch0_subblock_gain_window2_we), 
	 
		.data_in(sideinfo_ch0_subblock_gain_window2),
		.data_out(`sideinfo_ch0_subblock_gain_window2(parameter_data))
	);			

	// ---------------------------------------------------------	

	buffer #(
		.DATA_WIDTH(8)
	) parameter_sideinfo_ch1_global_gain_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_global_gain_we), 
	 
		.data_in(sideinfo_ch1_global_gain),
		.data_out(`sideinfo_ch1_global_gain(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch1_window_switching_flag_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_window_switching_flag_we), 
	 
		.data_in(sideinfo_ch1_window_switching_flag),
		.data_out(`sideinfo_ch1_window_switching_flag(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(2)
	) parameter_sideinfo_ch1_block_type_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_block_type_we), 
	 
		.data_in(sideinfo_ch1_block_type),
		.data_out(`sideinfo_ch1_block_type(parameter_data))
	);
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch1_mixed_block_flag_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_mixed_block_flag_we), 
	 
		.data_in(sideinfo_ch1_mixed_block_flag),
		.data_out(`sideinfo_ch1_mixed_block_flag(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch1_preflag_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_preflag_we), 
	 
		.data_in(sideinfo_ch1_preflag),
		.data_out(`sideinfo_ch1_preflag(parameter_data))
	);		
	
	buffer #(
		.DATA_WIDTH(1)
	) parameter_sideinfo_ch1_scalefac_scale_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_scalefac_scale_we), 
	 
		.data_in(sideinfo_ch1_scalefac_scale),
		.data_out(`sideinfo_ch1_scalefac_scale(parameter_data))
	);		

	buffer #(
		.DATA_WIDTH(3)
	) parameter_sideinfo_ch1_subblock_gain_window0_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_subblock_gain_window0_we), 
	 
		.data_in(sideinfo_ch1_subblock_gain_window0),
		.data_out(`sideinfo_ch1_subblock_gain_window0(parameter_data))
	);		

	buffer #(
		.DATA_WIDTH(3)
	) parameter_sideinfo_ch1_subblock_gain_window1_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_subblock_gain_window1_we), 
	 
		.data_in(sideinfo_ch1_subblock_gain_window1),
		.data_out(`sideinfo_ch1_subblock_gain_window1(parameter_data))
	);

	buffer #(
		.DATA_WIDTH(3)
	) parameter_sideinfo_ch1_subblock_gain_window2_buffer(
		.clk(clk),
		.rst(rst),	
	
		.buffer_assign_event(sideinfo_ch1_subblock_gain_window2_we), 
	 
		.data_in(sideinfo_ch1_subblock_gain_window2),
		.data_out(`sideinfo_ch1_subblock_gain_window2(parameter_data))
	);			


	// ---------------------------------------------------------	


	reg stage_done_d1;
	
	always @(posedge clk) begin
		if(rst) begin
			stage_done_d1 <= 0;
		end
		else begin
			stage_done_d1 <= stage_done;
		end
	end
	

	decoding_chain_parameter decoding_chain_parameter(
		.clk(clk),
		.rst(rst),

		// -------------------------------------------

		.granule_ch0_write_enable(granule_ch0_write_enable),
		.granule_ch0_write_addr(granule_ch0_write_addr),
		.granule_ch0_write_data(granule_ch0_write_data),	

		.granule_ch1_write_enable(granule_ch1_write_enable),
		.granule_ch1_write_addr(granule_ch1_write_addr),
		.granule_ch1_write_data(granule_ch1_write_data),	

		// -------------------------------------------

		.scalefac_ch0_short_write_enable(scalefac_ch0_short_write_enable),
		.scalefac_ch0_short_write_addr_window(scalefac_ch0_short_write_addr_window),
		.scalefac_ch0_short_write_addr_index(scalefac_ch0_short_write_addr_index),		
		.scalefac_ch0_short_write_data(scalefac_ch0_short_write_data),

		.scalefac_ch1_short_write_enable(scalefac_ch1_short_write_enable),
		.scalefac_ch1_short_write_addr_window(scalefac_ch1_short_write_addr_window),
		.scalefac_ch1_short_write_addr_index(scalefac_ch1_short_write_addr_index),		
		.scalefac_ch1_short_write_data(scalefac_ch1_short_write_data),

		.scalefac_ch0_long_write_enable(scalefac_ch0_long_write_enable),
		.scalefac_ch0_long_write_addr(scalefac_ch0_long_write_addr),	
		.scalefac_ch0_long_write_data(scalefac_ch0_long_write_data),

		.scalefac_ch1_long_write_enable(scalefac_ch1_long_write_enable),
		.scalefac_ch1_long_write_addr(scalefac_ch1_long_write_addr),	
		.scalefac_ch1_long_write_data(scalefac_ch1_long_write_data),

		// -------------------------------------------

		.parameter_enable(stage_done),
		.parameter_data(parameter_data),

		// -------------------------------------------

		.stage_ready(stage_ready),
		.stage_done(stage_done_d1),

		// -------------------------------------------

		.pcm_read_addr(pcm_read_addr),
		.pcm_read_data_ch0(pcm_read_data_ch0),
		.pcm_read_data_ch1(pcm_read_data_ch1),

		.pcm_ready(pcm_ready),
		.pcm_done(pcm_done)

		// -------------------------------------------
	);

endmodule
