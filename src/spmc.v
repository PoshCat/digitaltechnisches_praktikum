`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:41:10 07/25/2016 
// Design Name: 
// Module Name:    spmc 
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
module spmc (
	input  wire        clk_peri,
	input	 wire [17:0] do_peri,
	output wire	[17:0] di_peri,
	input	 wire  [9:0] addr_peri,
	input  wire        access_peri,
	input  wire        wr_peri,
	input  wire        reset,
	
	input  wire        i2s_bclk,
	input  wire        i2s_ws,
	output wire        i2s_dout	
);

// ---------------------------------------------------------------------------------------

parameter [9:0] BASE_ADR	   = 10'h000;
parameter       ALL_PORTS     = 36;		   //Anzahl der Register fuer den Dekoder
parameter       DECODSIM_DEB  = "NO";		//DEBUG mode YES oder NO

wire  [ALL_PORTS-1:0] spmc_read_en;       // read ADR
wire  [ALL_PORTS-1:0] spmc_write_en;      // write ADR

reg_access_decoder #(
	.REG_COUNT(     ALL_PORTS       ),
	.BASE_ADR(      BASE_ADR        ),
	.SIM_DEBUG(     DECODSIM_DEB    )
)decod1(
	.reset(         reset           ),
	.clk_peri(      clk_peri        ),
	.addr_peri(     addr_peri       ),
	.access_peri(   access_peri     ),
	.wr_peri(       wr_peri         ),

	.peri_select(                   ),
	.reg_select(                    ),
	.reg_read(      spmc_read_en    ),
	.reg_write(     spmc_write_en   )
);

wire [17:0] spmc_write_data = do_peri;
reg  [17:0] spmc_read_data;
assign di_peri = spmc_read_data;

// =======================================================================================

wire       stage_ready;

reg        granule_ch0_write_enable;
reg  [9:0] granule_ch0_write_addr;
reg [17:0] granule_ch0_write_data;	

reg        granule_ch1_write_enable;
reg  [9:0] granule_ch1_write_addr;
reg [17:0] granule_ch1_write_data;	

reg         scalefac_ch0_short_write_enable;
reg   [1:0] scalefac_ch0_short_write_addr_window;
reg   [3:0] scalefac_ch0_short_write_addr_index;		
reg   [3:0] scalefac_ch0_short_write_data;

reg         scalefac_ch1_short_write_enable;
reg   [1:0] scalefac_ch1_short_write_addr_window;
reg   [3:0] scalefac_ch1_short_write_addr_index;		
reg   [3:0] scalefac_ch1_short_write_data;

reg         scalefac_ch0_long_write_enable;
reg   [5:0] scalefac_ch0_long_write_addr;
reg   [3:0] scalefac_ch0_long_write_data;

reg         scalefac_ch1_long_write_enable;
reg   [5:0] scalefac_ch1_long_write_addr;
reg   [3:0] scalefac_ch1_long_write_data;


// ===========================================

wire [9:0]  pcm_read_addr;
wire [17:0] pcm_read_data_ch0;
wire [17:0] pcm_read_data_ch1;

wire        pcm_ready;
wire        pcm_done;

// ===========================================


decoding_chain chain(
		.clk(clk_peri),
		.rst(reset),

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

		.header_mode(spmc_write_data[1:0]),
		.header_mode_we(spmc_write_en[14]),
		
		.header_mode_extension(spmc_write_data[1:0]),
		.header_mode_extension_we(spmc_write_en[15]),
		
		.header_sampling_frequency(spmc_write_data[1:0]),
		.header_sampling_frequency_we(spmc_write_en[16]),
		
		// -------------------------------------------		
		
		.sideinfo_ch0_global_gain(spmc_write_data[7:0]),
		.sideinfo_ch0_global_gain_we(spmc_write_en[17]),		

		.sideinfo_ch0_window_switching_flag(spmc_write_data[0]),
		.sideinfo_ch0_window_switching_flag_we(spmc_write_en[18]),
		
		.sideinfo_ch0_block_type(spmc_write_data[1:0]),
		.sideinfo_ch0_block_type_we(spmc_write_en[19]),
		
		.sideinfo_ch0_mixed_block_flag(spmc_write_data[0]),
		.sideinfo_ch0_mixed_block_flag_we(spmc_write_en[20]),
		
		.sideinfo_ch0_preflag(spmc_write_data[0]),
		.sideinfo_ch0_preflag_we(spmc_write_en[21]),		

		.sideinfo_ch0_scalefac_scale(spmc_write_data[0]),
		.sideinfo_ch0_scalefac_scale_we(spmc_write_en[22]),

		.sideinfo_ch0_subblock_gain_window0(spmc_write_data[2:0]),
		.sideinfo_ch0_subblock_gain_window0_we(spmc_write_en[23]),		

		.sideinfo_ch0_subblock_gain_window1(spmc_write_data[2:0]),
		.sideinfo_ch0_subblock_gain_window1_we(spmc_write_en[24]),
		
		.sideinfo_ch0_subblock_gain_window2(spmc_write_data[2:0]),
		.sideinfo_ch0_subblock_gain_window2_we(spmc_write_en[25]),

		// -------------------------------------------

		.sideinfo_ch1_global_gain(spmc_write_data[7:0]),
		.sideinfo_ch1_global_gain_we(spmc_write_en[26]),		

		.sideinfo_ch1_window_switching_flag(spmc_write_data[0]),
		.sideinfo_ch1_window_switching_flag_we(spmc_write_en[27]),
		
		.sideinfo_ch1_block_type(spmc_write_data[1:0]),
		.sideinfo_ch1_block_type_we(spmc_write_en[28]),
		
		.sideinfo_ch1_mixed_block_flag(spmc_write_data[0]),
		.sideinfo_ch1_mixed_block_flag_we(spmc_write_en[29]),
		
		.sideinfo_ch1_preflag(spmc_write_data[0]),
		.sideinfo_ch1_preflag_we(spmc_write_en[30]),		

		.sideinfo_ch1_scalefac_scale(spmc_write_data[0]),
		.sideinfo_ch1_scalefac_scale_we(spmc_write_en[31]),

		.sideinfo_ch1_subblock_gain_window0(spmc_write_data[2:0]),
		.sideinfo_ch1_subblock_gain_window0_we(spmc_write_en[32]),		

		.sideinfo_ch1_subblock_gain_window1(spmc_write_data[2:0]),
		.sideinfo_ch1_subblock_gain_window1_we(spmc_write_en[33]),
		
		.sideinfo_ch1_subblock_gain_window2(spmc_write_data[2:0]),
		.sideinfo_ch1_subblock_gain_window2_we(spmc_write_en[34]),

		// -------------------------------------------

		.stage_ready(stage_ready),
		.stage_done(spmc_write_en[35]),

		// -------------------------------------------

		.pcm_read_addr(pcm_read_addr),
		.pcm_read_data_ch0(pcm_read_data_ch0),
		.pcm_read_data_ch1(pcm_read_data_ch1),

		.pcm_ready(pcm_ready),
		.pcm_done(pcm_done)

		// -------------------------------------------
    );


	always @(posedge clk_peri) begin
		if(reset) begin
			granule_ch0_write_addr   <= 0;
			granule_ch0_write_data   <= 0; 
			granule_ch0_write_enable <= 0;
			
			granule_ch1_write_addr   <= 0;
			granule_ch1_write_data   <= 0; 
			granule_ch1_write_enable <= 0;
	
			scalefac_ch0_short_write_addr_window <= 0;
			scalefac_ch0_short_write_addr_index  <= 0;
			scalefac_ch0_short_write_data        <= 0;
			scalefac_ch0_short_write_enable      <= 0;

			scalefac_ch1_short_write_addr_window <= 0;
			scalefac_ch1_short_write_addr_index  <= 0;
			scalefac_ch1_short_write_data        <= 0;
			scalefac_ch1_short_write_enable      <= 0;

			scalefac_ch0_long_write_addr         <= 0;
			scalefac_ch0_long_write_data         <= 0;
			scalefac_ch0_long_write_enable       <= 0;
			
			scalefac_ch1_long_write_addr         <= 0;
			scalefac_ch1_long_write_data         <= 0;
			scalefac_ch1_long_write_enable       <= 0;
		end
		else begin
			granule_ch0_write_enable             <= 0;
			granule_ch1_write_enable             <= 0;
			scalefac_ch0_short_write_enable      <= 0;		
			scalefac_ch1_short_write_enable      <= 0;
			scalefac_ch0_long_write_enable       <= 0;
			scalefac_ch1_long_write_enable       <= 0;
	
			case(spmc_write_en)
				(1 <<  0): granule_ch0_write_addr <= do_peri[9:0];
				(1 <<  1): begin
				           granule_ch0_write_data <= do_peri;
							  granule_ch0_write_enable <= 1'b1;
							  end
							  
				(1 <<  2): granule_ch1_write_addr <= do_peri[9:0];
				(1 <<  3): begin
				           granule_ch1_write_data <= do_peri;
							  granule_ch1_write_enable <= 1'b1;
							  end	
							  
				(1 <<  4): scalefac_ch0_short_write_addr_window <= do_peri[1:0];
				(1 <<  5): scalefac_ch0_short_write_addr_index  <= do_peri[3:0];
				(1 <<  6): begin 
				            scalefac_ch0_short_write_data       <= do_peri[3:0];
                        scalefac_ch0_short_write_enable     <= 1'b1;
								end							  
							  
				(1 <<  7): scalefac_ch1_short_write_addr_window <= do_peri[1:0];
				(1 <<  8): scalefac_ch1_short_write_addr_index  <= do_peri[3:0];
				(1 <<  9): begin 
				            scalefac_ch1_short_write_data       <= do_peri[3:0];
                        scalefac_ch1_short_write_enable     <= 1'b1;
								end								  
							  
				(1 << 10): scalefac_ch0_long_write_addr         <= do_peri[5:0];
				(1 << 11): begin 
				            scalefac_ch0_long_write_data        <= do_peri[3:0];
                        scalefac_ch0_long_write_enable      <= 1'b1;
								end	

				(1 << 12): scalefac_ch1_long_write_addr         <= do_peri[5:0];
				(1 << 13): begin 
				            scalefac_ch1_long_write_data        <= do_peri[3:0];
                        scalefac_ch1_long_write_enable      <= 1'b1;
								end
			endcase
		end
	end


	reg stage_ready_flag;

	always @(posedge clk_peri) begin
		if(reset) begin
			stage_ready_flag <= 0;
		end
		else begin
			if(stage_ready) begin
				stage_ready_flag <= 1'b1;
			end else begin
				//Only clear the flag if it's not just being set.
				if(spmc_read_en[35]) begin
					stage_ready_flag <= 1'b0;
				end
			end
		end
	end

	always @(*) begin
		case(spmc_read_en)
			(1 << 35): spmc_read_data = stage_ready_flag;
			default:  spmc_read_data = 18'h00000;
		endcase
	end


// =======================================================================================


	i2s_stage i2s (
		.clk(clk_peri), 
		.rst(reset),
		
		.pcm_read_addr(pcm_read_addr), 
		.pcm_read_data_ch0(pcm_read_data_ch0), 
		.pcm_read_data_ch1(pcm_read_data_ch1),
		
		.stage_ready(pcm_ready), 
		.stage_done(pcm_done),
		
		.i2s_bclk(i2s_bclk), 
		.i2s_ws(i2s_ws), 
		.i2s_dout(i2s_dout)
	);

endmodule
