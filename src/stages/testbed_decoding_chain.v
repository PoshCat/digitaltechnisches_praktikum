`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:14:47 07/28/2016
// Design Name:   decoding_chain
// Module Name:   /home/dreyer/Dokumente/Digitaltechnisches_Praktikum/git/implementierung/ise/boombox/testbed_decoding_chain.v
// Project Name:  boombox
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: decoding_chain
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`include "mp3_parameter.vh"

`define REQUANTIZE_REFERENCE_VECTOR_PREFIX "../../../mp3_module/src/stages/requantize/testbed/testbed_requantize_"
`define SYNTHETHIC_FILTER_BANK_VECTOR_PREFIX "../../../mp3_module/src/stages/synthetic_filter_bank/testbed/testbed_synthetic_filter_bank_"


module testbed_decoding_chain#(
	parameter GRANULES = 100,
  parameter GRANULE_OFFSET = 8 // synthetic_filter_bank: 8, frequency_inversion: 7, imdct: 6, alias_reduction: 5, stereo: 4, reorder: 3, requantize: 2
);

	reg 			clk;
	reg 			rst;
	
	reg 			granule_write_enable;
	reg [9:0] 	granule_write_addr;
	reg [17:0]	granule_write_data_ch0;
	reg [17:0]	granule_write_data_ch1;
	
	reg 			scalefac_short_write_enable;
	reg [1:0] 	scalefac_short_write_addr_window;
	reg [3:0] 	scalefac_short_write_addr_index;
	reg [3:0] 	scalefac_short_write_data_ch0;
	reg [3:0] 	scalefac_short_write_data_ch1;

	reg 			scalefac_long_write_enable;
	reg [5:0] 	scalefac_long_write_addr;
	reg [3:0] 	scalefac_long_write_data_ch0;
	reg [3:0] 	scalefac_long_write_data_ch1;

	reg 			stage_done;
	wire 			stage_ready;	
	
	reg 			pcm_done;
	wire 			pcm_ready;

	reg [9:0] 	pcm_read_addr;
	wire [17:0] pcm_read_data_ch0;
	wire [17:0] pcm_read_data_ch1;



	reg parameter_we;
	reg [`PARAMETER_WIDTH-1:0] parameter_data;


	// Instantiate the Unit Under Test (UUT)
	decoding_chain uut (
		.clk(clk), 
		.rst(rst), 
		
		.granule_ch0_write_enable(granule_write_enable),
		.granule_ch0_write_addr(granule_write_addr),
		.granule_ch0_write_data(granule_write_data_ch0),	

		.granule_ch1_write_enable(granule_write_enable),
		.granule_ch1_write_addr(granule_write_addr),
		.granule_ch1_write_data(granule_write_data_ch1),	

		.scalefac_ch0_short_write_enable(scalefac_short_write_enable),
		.scalefac_ch0_short_write_addr_window(scalefac_short_write_addr_window),
		.scalefac_ch0_short_write_addr_index(scalefac_short_write_addr_index),		
		.scalefac_ch0_short_write_data(scalefac_short_write_data_ch0),

		.scalefac_ch1_short_write_enable(scalefac_short_write_enable),
		.scalefac_ch1_short_write_addr_window(scalefac_short_write_addr_window),
		.scalefac_ch1_short_write_addr_index(scalefac_short_write_addr_index),		
		.scalefac_ch1_short_write_data(scalefac_short_write_data_ch1),

		.scalefac_ch0_long_write_enable(scalefac_long_write_enable),
		.scalefac_ch0_long_write_addr(scalefac_long_write_addr),	
		.scalefac_ch0_long_write_data(scalefac_long_write_data_ch0),

		.scalefac_ch1_long_write_enable(scalefac_long_write_enable),
		.scalefac_ch1_long_write_addr(scalefac_long_write_addr),	
		.scalefac_ch1_long_write_data(scalefac_long_write_data_ch1),
		
		.header_mode(`header_mode(parameter_data)), 
		.header_mode_we(parameter_we), 
		.header_mode_extension(`header_mode_extension(parameter_data)), 
		.header_mode_extension_we(parameter_we), 
		.header_sampling_frequency(`header_sampling_frequency(parameter_data)), 
		.header_sampling_frequency_we(parameter_we),
		
		.sideinfo_ch0_global_gain(`sideinfo_ch0_global_gain(parameter_data)), 
		.sideinfo_ch0_global_gain_we(parameter_we), 
		.sideinfo_ch0_window_switching_flag(`sideinfo_ch0_window_switching_flag(parameter_data)), 
		.sideinfo_ch0_window_switching_flag_we(parameter_we), 
		.sideinfo_ch0_block_type(`sideinfo_ch0_block_type(parameter_data)), 
		.sideinfo_ch0_block_type_we(parameter_we), 
		.sideinfo_ch0_mixed_block_flag(`sideinfo_ch0_mixed_block_flag(parameter_data)), 
		.sideinfo_ch0_mixed_block_flag_we(parameter_we), 
		.sideinfo_ch0_preflag(`sideinfo_ch0_preflag(parameter_data)), 
		.sideinfo_ch0_preflag_we(parameter_we), 
		.sideinfo_ch0_scalefac_scale(`sideinfo_ch0_scalefac_scale(parameter_data)), 
		.sideinfo_ch0_scalefac_scale_we(parameter_we), 
		.sideinfo_ch0_subblock_gain_window0(`sideinfo_ch0_subblock_gain_window0(parameter_data)), 
		.sideinfo_ch0_subblock_gain_window0_we(parameter_we), 
		.sideinfo_ch0_subblock_gain_window1(`sideinfo_ch0_subblock_gain_window1(parameter_data)), 
		.sideinfo_ch0_subblock_gain_window1_we(parameter_we), 
		.sideinfo_ch0_subblock_gain_window2(`sideinfo_ch0_subblock_gain_window2(parameter_data)), 
		.sideinfo_ch0_subblock_gain_window2_we(parameter_we),
		
		.sideinfo_ch1_global_gain(`sideinfo_ch1_global_gain(parameter_data)), 
		.sideinfo_ch1_global_gain_we(parameter_we), 
		.sideinfo_ch1_window_switching_flag(`sideinfo_ch1_window_switching_flag(parameter_data)), 
		.sideinfo_ch1_window_switching_flag_we(parameter_we), 
		.sideinfo_ch1_block_type(`sideinfo_ch1_block_type(parameter_data)), 
		.sideinfo_ch1_block_type_we(parameter_we), 
		.sideinfo_ch1_mixed_block_flag(`sideinfo_ch1_mixed_block_flag(parameter_data)), 
		.sideinfo_ch1_mixed_block_flag_we(parameter_we), 
		.sideinfo_ch1_preflag(`sideinfo_ch1_preflag(parameter_data)), 
		.sideinfo_ch1_preflag_we(parameter_we), 
		.sideinfo_ch1_scalefac_scale(`sideinfo_ch1_scalefac_scale(parameter_data)), 
		.sideinfo_ch1_scalefac_scale_we(parameter_we), 
		.sideinfo_ch1_subblock_gain_window0(`sideinfo_ch1_subblock_gain_window0(parameter_data)), 
		.sideinfo_ch1_subblock_gain_window0_we(parameter_we), 
		.sideinfo_ch1_subblock_gain_window1(`sideinfo_ch1_subblock_gain_window1(parameter_data)), 
		.sideinfo_ch1_subblock_gain_window1_we(parameter_we), 
		.sideinfo_ch1_subblock_gain_window2(`sideinfo_ch1_subblock_gain_window2(parameter_data)), 
		.sideinfo_ch1_subblock_gain_window2_we(parameter_we),
		
		.stage_ready(stage_ready), 
		.stage_done(stage_done),
		
		.pcm_read_addr(pcm_read_addr), 
		.pcm_read_data_ch0(pcm_read_data_ch0), 
		.pcm_read_data_ch1(pcm_read_data_ch1), 
		.pcm_ready(pcm_ready), 
		.pcm_done(pcm_done)
	);


   initial begin
      clk = 0;
      while(1)
         #10 clk = !clk;
   end


// ====================================================================================================================
// Test & compare values
// --------------------------------------------------------------------------------------------------------------------

	reg [`PARAMETER_WIDTH-1:0] parameter_input_vector[GRANULES-1:0];
	
	reg [17:0] granule_ch0_input_vector   [GRANULES*576-1:0];
	reg [17:0] granule_ch0_compair_vector [GRANULES*576-1:0];
	
	reg [17:0] granule_ch1_input_vector   [GRANULES*576-1:0];	
	reg [17:0] granule_ch1_compair_vector [GRANULES*576-1:0];
	
	reg  [3:0] scalfac_short_ch0_input_vector [GRANULES*39-1:0];
	reg  [3:0] scalfac_short_ch1_input_vector [GRANULES*39-1:0];

	reg  [3:0] scalfac_long_ch0_input_vector [GRANULES*23-1:0];
	reg  [3:0] scalfac_long_ch1_input_vector [GRANULES*23-1:0];	
	
	
	initial begin
		$readmemh({`REQUANTIZE_REFERENCE_VECTOR_PREFIX, "parameter.txt"},             parameter_input_vector,     0, GRANULES-1);

		$readmemh({`REQUANTIZE_REFERENCE_VECTOR_PREFIX,   "granule_ch0_input.txt"},   granule_ch0_input_vector,   0, GRANULES*576-1);	
		$readmemh({`SYNTHETHIC_FILTER_BANK_VECTOR_PREFIX, "granule_ch0_compare.txt"}, granule_ch0_compair_vector, 0, GRANULES*576-1);		
		$readmemh({`REQUANTIZE_REFERENCE_VECTOR_PREFIX,   "granule_ch1_input.txt"},   granule_ch1_input_vector,   0, GRANULES*576-1);	
		$readmemh({`SYNTHETHIC_FILTER_BANK_VECTOR_PREFIX, "granule_ch1_compare.txt"}, granule_ch1_compair_vector, 0, GRANULES*576-1);				

		$readmemh({`REQUANTIZE_REFERENCE_VECTOR_PREFIX, "scalefac_short_ch0.txt"},    scalfac_short_ch0_input_vector, 0, GRANULES*39-1);	
		$readmemh({`REQUANTIZE_REFERENCE_VECTOR_PREFIX, "scalefac_long_ch0.txt"},     scalfac_long_ch0_input_vector,  0, GRANULES*23-1);				

		$readmemh({`REQUANTIZE_REFERENCE_VECTOR_PREFIX, "scalefac_short_ch1.txt"},    scalfac_short_ch1_input_vector, 0, GRANULES*39-1);	
		$readmemh({`REQUANTIZE_REFERENCE_VECTOR_PREFIX, "scalefac_long_ch1.txt"},     scalfac_long_ch1_input_vector,  0, GRANULES*23-1);				

		rst = 1;
		#111;
		rst = 0;
	end


// ====================================================================================================================



	localparam
		STATE_INPUT_IDLE = 0,
		STATE_INPUT_COPY_PARAMETER = 1,
		STATE_INPUT_COPY_GRANULE = 2,
		STATE_INPUT_COPY_SCALEFAC_SHORT = 3,
		STATE_INPUT_COPY_SCALEFAC_LONG = 4,		
		STATE_INPUT_DONE = 5;

	reg   [3:0] state_input;  


	integer granule;
	integer index;
	integer window;

	always @(posedge clk) begin
		if(rst) begin
			granule <= 0;
			stage_done <= 0;
		
			parameter_we <= 0;
			granule_write_enable <= 0;
			scalefac_long_write_enable <= 0;
			scalefac_short_write_enable <= 0;
		end
		else begin
			stage_done <= 0;
			parameter_we <= 0;
			granule_write_enable <= 0;
			scalefac_long_write_enable <= 0;
			scalefac_short_write_enable <= 0;

			case(state_input)
				STATE_INPUT_IDLE: begin
					if(stage_ready) begin
						state_input <= STATE_INPUT_COPY_PARAMETER;
					end
				end
				
				STATE_INPUT_COPY_PARAMETER: begin			
					parameter_data <= parameter_input_vector[granule];
					parameter_we   <= 1'b1;

					index <= 0;				
					state_input <= STATE_INPUT_COPY_GRANULE;
				end
				
				STATE_INPUT_COPY_GRANULE: begin
					granule_write_enable   <= 1;
					granule_write_addr     <= index;
					granule_write_data_ch0 <= granule_ch0_input_vector[granule*576+index];
					granule_write_data_ch1 <= granule_ch1_input_vector[granule*576+index];					

					index <= index + 1;
								
					if(index == 575) begin
						index <= 0;									
						state_input <= STATE_INPUT_COPY_SCALEFAC_LONG;
					end
				end
				
				STATE_INPUT_COPY_SCALEFAC_LONG: begin
					scalefac_long_write_enable   <= 1'b1;
					scalefac_long_write_addr     <= index;
					scalefac_long_write_data_ch0 <= scalfac_long_ch0_input_vector[granule*23 + index];
					scalefac_long_write_data_ch1 <= scalfac_long_ch1_input_vector[granule*23 + index];

					index <= index + 1;
					
					if(index == 22) begin
						index <= 0;
						window <= 0;
						state_input <= STATE_INPUT_COPY_SCALEFAC_SHORT;
					end
				end				
				
				STATE_INPUT_COPY_SCALEFAC_SHORT: begin
					scalefac_short_write_enable      <= 1'b1;
					scalefac_short_write_addr_window <= window;
					scalefac_short_write_addr_index  <= index;
					scalefac_short_write_data_ch0    <= scalfac_short_ch0_input_vector[granule*39 + 13*window + index];
					scalefac_short_write_data_ch1    <= scalfac_short_ch1_input_vector[granule*39 + 13*window + index];				

					index <= index + 1;
					
					if(index == 12) begin
						index <= 0;
						window <= window + 1;
					end
					
					if(index == 12 && window == 2) begin
						state_input <= STATE_INPUT_DONE;
					end
				end
				
				STATE_INPUT_DONE: begin
					granule <= granule + 1'b1;
					stage_done <= 1'b1;
					state_input <= STATE_INPUT_IDLE;
				end
				
				default: begin
					state_input <= STATE_INPUT_IDLE;
				end
			endcase
		end
	end


// ====================================================================================================================

	integer granules_skipped;


	localparam
		STATE_COMPARE_IDLE = 0,
		STATE_COMPARE_SKIP = 1,
		STATE_COMPARE_READ1 = 2,
		STATE_COMPARE_READ2 = 3,
		STATE_COMPARE_TEST = 4,
		STATE_COMPARE_DONE = 5;

	reg   [3:0] state_compare;  

	integer index_compare;
	integer granule_compare;

	always @(posedge clk) begin
		if(rst) begin
			index_compare <= 0;
			state_compare <= STATE_COMPARE_SKIP;
			granule_compare <= 0;
		
			pcm_done <= 0;
			
			granules_skipped <= 0;
			
		end
		else begin
			pcm_done <= 0;

			case(state_compare)
				STATE_COMPARE_SKIP: begin
					if(pcm_ready) begin
						if(granules_skipped < GRANULE_OFFSET) begin
							pcm_done <= 1;
							granules_skipped <= granules_skipped + 1;
						end
				
						if(granules_skipped == GRANULE_OFFSET) begin		
							state_compare <= STATE_COMPARE_READ1;
							index_compare <= 0;							
						end		
					end
				end
			
			
				STATE_COMPARE_IDLE: begin
					if(pcm_ready) begin
						state_compare <= STATE_COMPARE_READ1;
						index_compare <= 0;
					end
				end
				

				STATE_COMPARE_READ1: begin
					pcm_read_addr <= index_compare;
					index_compare <= index_compare + 1;
					
					state_compare <= STATE_COMPARE_READ2;
				end
				
				STATE_COMPARE_READ2: begin
					pcm_read_addr <= index_compare;
					index_compare <= index_compare + 1;
					
					state_compare <= STATE_COMPARE_TEST;
				end				


				STATE_COMPARE_TEST: begin
					pcm_read_addr <= index_compare;
				
					if(pcm_read_data_ch0 !== granule_ch0_compair_vector[576*granule_compare+index_compare-2]) begin
							$display("TESTBENCH WARNING: granule %3d, channel 0, index %3d: expected value 0x%x, written 0x%x",
								granule_compare,
								index_compare-2, 
								granule_ch0_compair_vector[576*granule_compare+index_compare-2], 
								pcm_read_data_ch0);						
					end
					
					if(pcm_read_data_ch1 !== granule_ch1_compair_vector[576*granule_compare+index_compare-2]) begin
							$display("TESTBENCH WARNING: granule %3d, channel 1, index %3d: expected value 0x%x, written 0x%x",
								granule_compare,
								index_compare-2, 
								granule_ch1_compair_vector[576*granule_compare+index_compare-2], 
								pcm_read_data_ch1);								
					end

					index_compare <= index_compare + 1;

					if(index_compare == 577) begin
						state_compare <= STATE_COMPARE_DONE;
					end
				end				
		
				STATE_COMPARE_DONE: begin
					granule_compare <= granule_compare + 1;
					
					if(granule_compare == GRANULES-1) begin
						$stop;
					end
					
					pcm_done <= 1'b1;
					state_compare <= STATE_INPUT_IDLE;
				end					
			endcase
		end
	end

endmodule
