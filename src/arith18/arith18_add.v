`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:19 07/14/2016 
// Design Name: 
// Module Name:    arith18_add 
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
module arith18_add(
    input wire [17:0] op1,
	input wire [17:0] op2,
    output wire [17:0] sum
    );
	 
    assign sum = op1 + op2;
endmodule
