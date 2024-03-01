`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2022 01:22:54 PM
// Design Name: 
// Module Name: multiplexer_2
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


module multiplexer_2_10bit(input wire muxin, input wire[9:0] a, input wire[9:0] b, output reg[9:0] out);
    always @(*)begin
        case (muxin)
            0: out = a;
            1: out = b;
        endcase
    end
endmodule
