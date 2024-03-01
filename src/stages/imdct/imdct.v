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
module imdct(
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

	 output wire  [9:0] granule_ch1_read_addr,
	 input  wire [17:0] granule_ch1_read_data,
	 output wire        granule_ch1_write_enable,
	 output wire  [9:0] granule_ch1_write_addr, 
	 output wire [17:0] granule_ch1_write_data, 
	 
// ==================================================
// sideinfo information
// --------------------------------------------------	  
	 
	 input  wire  [1:0] sideinfo_ch0_block_type,
	 input  wire        sideinfo_ch0_window_switching_flag,
	 input  wire        sideinfo_ch0_mixed_block_flag,

// --------------------------------------------------	 
	 
	 input  wire  [1:0] sideinfo_ch1_block_type,
	 input  wire        sideinfo_ch1_window_switching_flag,
	 input  wire        sideinfo_ch1_mixed_block_flag,	 
	 
// ==================================================
// stage signaling
// --------------------------------------------------	
	 
    input  wire        stage_ready,
    output reg        stage_done
    );
    
//datapath
//connections
wire [17:0] computed_data_0_ch0;
wire [5:0] compute_index_0_ch0;
wire [17:0] computed_data_1_ch0;
wire [5:0] compute_index_1_ch0;
wire compute_done_ch0;
wire [17:0] windowed_data_0_ch0;
wire [5:0] windowed_index_0_ch0;
wire [17:0] windowed_data_1_ch0;
wire [5:0] windowed_index_1_ch0;
wire windowing_done_ch0;
wire overlap_done_ch0;
//control signals
wire [1:0] block_type_ch0;
wire [9:0] base_address_ch0;
wire stage_done_ch0;
wire band_done_ch0;
wire start_subband_ch0;

//connections
wire [17:0] computed_data_0_ch1;
wire [5:0] compute_index_0_ch1;
wire [17:0] computed_data_1_ch1;
wire [5:0] compute_index_1_ch1;
wire compute_done_ch1;
wire [17:0] windowed_data_0_ch1;
wire [5:0] windowed_index_0_ch1;
wire [17:0] windowed_data_1_ch1;
wire [5:0] windowed_index_1_ch1;
wire windowing_done_ch1;
wire overlap_done_ch1;
//control signals
wire [1:0] block_type_ch1;
wire [9:0] base_address_ch1;
wire stage_done_ch1;
wire band_done_ch1;
wire start_subband_ch1;

compute comp0_ch0(.clk(clk), .rst(rst), .base_addr(base_address_ch0), .block_type_2bit(block_type_ch0), .read_data(granule_ch0_read_data), .all_ready(overlap_done_ch0), .start(start_subband_ch0), .read_addr(granule_ch0_read_addr), .computed_value_0(computed_data_0_ch0), .index_0(compute_index_0_ch0), .computed_value_1(computed_data_1_ch0), .index_1(compute_index_1_ch0), .compute_done(compute_done_ch0), .band_done(band_done_ch0));
windowing wind_ch0(.clk(clk), .rst(rst), .base_address(base_address_ch0), .computed_value_0(computed_data_0_ch0), .index_0(compute_index_0_ch0), .computed_value_1(computed_data_1_ch0), .index_1(compute_index_1_ch0), .compute_done(compute_done_ch0), .block_type(block_type_ch0), .windowed_value_0(windowed_data_0_ch0), .index_0_out(windowed_index_0_ch0), .windowed_value_1(windowed_data_1_ch0), .index_1_out(windowed_index_1_ch0), .done(windowing_done_ch0), .overlap_done(overlap_done_ch0));
overlap ovl_ch0(.clk(clk), .rst(rst), .base_address(base_address_ch0), .block_type(sideinfo_ch0_block_type), .windowed_value_0(windowed_data_0_ch0), .index_0(windowed_index_0_ch0), .windowed_value_1(windowed_data_1_ch0), .index_1(windowed_index_1_ch0), .windowing_done(windowing_done_ch0), .write_addr(granule_ch0_write_addr), .data_out(granule_ch0_write_data), .write_enable(granule_ch0_write_enable), .done(overlap_done_ch0));

compute comp0_ch1(.clk(clk), .rst(rst), .base_addr(base_address_ch1), .block_type_2bit(block_type_ch1), .read_data(granule_ch1_read_data), .all_ready(overlap_done_ch1), .start(start_subband_ch1), .read_addr(granule_ch1_read_addr), .computed_value_0(computed_data_0_ch1), .index_0(compute_index_0_ch1), .computed_value_1(computed_data_1_ch1), .index_1(compute_index_1_ch1), .compute_done(compute_done_ch1), .band_done(band_done_ch1));
windowing wind_ch1(.clk(clk), .rst(rst), .base_address(base_address_ch1), .computed_value_0(computed_data_0_ch1), .index_0(compute_index_0_ch1), .computed_value_1(computed_data_1_ch1), .index_1(compute_index_1_ch1), .compute_done(compute_done_ch1), .block_type(block_type_ch1), .windowed_value_0(windowed_data_0_ch1), .index_0_out(windowed_index_0_ch1), .windowed_value_1(windowed_data_1_ch1), .index_1_out(windowed_index_1_ch1), .done(windowing_done_ch1), .overlap_done(overlap_done_ch1));
overlap ovl_ch1(.clk(clk), .rst(rst), .base_address(base_address_ch1), .block_type(sideinfo_ch1_block_type), .windowed_value_0(windowed_data_0_ch1), .index_0(windowed_index_0_ch1), .windowed_value_1(windowed_data_1_ch1), .index_1(windowed_index_1_ch1), .windowing_done(windowing_done_ch1), .write_addr(granule_ch1_write_addr), .data_out(granule_ch1_write_data), .write_enable(granule_ch1_write_enable), .done(overlap_done_ch1));

channel_controller ch0(.clk(clk), .rst(rst), .block_type(sideinfo_ch0_block_type), .window_switching_flag(sideinfo_ch0_window_switching_flag), .mixed_block_flag(sideinfo_ch0_mixed_block_flag), .overlap_done(overlap_done_ch0), .band_done(band_done_ch0), .stage_ready(stage_ready), .block_type_out(block_type_ch0), .base_address(base_address_ch0), .start_subband(start_subband_ch0), .stage_done(stage_done_ch0));
channel_controller ch1(.clk(clk), .rst(rst), .block_type(sideinfo_ch1_block_type), .window_switching_flag(sideinfo_ch1_window_switching_flag), .mixed_block_flag(sideinfo_ch1_mixed_block_flag), .overlap_done(overlap_done_ch1), .band_done(band_done_ch1), .stage_ready(stage_ready), .block_type_out(block_type_ch1), .base_address(base_address_ch1), .start_subband(start_subband_ch1), .stage_done(stage_done_ch1));

reg counter;

always @(posedge clk) begin
    if(rst) begin
        stage_done <= 0;
        counter <= 0;
    end else begin
        if(counter == 0) begin
            stage_done <= 0;
            if(stage_done_ch0 && stage_done_ch1) begin
                stage_done <= 1;
            end else
            if(stage_done_ch0 || stage_done_ch1) begin
                counter <= 1;
            end
        end else begin
            if(stage_done_ch0 || stage_done_ch1) begin
                counter <= 0;
                stage_done <= 1;
            end
        end
    end
end
//FSM

endmodule

module channel_controller(
    input wire clk,
    input wire rst,
    input wire [1:0] block_type,
    input wire window_switching_flag,
    input wire mixed_block_flag,
    input wire overlap_done,
    input wire band_done, 
    input wire stage_ready,
    output reg [1:0] block_type_out,
    output reg [9:0] base_address,
    output reg start_subband,
    output reg stage_done
);
localparam 
    idle = 2'b00,
    calc = 2'b01,
    calc_lower = 2'b10,
    calc_upper = 2'b11;

reg[1:0] state,
         nextstate;

always @(posedge clk) begin
    if(rst) begin
        state <= idle;
    end else begin
        state <= nextstate;
    end
end

always @(posedge clk) begin
    if(rst) begin
        base_address <= 0;
        start_subband <= 0;
        stage_done <= 0;
    end else begin
        if(band_done && base_address < 575 && ~start_subband && state != idle) begin
            base_address <= base_address + 18;
            if(base_address < 558) begin
                start_subband <= 1;
            end
        end else if(stage_ready) begin
            start_subband <= 1;
            base_address <= 0;
        end else begin
            start_subband <= 0;
        end
        
        if(base_address >= 575) begin
            base_address <= 0;
            stage_done = 1;
        end else begin
            stage_done = 0;
        end
    end
end


//state transitions
always @(*) begin
nextstate = state;
case(state)
    idle: begin
        if(stage_ready && mixed_block_flag) begin
            nextstate = calc_lower;
        end else if(stage_ready && ~mixed_block_flag) begin
            nextstate = calc;
        end
    end
    
    calc: begin
        if(base_address >= 575) begin
            nextstate = idle;
        end else begin
            nextstate = calc;
        end
    end
    
    calc_lower: begin
        if(base_address >= 32) begin
            nextstate = calc_upper;
        end else begin
            nextstate = calc_lower;
        end
    end
    
    calc_upper: begin
        if(base_address >= 575) begin
            nextstate = idle;
        end else begin
            nextstate = calc_upper;
        end
    end
endcase
end


//outputs
always @(*) begin
block_type_out = 0;
    case(state)
        calc: begin
            block_type_out = block_type;
        end
        
        calc_lower: begin
            block_type_out = 0;
        end
        
        calc_upper: begin
            block_type_out = block_type;
        end
    endcase
end
endmodule