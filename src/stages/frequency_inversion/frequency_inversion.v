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
module frequency_inversion(
    input  wire clk,
    input  wire rst,	 

// ==================================================
// 576 lines
// --------------------------------------------------	 
	 
	 output wire  [9:0] granule_ch0_read_addr,
	 input  wire [17:0] granule_ch0_read_data,
	 output wire        granule_ch0_write_enable,
	 output wire  [9:0] granule_ch0_write_addr, 
	 output reg [17:0] granule_ch0_write_data,	 

	 output wire  [9:0] granule_ch1_read_addr,
	 input  wire [17:0] granule_ch1_read_data,
	 output wire        granule_ch1_write_enable,
	 output wire  [9:0] granule_ch1_write_addr, 
	 output reg [17:0] granule_ch1_write_data, 	 

// ==================================================
// stage signaling
// --------------------------------------------------	
	 
    input  wire        stage_ready,
    output reg        stage_done
    );
	
	reg [5:0] subband_counter;
	reg [10:0] next_subband_index;
	reg [10:0] counter;
	reg working;
	reg write_enable;
	reg [10:0] write_addr;
	
	assign granule_ch0_read_addr = counter;
	assign granule_ch1_read_addr = counter;
	assign granule_ch0_write_addr = write_addr;
	assign granule_ch1_write_addr = write_addr;
    
	assign granule_ch0_write_enable = write_enable;
	assign granule_ch1_write_enable = write_enable;
	
	
	
	always @(posedge clk) begin
	   if(rst)begin
	       counter <= 0;
	       subband_counter <= 0;
	       next_subband_index <= 0;
	   end else begin
	       if(stage_ready) begin
	           working <= 1;
	           counter <= 0;
	           subband_counter <= 0;
	           next_subband_index <= 16;
	           stage_done <= 0;
	       end
           if(working)begin
               if(counter <= 576)begin
                    counter <= counter +1;
                    write_addr <= counter-1;
                    if(counter > 0)write_enable <= 1;
                    if(write_addr == next_subband_index)begin
                        next_subband_index <= next_subband_index +18;
                        subband_counter <= subband_counter +1;
                    end
                    if(~write_addr[0] && subband_counter[0])begin
                        granule_ch1_write_data <= (~granule_ch1_read_data) +1;
                        granule_ch0_write_data <= (~granule_ch0_read_data) +1;
                    end else begin
                        granule_ch1_write_data <= granule_ch1_read_data;
                        granule_ch0_write_data <= granule_ch0_read_data;
                    end
               end else begin
                    working <= 0;
                    stage_done <= 1;
                    write_enable <= 0;
               end
           end else begin
                write_enable <= 0;
                stage_done <= 0;
           end 
	   end
	end
	
endmodule
