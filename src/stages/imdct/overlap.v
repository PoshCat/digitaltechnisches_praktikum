`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2022 11:17:40 AM
// Design Name: 
// Module Name: overlap
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


module overlap(
    input wire clk,
    input wire rst,
    input wire [9:0] base_address,
    input wire [1:0] block_type,
    input wire [17:0] windowed_value_0,
    input wire [5:0] index_0,
    input wire [17:0] windowed_value_1,
    input wire [5:0] index_1,
    input wire windowing_done,
    output wire [9:0] write_addr,
    output wire [17:0] data_out,
    output reg write_enable,
    output reg done
    );
    
//datapath
wire [17:0] old_frame_data;
wire [17:0] mem_in;
wire [17:0] add_in;
reg mem_read_enable;
reg mem_ctrl;
reg add_ctrl;
reg mem_write_enable;
reg mem_ctrl_out;
wire mem_shift_ctrl;
wire [9:0] mem_addr_0;
wire [9:0] mem_addr_1;
wire [9:0] mem_addr_tmp;
wire [9:0] mem_addr_shifted;
wire [9:0] mem_addr_shifted_out;
wire [9:0] mem_addr;
wire [9:0] mem_addr_tmp_out;

assign mem_addr_0 = base_address + index_0;
assign mem_addr_1 = base_address + index_1;
assign mem_addr_shifted = mem_addr_tmp - 18;
assign mem_addr_shifted_out = mem_addr_tmp_out - 18;
assign mem_shift_ctrl = index_0 >= 18;

multiplexer_2_Nbit #(.N(18)) mux_mem_data(.muxin(mem_ctrl), .a(windowed_value_0), .b(windowed_value_1), .out(mem_in));
multiplexer_2_Nbit #(.N(10)) mux_mem_addr(.muxin(mem_ctrl), .a(mem_addr_0), .b(mem_addr_1), .out(mem_addr_tmp));
multiplexer_2_Nbit #(.N(10)) mux_mem_addr_shift(.muxin(mem_shift_ctrl), .a(mem_addr_tmp), .b(mem_addr_shifted), .out(mem_addr));


imdct_overlap_memory mem(.clk(clk), .read_enable(mem_read_enable), .read_addr(mem_addr), .read_data(old_frame_data), .write_enable(mem_write_enable), .write_addr(mem_addr), .write_data(mem_in)); 
    
multiplexer_2_Nbit #(.N(18)) mux_add(.muxin(add_ctrl), .a(windowed_value_0), .b(windowed_value_1), .out(add_in));
    
arith18_add add(.op1(old_frame_data), .op2(add_in), .sum(data_out));

multiplexer_2_Nbit #(.N(10)) mux_mem_addr_out(.muxin(mem_ctrl_out), .a(mem_addr_0), .b(mem_addr_1), .out(mem_addr_tmp_out));
multiplexer_2_Nbit #(.N(10)) mux_mem_addr_shift_out(.muxin(mem_shift_ctrl), .a(mem_addr_tmp_out), .b(mem_addr_shifted_out), .out(write_addr));

//FSM
localparam
    idle = 0,
    read_mem = 1,
    calc_write_read = 2,
    calc_write = 3,
    write_overlap = 4,
    write_overlap2 = 5;

reg [2:0] state,
          nextstate;
          
always @(posedge clk) begin
    if(rst) begin
        state <= idle;
    end else begin
        state <= nextstate;
        /*if(block_type == 2'b10 && state == calc_write_read) begin
            done <= 1;
        end else */if(state == calc_write || state == write_overlap2) begin
            done <= 1;
        end else begin
            done <= 0;
        end
    end
end

always @(*) begin
nextstate = idle;
case(state)
    idle: if(windowing_done) begin
        if(index_0 < 18) begin
            nextstate = read_mem;        
        end else begin
            nextstate = write_overlap;
        end
    end
    
    read_mem: nextstate = calc_write_read;
    
    calc_write_read: nextstate = calc_write;
        /*if(block_type == 2'b10) begin
            nextstate = idle;
        end else begin
            nextstate = calc_write;
        end*/
    
    calc_write: nextstate = idle;
    
    write_overlap: nextstate = write_overlap2;

    write_overlap2: nextstate = idle;
endcase
end

always @(*) begin
mem_read_enable = 0;
mem_ctrl = 0;
add_ctrl = 0;
mem_write_enable = 0;
mem_ctrl_out = 0;
write_enable = 0;
case(state)
    read_mem: begin
        mem_ctrl = 0;
        mem_read_enable = 1;
    end
    
    calc_write_read: begin
        mem_ctrl = 1;
        mem_read_enable = 1;
        add_ctrl = 0;
        write_enable = 1;
        mem_ctrl_out = 0;
    end
    
    calc_write: begin
        mem_ctrl_out = 1;
        write_enable = 1;
        add_ctrl = 1;
    end
    
    write_overlap: begin
        mem_write_enable = 1;
        mem_ctrl = 0;
    end
    
    write_overlap2: begin
        mem_write_enable = 1;
        mem_ctrl = 1;
    end
    
endcase
end

endmodule
