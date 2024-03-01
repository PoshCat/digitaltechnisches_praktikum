`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2022 03:14:16 PM
// Design Name: 
// Module Name: register
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


module register#
(
    parameter N = 18
)
(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire[N-1:0] dataIn,
    output reg[N-1:0] dataOut
    );
    always @(posedge clk) begin
        if(!rst) begin
            if(enable) dataOut <= dataIn;
        end else begin
            dataOut <= 0;
        end
    end
endmodule