`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:42:55 07/14/2016 
// Design Name: 
// Module Name:    arith18_sub 
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
module arith18_sub(
    input wire [17:0] op1,
	input wire [17:0] op2,
    output wire [17:0] difference
    );
    
    assign difference = op1 - op2;

endmodule
