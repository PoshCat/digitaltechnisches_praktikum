`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:44:38 07/14/2016 
// Design Name: 
// Module Name:    arith18_mul 
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
module arith18_mul(
    input wire signed [17:0] op1,
	input wire signed [17:0] op2,
    output wire [17:0] product
    );
    
    reg[35:0] tmp;
    assign product = tmp[33:16];
    
    always @(*) begin
        tmp = op1 * op2;
    end

endmodule
