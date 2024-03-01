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
module requantize_channel (
    input  wire clk,
    input  wire rst,	 
	 
// ==================================================
// 576 lines
// --------------------------------------------------	 
	 
	 output wire  [9:0] granule_read_addr,
	 input  wire [17:0] granule_read_data,	 

	 output wire        granule_write_enable,
	 output wire  [9:0] granule_write_addr, 
	 output wire [17:0] granule_write_data, 
	 
// ==================================================
// scale factors
// --------------------------------------------------	  	 

	 output wire  [1:0] scalfac_short_read_addr_window,
	 output wire  [3:0] scalfac_short_read_addr_index,			 
	 input  wire  [3:0] scalfac_short_read_data,
	 
	 output wire  [5:0] scalfac_long_read_addr,
	 input  wire  [3:0] scalfac_long_read_data,

// ==================================================
// header information
// --------------------------------------------------	  
	 
	 input  wire  [1:0] header_sampling_frequency,
	 
// ==================================================
// sideinfo information
// --------------------------------------------------	  
	 
	 input  wire        sideinfo_scalefac_scale,
	 
	 input  wire  [1:0] sideinfo_block_type,
	 input  wire        sideinfo_window_switching_flag,
	 input  wire        sideinfo_mixed_block_flag,	 
	 
	 input  wire        sideinfo_preflag,
	 
	 input  wire  [7:0] sideinfo_global_gain,
	 input  wire  [2:0] sideinfo_subblock_gain_window0,
	 input  wire  [2:0] sideinfo_subblock_gain_window1,
	 input  wire  [2:0] sideinfo_subblock_gain_window2, 	 
	 
// ==================================================
// stage signaling
// --------------------------------------------------	
	 
     input  wire       channel_ready,
     output reg        channel_done
    );
	 
	 
	// This module consists of two parts. The first part is a state machine
	// which executes loops and increments the address according to the block
	// mode. The second part is a sub module which executes all arithmetic
	// calculations.
	 
	// states
	localparam
		STATE_IDLE = 0,
		STATE_LONG_OUTER_LOOP_INIT = 1,
		STATE_LONG_INNER_LOOP_INIT = 2,
		STATE_LONG_INNER_LOOP_BODY = 3,
		STATE_LONG_OUTER_LOOP_INCR = 4,
		STATE_SHORT_OUTER_LOOP_INIT = 5,
		STATE_SHORT_MIDDLE_LOOP_INIT = 6,
		STATE_SHORT_INNER_LOOP_INIT = 7,
		STATE_SHORT_INNER_LOOP_BODY = 8,
		STATE_SHORT_MIDDLE_LOOP_INCR = 9,
		STATE_SHORT_OUTER_LOOP_INCR = 10,
		STATE_DONE = 11;
	 
	// block modes
	localparam
		MODE_SHORT = 0,
		MODE_MIXED = 1,
		MODE_LONG  = 2;
		
	// calculation mode
	localparam
		CALC_MODE_SHORT = 0,
		CALC_MODE_LONG  = 1;

	// real registers
	reg [3:0] state;               // the state

	reg [4:0] cb;                  // the cb variable (counter of the outer loop)
	reg [4:0] cb_stop;             // upper bound of the cb variable
	reg [1:0] window;              // the current window (counter of the middle loop)
	reg       calculation_mode;    // type of calculation which should be performed
	reg       calculation_start;   // starts the calculation
	reg [9:0] index;               // the address where to read data from and write data to
	reg [7:0] counter;             // the counter of the inner loop
	
	// combinational regs
	reg  [1:0] mode;               // the block mode
	
	// wires
	wire  [7:0] scalefac_width;          // output of the scalefac width ROM
	wire        calculation_ready;       // indicates that the calulation is ready to receive the next
	                                     // data in the NEXT clock cycle
	wire        calculation_active;      // indicates that a calculation is still going on
	wire  [2:0] sideinfo_subblock_gain;  // the subblock gain which is relevant for the current window
	
	// selection of the subblock_gain
	assign sideinfo_subblock_gain = (window == 0) ? sideinfo_subblock_gain_window0 :
	                                (window == 1) ? sideinfo_subblock_gain_window1 :
	                                sideinfo_subblock_gain_window2;
											 
	// combinational calculation of the block mode
	always @(*) begin
		if (sideinfo_window_switching_flag && sideinfo_block_type == 2) begin
			if (sideinfo_mixed_block_flag)
				mode = MODE_MIXED;
			else
				mode = MODE_SHORT;
		end else begin
			mode = MODE_LONG;
		end
	end
	
	// lookup ROMs
	rom_scalefac_width scalefac_inst  (
		.clk(clk),
		.enable(1'b1),
		.mode(mode),
		.freq(header_sampling_frequency),
		.ch_width(cb),
		.data(scalefac_width)
	);
	
	// the compute unit of this stage (executes the body of the inner loop)
	requantize_calculations calculations(
		.clk(clk),
		.rst(rst),  
		     
		.granule_read_addr(granule_read_addr),
		.granule_read_data(granule_read_data),  
		.granule_write_enable(granule_write_enable),
		.granule_write_addr(granule_write_addr), 
		.granule_write_data(granule_write_data),     
       
		.scalfac_short_read_addr_window(scalfac_short_read_addr_window),
		.scalfac_short_read_addr_index(scalfac_short_read_addr_index),             
		.scalfac_short_read_data(scalfac_short_read_data),
		.scalfac_long_read_addr(scalfac_long_read_addr),
		.scalfac_long_read_data(scalfac_long_read_data),  
         
		.sideinfo_scalefac_scale(sideinfo_scalefac_scale),
		.sideinfo_preflag(sideinfo_preflag),
		.sideinfo_global_gain(sideinfo_global_gain),
		.sideinfo_subblock_gain(sideinfo_subblock_gain),

		.start(calculation_start),
		.ready(calculation_ready),
		.active(calculation_active),
		.index(index),
		.cb(cb),
		.window(window),
		.calc_mode(calculation_mode)
	);


	// the state machine
	always @(posedge clk) begin
		
		if(rst) begin
			state <= STATE_IDLE;
			channel_done <= 0;
			calculation_start <= 0;
			
		end
		else begin
			channel_done <= 0;
			calculation_start <= 0;

			case(state)
				// IDLE state - wait for ready signal
				STATE_IDLE: begin
					if(channel_ready) begin
						if (mode == MODE_SHORT)
							state <= STATE_SHORT_OUTER_LOOP_INIT;
						else
							state <= STATE_LONG_OUTER_LOOP_INIT;
					end
				end
				
				// initializes the outer loop for long block calculations
				STATE_LONG_OUTER_LOOP_INIT: begin
				    if (mode == MODE_LONG) begin
				        cb <= 0;
				        cb_stop <= 22;
				    end else begin
				        cb <= 0;
				        cb_stop <= 8;
				    end
				    index <= 0;
				    calculation_mode <= CALC_MODE_LONG;
				    state <= STATE_LONG_INNER_LOOP_INIT;				
				end
				
				// initializes the inner loop for long block calculations
				STATE_LONG_INNER_LOOP_INIT: begin
				   counter <= 0;
				   if (calculation_ready) begin
						calculation_start <= 1;
						if (index != 0)
							index <= index + 1;
						state <= STATE_LONG_INNER_LOOP_BODY;
				   end
				end
				
				// executes the calculations for long blocks 
				// (this is delegated to the sub module)
				STATE_LONG_INNER_LOOP_BODY: begin
				    if ((counter + 1) < scalefac_width) begin
                        if (calculation_ready) begin
                            counter <= counter + 1;
                            index <= index + 1;
                            calculation_start <= 1;
                        end
				    end else begin
				        state <= STATE_LONG_OUTER_LOOP_INCR;
				    end
				end
				
				// increments the outer loop for long blocks
				STATE_LONG_OUTER_LOOP_INCR: begin
				    cb <= cb + 1;
				    if ((cb + 1) < cb_stop) begin
				        state <= STATE_LONG_INNER_LOOP_INIT;
				    end else begin
				        if (mode == MODE_MIXED)
				            state <= STATE_SHORT_OUTER_LOOP_INIT;
				        else
				            state <= STATE_DONE;
				    end
				end
				
				// initializes the outer loop for short blocks
				STATE_SHORT_OUTER_LOOP_INIT: begin
					if (mode == MODE_SHORT) begin
						cb <= 0;
						cb_stop <= 13;
						index <= 0;
					end else begin
						cb <= 8;
						cb_stop <= 18;
					end
					calculation_mode <= CALC_MODE_SHORT;
					state <= STATE_SHORT_MIDDLE_LOOP_INIT;
				end
              
				// initializes the middle loop for short blocks
				STATE_SHORT_MIDDLE_LOOP_INIT: begin
					window <= 0;
					state <= STATE_SHORT_INNER_LOOP_INIT;
				end
				
				// initializes the inner loop for short blocks
				STATE_SHORT_INNER_LOOP_INIT: begin
					counter <= 0;
					if (calculation_ready) begin
						calculation_start <= 1;
						if (index != 0)
							index <= index + 1;
						state <= STATE_SHORT_INNER_LOOP_BODY;
					end
				end
                
				// executes the calculations for short blocks
				// (this is delegated to the sub module)
				STATE_SHORT_INNER_LOOP_BODY: begin
					if ((counter + 1) < scalefac_width) begin
						if (calculation_ready) begin
							counter <= counter + 1;
							index <= index + 1;
							calculation_start <= 1;
						end
					end else begin
						state <= STATE_SHORT_MIDDLE_LOOP_INCR;
					end
				end
				 
				// increments the middle loop
				STATE_SHORT_MIDDLE_LOOP_INCR: begin
					window <= window + 1;
					if ((window + 1) < 3) begin
						state <= STATE_SHORT_INNER_LOOP_INIT;
					end else begin
						state <= STATE_SHORT_OUTER_LOOP_INCR;
					end
				end
				 
				// increments the outer loop
				STATE_SHORT_OUTER_LOOP_INCR: begin
					cb <= cb + 1;
					if ((cb + 1) < cb_stop) begin
						state <= STATE_SHORT_MIDDLE_LOOP_INIT;
					end else begin
						state <= STATE_DONE;
					end
				end
				
				// signal that this stage is finished
				STATE_DONE: begin
					if (!calculation_active) begin
						channel_done <= 1;
						state <= STATE_IDLE;	
					end
				end
		
				default: begin
						state <= 0;					
				end
				
			endcase
		end
	end

endmodule
