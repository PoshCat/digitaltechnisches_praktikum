`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2022 10:05:19 AM
// Design Name: 
// Module Name: multiplexer_2_Nbit
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


module multiplexer_2_Nbit#
(
    parameter N = 18
)
(input wire muxin, input wire[N-1:0] a, input wire[N-1:0] b, output reg[N-1:0] out);
    always @(*)begin
        case (muxin)
            0: out = a;
            1: out = b;
        endcase
    end
endmodule
