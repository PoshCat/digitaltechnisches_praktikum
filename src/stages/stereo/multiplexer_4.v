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

module multiplexer_2_1bit(input wire muxin, input wire a, input wire b, output reg out);
    always @(*)begin
        case (muxin)
            0: out = a;
            1: out = b;
        endcase
    end
endmodule

module multiplexer_4(input wire[1:0] muxin, input wire a, input wire b, input wire c,output reg out);
    always @(*)begin
        case (muxin)
            2'b0: out = a;
            2'd1: out = b;
            2'd2: out = c;
            default: out = 1'b0;
        endcase
    end
endmodule