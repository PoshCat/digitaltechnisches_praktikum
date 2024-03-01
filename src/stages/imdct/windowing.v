`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2022 10:47:46 AM
// Design Name: 
// Module Name: windowing
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module windowing(
    input wire clk,
    input wire rst,
    input wire [9:0] base_address,
    input wire [17:0] computed_value_0,
    input wire [5:0] index_0,
    input wire [17:0] computed_value_1,
    input wire [5:0] index_1,
    input wire compute_done,
    input wire [1:0] block_type,
    input wire overlap_done,
    output wire [17:0] windowed_value_0,
    output wire [5:0] index_0_out,
    output wire [17:0] windowed_value_1,
    output wire [5:0] index_1_out,
    output reg done
);

//datapath
wire [17:0] window_data_0,
            window_data_1,
            windowed_tmp_0,
            windowed_tmp_1;
            
assign index_0_out = index_0;
assign index_1_out = index_1;

rom_imdct_sinwindow rom_0(.clk(clk), .enable(compute_done), .window(block_type), .n(index_0), .data(window_data_0));
rom_imdct_sinwindow rom_1(.clk(clk), .enable(compute_done), .window(block_type), .n(index_1), .data(window_data_1));

arith18_mul mul_0(.op1(computed_value_0), .op2(window_data_0), .product(windowed_tmp_0));
arith18_mul mul_1(.op1(computed_value_1), .op2(window_data_1), .product(windowed_tmp_1));

multiplexer_2_Nbit #(.N(18)) value_0_short(.muxin(block_type[1] & ~block_type[0]), .a(windowed_tmp_0), .b(computed_value_0), .out(windowed_value_0));
multiplexer_2_Nbit #(.N(18)) value_1_short(.muxin(block_type[1] & ~block_type[0]), .a(windowed_tmp_1), .b(computed_value_1), .out(windowed_value_1));

reg counter;

always @(posedge clk) begin
    if(rst) begin
        counter <= 0;
        done <= 0;
    end else begin
        if(compute_done == 1) counter <= 1;
        if(counter == 1) begin
            done <= 1;
            counter <= 0;
        end else begin
            done <= 0;
        end
    end
end

endmodule
