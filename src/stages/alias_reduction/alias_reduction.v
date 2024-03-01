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
module alias_reduction(
    input  wire clk,
    input  wire rst,	 

// ==================================================
// 576 lines
// --------------------------------------------------	 
	 
	 output wire  [9:0] granule_ch0_read_addr,
	 input  wire [17:0] granule_ch0_read_data,	 
	 output wire        granule_ch0_write_enable,
	 output wire  [9:0] granule_ch0_write_addr, 
	 output wire [17:0] granule_ch0_write_data,
	 
	 output wire  [9:0] granule_ch1_read_addr,
	 input  wire [17:0] granule_ch1_read_data,
	 output wire        granule_ch1_write_enable,
	 output wire  [9:0] granule_ch1_write_addr, 
	 output wire [17:0] granule_ch1_write_data, 
	 
// ==================================================
// sideinfo information
// --------------------------------------------------	  
	 
	 input  wire  [1:0] sideinfo_ch0_block_type,
	 input  wire        sideinfo_ch0_window_switching_flag,
	 input  wire        sideinfo_ch0_mixed_block_flag,	 
	 
// --------------------------------------------------		 
	 
	 input  wire  [1:0] sideinfo_ch1_block_type,
	 input  wire        sideinfo_ch1_window_switching_flag,
	 input  wire        sideinfo_ch1_mixed_block_flag,	 
	 	 
// ==================================================
// stage signaling
// --------------------------------------------------	
	 
    input  wire        stage_ready,
    output reg        stage_done 
    );
	localparam BUTTERFLY_MAX_DIFF = 17, MAXBUTTERFLY = 8;
    
    reg [9:0] counter;
    reg [3:0] butterfly_counter;
    reg up = 0;
    
    reg signed [9:0] other_address_diff;
    reg [9:0] other_address;
    reg [17:0] in_0;
    reg [17:0] in_1;
    wire count_enable;
                  
    always @(posedge clk) begin
        if(rst) begin
            counter <= 0;
            butterfly_counter <= MAXBUTTERFLY;
            up <= 0;
         
        end
        else if(counter < 576) begin
            if(count_enable) counter <= counter +1;
        end else begin
            counter <= 0;
        end
        
        if(counter == 576) begin
            stage_done <= 1;
        end else begin
           stage_done <= 0;
        end
        
        if(~rst && counter > 8 && counter < 567 && count_enable) begin
            if(~up) begin
                if(butterfly_counter == 0) begin
                    butterfly_counter <= 0;
                    up <= 1;
                end else begin
                    butterfly_counter <= butterfly_counter - 1;
                end
            end
            
            if(up) begin
                if(butterfly_counter == MAXBUTTERFLY) begin
                    butterfly_counter <= MAXBUTTERFLY;
                    up <= 0;
                end else begin
                    butterfly_counter <= butterfly_counter + 1;
                end
            end
        end
    end
    
    
    always @(posedge clk) begin
    
        if(rst) begin
            other_address_diff <= BUTTERFLY_MAX_DIFF;
            other_address <= 0;
        end 
        else if(counter > 8 && counter < 567 && granule_ch0_write_enable == 1) begin
            other_address <= counter + other_address_diff; //could be deleted
            other_address_diff <= other_address_diff - 2;
            if(other_address_diff <= -BUTTERFLY_MAX_DIFF) begin
                other_address_diff <= BUTTERFLY_MAX_DIFF;
            end
        end
        
        if(~rst) other_address <= counter + other_address_diff;
        
        if(counter >= 576) begin
            other_address_diff <= BUTTERFLY_MAX_DIFF;
        end
    end
    
    reg [1:0] mux_window_type_ch0, //0 = long window, 1 = mixed window, 2 = short window
              mux_window_type_ch1;
    reg lw_start_ch0,
        lw_start_ch1,
        mw_start_ch0,
        mw_start_ch1,
        sw_start_ch0,
        sw_start_ch1;
    
    always @(*) begin
        lw_start_ch0 = 0;
        mw_start_ch0 = 0;
        sw_start_ch0 = 0;
        lw_start_ch1 = 0;
        mw_start_ch1 = 0;
        sw_start_ch1 = 0;
         
        if(~sideinfo_ch0_window_switching_flag || (sideinfo_ch0_window_switching_flag && (sideinfo_ch0_block_type == 2'b01 || sideinfo_ch0_block_type == 2'b11))) begin
            mux_window_type_ch0 = 0;
            if(counter == 0 && stage_ready) begin
                lw_start_ch0 = 1;
            end else begin
                lw_start_ch0 = 0;
            end
        end else if(~sideinfo_ch0_mixed_block_flag) begin
            mux_window_type_ch0 = 2;
            if(counter == 0 && stage_ready) begin
                sw_start_ch0 = 1;
            end else begin
                sw_start_ch0 = 0;
            end
        end else begin
            mux_window_type_ch0 = 1;
            if(counter == 0 && stage_ready) begin
                mw_start_ch0 = 1;
            end else begin
                mw_start_ch0 = 0;
            end
        end
        
        if(~sideinfo_ch1_window_switching_flag || (sideinfo_ch1_window_switching_flag && (sideinfo_ch1_block_type == 2'b01 || sideinfo_ch1_block_type == 2'b11))) begin
            mux_window_type_ch1 = 0;
            if(counter == 0 && stage_ready) begin
                lw_start_ch1 = 1;
            end else begin
                lw_start_ch1 = 0;
            end
        end else if(~sideinfo_ch0_mixed_block_flag) begin
            mux_window_type_ch1 = 2;
            if(counter == 0 && stage_ready) begin
                sw_start_ch1 = 1;
            end else begin
                sw_start_ch1 = 0;
            end
        end else begin
            mux_window_type_ch1 = 1;
            if(counter == 0 && stage_ready) begin
                mw_start_ch1 = 1;
            end else begin
                mw_start_ch1 = 0;
            end
        end
    end
    
    wire enable0_ch0;
    wire mux_add_sub_ch0;
    wire enable0_ch1;
    wire mux_add_sub_ch1;
    wire mux_ctrl_out_ch0;
    wire mux_ctrl_out_ch1;
    reg const_enable;
    wire[2:0] const_index;
    wire signed [17:0] ca;
    wire signed [17:0] cs;
    wire mux_addr_ctrl_ch0;
    wire mux_addr_ctrl_ch1;
    
    wire lw_enable0_ch0;
    wire lw_enable0_ch1;
    wire lw_add_sub_ch0;    
    wire lw_add_sub_ch1;
    wire lw_ctrl_out_ch0;
    wire lw_ctrl_out_ch1;    
    wire lw_addr_ctrl_ch0;
    wire lw_addr_ctrl_ch1;
    wire lw_write_enable_ch0;
    wire lw_write_enable_ch1;
    wire lw_count_enable_ch0;
    wire lw_count_enable_ch1;
    reg lw_done_counter;
    wire lw_count_enable;
    
    wire mw_enable0_ch0;
    wire mw_enable0_ch1;
    wire mw_add_sub_ch0;    
    wire mw_add_sub_ch1;
    wire mw_ctrl_out_ch0;
    wire mw_ctrl_out_ch1;    
    wire mw_addr_ctrl_ch0;
    wire mw_addr_ctrl_ch1;
    wire mw_write_enable_ch0;
    wire mw_write_enable_ch1;
    wire mw_count_enable_ch0;
    wire mw_count_enable_ch1;
    reg mw_done_counter;
    wire mw_count_enable;
    
    wire sw_enable0_ch0;
    wire sw_enable0_ch1;
    wire sw_add_sub_ch0;    
    wire sw_add_sub_ch1;
    wire sw_ctrl_out_ch0;
    wire sw_ctrl_out_ch1;    
    wire sw_addr_ctrl_ch0;
    wire sw_addr_ctrl_ch1;
    wire sw_write_enable_ch0;
    wire sw_write_enable_ch1;
    wire sw_count_enable_ch0;
    wire sw_count_enable_ch1;
    reg sw_done_counter;
    wire sw_count_enable;
    
    multiplexer_4 state_add_sub_ch0(.muxin(mux_window_type_ch0), .a(lw_add_sub_ch0), .b(mw_add_sub_ch0), .c(sw_add_sub_ch0),  .out(mux_add_sub_ch0));
    multiplexer_4 state_add_sub_ch1(.muxin(mux_window_type_ch1), .a(lw_add_sub_ch1), .b(mw_add_sub_ch1), .c(sw_add_sub_ch1),  .out(mux_add_sub_ch1));
    multiplexer_4 state_ctrlout_ch0(.muxin(mux_window_type_ch0), .a(lw_ctrl_out_ch0), .b(mw_ctrl_out_ch0), .c(sw_ctrl_out_ch0),  .out(mux_ctrl_out_ch0));
    multiplexer_4 state_ctrlout_ch1(.muxin(mux_window_type_ch1), .a(lw_ctrl_out_ch1), .b(mw_ctrl_out_ch1), .c(sw_ctrl_out_ch1),  .out(mux_ctrl_out_ch1));    
    multiplexer_4 state_enable0_ch0(.muxin(mux_window_type_ch0), .a(lw_enable0_ch0), .b(mw_enable0_ch0), .c(sw_enable0_ch0),  .out(enable0_ch0));
    multiplexer_4 state_enable0_ch1(.muxin(mux_window_type_ch1), .a(lw_enable0_ch1), .b(mw_enable0_ch1), .c(sw_enable0_ch1),  .out(enable0_ch1));    
    multiplexer_4 state_addr_ctrl_ch0(.muxin(mux_window_type_ch0), .a(lw_addr_ctrl_ch0), .b(mw_addr_ctrl_ch0), .c(sw_addr_ctrl_ch0), .out(mux_addr_ctrl_ch0));
    multiplexer_4 state_addr_ctrl_ch1(.muxin(mux_window_type_ch1), .a(lw_addr_ctrl_ch1), .b(mw_addr_ctrl_ch1), .c(sw_addr_ctrl_ch1), .out(mux_addr_ctrl_ch1));
    multiplexer_4 state_write_enable_ch0(.muxin(mux_window_type_ch0), .a(lw_write_enable_ch0), .b(mw_write_enable_ch0), .c(sw_write_enable_ch0), .out(granule_ch0_write_enable));
    multiplexer_4 state_write_enable_ch1(.muxin(mux_window_type_ch1), .a(lw_write_enable_ch1), .b(mw_write_enable_ch1), .c(sw_write_enable_ch1), .out(granule_ch1_write_enable));
    multiplexer_4 state_count_enable(.muxin(mux_window_type_ch0), .a(lw_count_enable), .b(mw_count_enable), .c(sw_count_enable), .out(count_enable));
    
    
    assign lw_count_enable = lw_count_enable_ch0 && lw_count_enable_ch1;
    
    assign sw_count_enable = sw_count_enable_ch0 && sw_count_enable_ch1;
    
    assign mw_count_enable = mw_count_enable_ch0 && mw_count_enable_ch1;
        
    
    
    assign granule_ch0_write_addr = counter;
    assign granule_ch1_write_addr = counter;
	
	assign const_index = butterfly_counter[2:0];
	
	long_window_FSM long_window_ctrl0(.clk(clk), .rst(rst), .start(lw_start_ch0), .counter(counter), .enable0(lw_enable0_ch0), .butterfly_counter(butterfly_counter), .mux_add_sub(lw_add_sub_ch0), .mux_ctrlout(lw_ctrl_out_ch0), .write_enable(lw_write_enable_ch0), .count_enable(lw_count_enable_ch0), .mux_addr_ctrl(lw_addr_ctrl_ch0), .difference(other_address_diff)); //granule_ch0_write_enable has to be multiplexed
	long_window_FSM long_window_ctrl1(.clk(clk), .rst(rst), .start(lw_start_ch1), .counter(counter), .enable0(lw_enable0_ch1), .butterfly_counter(butterfly_counter), .mux_add_sub(lw_add_sub_ch1), .mux_ctrlout(lw_ctrl_out_ch1), .write_enable(lw_write_enable_ch1), .count_enable(lw_count_enable_ch1), .mux_addr_ctrl(lw_addr_ctrl_ch1), .difference(other_address_diff));
    
    mixed_window_FSM mixed_window_ctrl0(.clk(clk), .rst(rst), .start(mw_start_ch0), .counter(counter), .enable0(mw_enable0_ch0), .butterfly_counter(butterfly_counter), .mux_add_sub(mw_add_sub_ch0), .mux_ctrlout(mw_ctrl_out_ch0), .write_enable(mw_write_enable_ch0), .count_enable(mw_count_enable_ch0), .mux_addr_ctrl(mw_addr_ctrl_ch0), .difference(other_address_diff)); //granule_ch0_write_enable has to be multiplexed
	mixed_window_FSM mixed_window_ctrl1(.clk(clk), .rst(rst), .start(mw_start_ch1), .counter(counter), .enable0(mw_enable0_ch1), .butterfly_counter(butterfly_counter), .mux_add_sub(mw_add_sub_ch1), .mux_ctrlout(mw_ctrl_out_ch1), .write_enable(mw_write_enable_ch1), .count_enable(mw_count_enable_ch1), .mux_addr_ctrl(mw_addr_ctrl_ch1), .difference(other_address_diff));
	
	short_window_FSM short_window_ctrl0(.clk(clk), .rst(rst), .start(sw_start_ch0), .counter(counter), .enable0(sw_enable0_ch0), .butterfly_counter(butterfly_counter), .mux_add_sub(sw_add_sub_ch0), .mux_ctrlout(sw_ctrl_out_ch0), .write_enable(sw_write_enable_ch0), .count_enable(sw_count_enable_ch0), .mux_addr_ctrl(sw_addr_ctrl_ch0), .difference(other_address_diff)); //granule_ch0_write_enable has to be multiplexed
	short_window_FSM short_window_ctrl1(.clk(clk), .rst(rst), .start(sw_start_ch1), .counter(counter), .enable0(sw_enable0_ch1), .butterfly_counter(butterfly_counter), .mux_add_sub(sw_add_sub_ch1), .mux_ctrlout(sw_ctrl_out_ch1), .write_enable(sw_write_enable_ch1), .count_enable(sw_count_enable_ch1), .mux_addr_ctrl(sw_addr_ctrl_ch1), .difference(other_address_diff));
	
	rom_alias_reduction_ca get_ca(.clk(clk), .enable(1'b1), .index(const_index), .data(ca));
	rom_alias_reduction_cs get_cs(.clk(clk), .enable(1'b1), .index(const_index), .data(cs));
	
	
	datapath dp0(.clk(clk), .rst(rst), .ca(ca), .cs(cs), .mux_ctrl_add_sub(mux_add_sub_ch0), .mux_ctrlout(mux_ctrl_out_ch0), .enable0(enable0_ch0), .read_data(granule_ch0_read_data), .mux_addr_ctrl(mux_addr_ctrl_ch0), .counter(counter), .other_addr(other_address), .out(granule_ch0_write_data), .read_addr(granule_ch0_read_addr));
	datapath dp1(.clk(clk), .rst(rst), .ca(ca), .cs(cs), .mux_ctrl_add_sub(mux_add_sub_ch1), .mux_ctrlout(mux_ctrl_out_ch1), .enable0(enable0_ch1), .read_data(granule_ch1_read_data), .mux_addr_ctrl(mux_addr_ctrl_ch1), .counter(counter), .other_addr(other_address), .out(granule_ch1_write_data), .read_addr(granule_ch1_read_addr));
endmodule








module datapath(input wire clk,
                 input wire rst,
                 input wire signed [17:0] ca,
                 input wire signed [17:0] cs,
                 input wire mux_ctrl_add_sub,
                 input wire mux_ctrlout,
                 input wire enable0,
                 input wire[17:0] read_data,
                 input wire mux_addr_ctrl,
                 input wire [9:0] counter,
                 input wire [9:0] other_addr,
                 output wire signed [17:0] out,
                 output wire [9:0] read_addr
                 );
    wire signed [17:0]  cs_in,
                        ca_in,
                        add_out,
                        sub_out,
                        out_0,
                        in_0,
                        in_1;
                
    assign in_1 = read_data;
                
    register #(.N(18)) reg0(.clk(clk), .rst(rst), .enable(enable0), .dataIn(read_data), .dataOut(in_0));
    
    arith18_mul mul_cs_in(.op1(cs), .op2(in_0), .product(cs_in));
    arith18_mul mul_ca_in(.op1(ca), .op2(in_1), .product(ca_in));
    
    arith18_add add(.op1(cs_in), .op2(ca_in), .sum(add_out));
	arith18_sub sub(.op1(cs_in), .op2(ca_in), .difference(sub_out));
	
	multiplexer_2 mux_add_sub(.muxin(mux_ctrl_add_sub), .a(sub_out), .b(add_out), .out(out_0));
	
	multiplexer_2 mux_out(.muxin(mux_ctrlout), .a(in_0), .b(out_0), .out(out));
	
	multiplexer_2_10bit mux_addr(.muxin(mux_addr_ctrl), .a(counter), .b(other_addr), .out(read_addr));

endmodule












module long_window_FSM(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [9:0] difference,
    input wire[9:0] counter,
    input wire[3:0] butterfly_counter,
    output reg enable0,
    output reg mux_add_sub,
    output reg write_enable,
    output reg count_enable,
    output reg mux_addr_ctrl,
    output reg mux_ctrlout
);
    localparam 
        idle = 0,
        load0 = 1,
        load1 = 2,
        calc_write = 3;
        
    reg[1:0] state;
    reg[1:0] nextstate;
    
    always @(posedge clk) begin
        if(!rst) begin
            state <= nextstate;
        end else begin
            state <= idle;
        end
    end
    
    always @(*) begin
    nextstate = idle;
        if(difference < 0)begin
            mux_add_sub = 1;
        end else begin
            mux_add_sub = 0;
        end
        case(state)
            idle: begin
                if(start) nextstate = load0;
            end
            load0: nextstate = load1;
            load1: nextstate = calc_write;
            calc_write: begin
                if(counter == 575) begin
                    nextstate = idle;
                end else begin
                    nextstate = load0;
                end
            end
        endcase
    end
    
    always @(*) begin
        enable0 = 0;
        write_enable = 0;
        count_enable = 0;
        mux_addr_ctrl = 0;
        mux_ctrlout = 0;
        case (state)
            load0: mux_addr_ctrl = 0;
            load1: begin
                mux_addr_ctrl = 1;
                enable0 = 1;
            end
            calc_write: begin
                write_enable = 1;
                count_enable = 1;
                if(butterfly_counter != 8 && counter > 8 && counter < 567) mux_ctrlout = 1;
            end
        endcase
    end
endmodule

module mixed_window_FSM(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [9:0] difference,
    input wire[9:0] counter,
    input wire[3:0] butterfly_counter,
    output reg enable0,
    output reg mux_add_sub,
    output reg write_enable,
    output reg count_enable,
    output reg mux_addr_ctrl,
    output reg mux_ctrlout
);
    localparam 
        idle = 0,
        load0 = 1,
        load1 = 2,
        calc_write = 3;
        
    reg[1:0] state;
    reg[1:0] nextstate;
    
    always @(posedge clk) begin
        if(!rst) begin
            state <= nextstate;
        end else begin
            state <= idle;
        end
    end
    
    always @(*) begin
        nextstate = idle;
        mux_add_sub = 0;
        if(counter > 35) begin
            case(state)
                idle: begin
                    if(start) nextstate = load0;
                end
                load0: nextstate = load1;
                load1: nextstate = calc_write;
                calc_write: begin
                    if(counter == 575) begin
                        nextstate = idle;
                    end else begin
                        nextstate = load0;
                    end
                end
            endcase
        end else begin
            if(difference < 0)begin
                mux_add_sub = 1;
            end else begin
                mux_add_sub = 0;
            end
            case(state)
                idle: begin
                    if(start) nextstate = load0;
                end
                load0: nextstate = load1;
                load1: nextstate = calc_write;
                calc_write: begin
                    if(counter == 575) begin
                        nextstate = idle;
                    end else begin
                        nextstate = load0;
                    end
                end
            endcase
        end
    end
    
    always @(*) begin
        enable0 = 0;
        write_enable = 0;
        count_enable = 0;
        mux_addr_ctrl = 0;
        mux_ctrlout = 0;
        case (state)
            load0: mux_addr_ctrl = 0;
            load1: begin
                mux_addr_ctrl = 1;
                enable0 = 1;
            end
            calc_write: begin
                write_enable = 1;
                count_enable = 1;
                if(butterfly_counter != 8 && counter > 8 && counter < 26) mux_ctrlout = 1; //onle the first subbands are being calculated
            end
        endcase
    end
endmodule

module short_window_FSM(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [9:0] difference,
    input wire[9:0] counter,
    input wire[3:0] butterfly_counter,
    output reg enable0,
    output reg mux_add_sub,
    output reg write_enable,
    output reg count_enable,
    output reg mux_addr_ctrl,
    output reg mux_ctrlout
);
    localparam 
        idle = 0,
        load0 = 1,
        load1 = 2,
        calc_write = 3;
        
    reg[1:0] state;
    reg[1:0] nextstate;
    
    always @(posedge clk) begin
        if(!rst) begin
            state <= nextstate;
        end else begin
            state <= idle;
        end
    end
    
    always @(*) begin
        nextstate = idle;
        case(state)
            idle: begin
                if(start) nextstate = load0;
            end
            load0: nextstate = load1;
            load1: nextstate = calc_write;
            calc_write: begin
                if(counter == 575) begin
                    nextstate = idle;
                end else begin
                    nextstate = load0;
                end
            end
        endcase
    end
    
    always @(*) begin
        enable0 = 0;
        write_enable = 0;
        count_enable = 0;
        mux_addr_ctrl = 0;
        mux_ctrlout = 0;
        case (state)
            load0: mux_addr_ctrl = 0;
            load1: enable0 = 1;
            calc_write: begin
                write_enable = 1;
                count_enable = 1;
                mux_ctrlout = 0;
            end
        endcase
    end
endmodule