`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:49:13 07/15/2016 
// Design Name: 
// Module Name:    step_template 
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
module reorder_channel (
    input  wire clk,
    input  wire rst,	 
	 
// ==================================================
// 576 lines
// --------------------------------------------------	 
	 
	 output reg   [9:0] granule_read_addr,
	 input  wire [17:0] granule_read_data, 

	 output reg         granule_write_enable,
	 output reg   [9:0] granule_write_addr, 
	 output reg  [17:0] granule_write_data, 
	 
// ==================================================
// header information
// --------------------------------------------------	  
	 
	 input  wire  [1:0] header_sampling_frequency,
	 
// ==================================================
// sideinfo information
// --------------------------------------------------	  
	 
	 input  wire  [1:0] sideinfo_block_type,
	 input  wire        sideinfo_window_switching_flag,
	 input  wire        sideinfo_mixed_block_flag,	 
	 
// ==================================================
// stage signaling
// --------------------------------------------------	
	 
    input  wire        channel_ready,
    output reg         channel_done
    );

	// states
	localparam
		STATE_IDLE = 0,
		STATE_COPY_PREPARE1 = 1,
		STATE_COPY_PREPARE2 = 2,
		STATE_COPY = 3,
		STATE_REORDER_START = 4,
		STATE_MIDDLE_LOOP_INIT = 5,
		STATE_INNER_LOOP_INIT = 6,
		STATE_INNER_LOOP_BODY1 = 7,
		STATE_INNER_LOOP_BODY2 = 8,
		STATE_INNER_LOOP_BODY3 = 9,
		STATE_MIDDLE_LOOP_INCR = 10,
		STATE_OUTER_LOOP_INCR = 11,
		STATE_DONE = 12;
	
	// block modes
	localparam
		MODE_SHORT = 0,
		MODE_MIXED = 1,
		MODE_LONG = 2;
	
	// real registers
	reg [3:0] state;             // the state
	reg [9:0] read_index;        // the index for reading data
	reg [9:0] write_index;       // the index for writing data
	reg [9:0] scale;             // the scale variable
	reg [4:0] cb;                // the cb variable
	reg [4:0] cb_stop;           // the upper bound for counting the cb variable
	reg [9:0] base;              // the base variable
	reg [1:0] offset;            // the offset variable
	reg [9:0] dest;              // the dest variable

	// combinational regs
	reg [1:0] mode;              // the block mode
	
	// wires
	wire [7:0] scalefac_width;
	
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
	
	// scalefac ROM
	rom_scalefac_width scalefac_inst  (
		clk,
		1'b1,
		mode,
		header_sampling_frequency,
		cb,
		scalefac_width
	);

	// state machine
	always @(posedge clk) begin
		
		if(rst) begin
			state <= STATE_IDLE;
			channel_done <= 0;
			granule_read_addr <= 0;
			granule_write_enable <= 0;
		end
		else begin
			channel_done <= 0;
			granule_write_enable <= 0;

			case(state)
			
				// wait for external ready signal
				STATE_IDLE: begin
					if(channel_ready) begin
						state <= STATE_COPY_PREPARE1;
						read_index <= 0;
						write_index <= 0;
					end
				end
					
				// set first read address
				STATE_COPY_PREPARE1: begin
					granule_read_addr <= read_index;
					state             <= STATE_COPY_PREPARE2;
				end
				
				// set next read address
				STATE_COPY_PREPARE2: begin
					granule_read_addr <= read_index+1;
					read_index        <= read_index+1;
					state             <= STATE_COPY;
				end
				
				// get read data and write it to the same address,
				// set next read address
				STATE_COPY: begin
					granule_write_enable   <= 1;
					granule_write_addr     <= write_index;
					granule_write_data     <= granule_read_data;
					
					granule_read_addr      <= read_index+1;
					
					read_index             <= read_index+1;
					write_index            <= write_index+1;
					
					if(write_index == 575) begin
						if (mode == MODE_LONG)
							state <= STATE_DONE;
						else
							state <= STATE_REORDER_START;	
					end	
				end
				
				// start the reordering / initialize the outer loop
				STATE_REORDER_START: begin
					if (mode == MODE_SHORT) begin
						scale <= 0;
						cb_stop <= 13;
						cb <= 0;
						state <= STATE_MIDDLE_LOOP_INIT;
					end else begin	// mixed mode
						scale <= 36;
						cb_stop <= 18;
						cb <= 8;
						state <= STATE_MIDDLE_LOOP_INIT;
					end
				end
				
				// initialize the middle loop
				STATE_MIDDLE_LOOP_INIT: begin
					base <= scale;
					offset <= 0;
					state <= STATE_INNER_LOOP_INIT;
				end
				
				// initialize the inner loop
				STATE_INNER_LOOP_INIT: begin
					read_index <= 0;
					write_index <= 0;
					dest <= base + {8'd0, offset};
					state <= STATE_INNER_LOOP_BODY1;
				end
				
				// set first read address
				STATE_INNER_LOOP_BODY1: begin
					granule_read_addr <= scale;
					scale <= scale + 1;
					read_index <= read_index + 1;
					state <= STATE_INNER_LOOP_BODY2;
				end
				
				// set second read address
				STATE_INNER_LOOP_BODY2: begin
					granule_read_addr <= scale;
					scale <= scale + 1;
					read_index <= read_index + 1;
					state <= STATE_INNER_LOOP_BODY3;
				end
				
				// get read data and write it to the corresponding destination address
				// set next read address
				STATE_INNER_LOOP_BODY3: begin
					granule_read_addr <= scale;
					if (read_index < scalefac_width) begin
						scale <= scale + 1;
						read_index <= read_index + 1;
					end
					
					granule_write_enable   <= 1;
					granule_write_addr     <= dest;
					granule_write_data     <= granule_read_data;
					dest <= dest + 3;
					write_index <= write_index + 1;
					
					if (write_index + 1 < scalefac_width)
						state <= STATE_INNER_LOOP_BODY3;
					else
						state <= STATE_MIDDLE_LOOP_INCR;
				end
				
				// increment of the middle loop
				STATE_MIDDLE_LOOP_INCR: begin
					offset <= offset + 1;
					if (offset + 1 < 3)
						state <= STATE_INNER_LOOP_INIT;
					else
						state <= STATE_OUTER_LOOP_INCR;
				end
				
				// increment of the outer loop
				STATE_OUTER_LOOP_INCR: begin
					cb <= cb + 1;
					if (cb + 1 < cb_stop)
						state <= STATE_MIDDLE_LOOP_INIT;
					else
						state <= STATE_DONE;
				end
				
				// signal that the reordering has finished
				STATE_DONE: begin
					channel_done <= 1;
					state <= STATE_IDLE;	
				end
		
				default: begin
					state <= STATE_IDLE;					
				end
				
			endcase
		end
	end

endmodule
