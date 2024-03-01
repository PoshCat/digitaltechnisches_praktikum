module compute(input wire clk,
                    input wire rst,
                    input wire [9:0] base_addr,
                    input wire [1:0] block_type_2bit, // short == 0, long == 1;
                    input wire [17:0] read_data,
                    input wire start,
                    input wire all_ready,
                    output wire [9:0] read_addr,
                    output wire [17:0] computed_value_0,
                    output wire [5:0] index_0,
                    output wire [17:0] computed_value_1,
                    output wire [5:0] index_1,
                    output wire compute_done,
                    output wire band_done
                    );
                    wire [9:0] read_addr_long;
                    wire [17:0] computed_value_0_long;
                    wire [5:0] index_0_long;
                    wire [17:0] computed_value_1_long;
                    wire [5:0] index_1_long;
                    wire compute_done_long;
                    wire band_done_long;
                    
                    wire [9:0] read_addr_short;
                    wire [17:0] computed_value_0_short;
                    wire [5:0] index_0_short;
                    wire [17:0] computed_value_1_short;
                    wire [5:0] index_1_short;
                    wire compute_done_short;
                    wire band_done_short;
    
        wire block_type;

        assign block_type = ~(block_type_2bit[1] & ~block_type_2bit[0]); //changed

    compute_long long(.clk(clk), .rst(rst), .base_addr(base_addr), .block_type(block_type), .read_data(read_data), .read_addr(read_addr_long), .computed_value_0(computed_value_0_long), .index_0(index_0_long), .computed_value_1(computed_value_1_long), .index_1(index_1_long), .compute_done(compute_done_long) ,.band_done(band_done_long), .all_ready(all_ready) , .start(start));
    compute_short short(.clk(clk),.rst(rst),.base_addr(base_addr),.block_type(block_type),.read_data(read_data), .read_addr(read_addr_short), .computed_value_0(computed_value_0_short), .index_0(index_0_short), .computed_value_1(computed_value_1_short), .index_1(index_1_short), .compute_done(compute_done_short), .band_done(band_done_short) ,. all_ready(all_ready), .start(start));

    multiplexer_2_Nbit #(.N(10)) value_0_out(.muxin(block_type), .a(read_addr_short), .b(read_addr_long), .out(read_addr));
    multiplexer_2_Nbit #(.N(18)) value_computed_0_out(.muxin(block_type), .a(computed_value_0_short), .b(computed_value_0_long), .out(computed_value_0));
    multiplexer_2_Nbit #(.N(6)) index_0_out(.muxin(block_type), .a(index_0_short), .b(index_0_long), .out(index_0));
    multiplexer_2_Nbit #(.N(18)) value_computed_1_out(.muxin(block_type), .a(computed_value_1_short), .b(computed_value_1_long), .out(computed_value_1));
    multiplexer_2_Nbit #(.N(6)) index_1_out(.muxin(block_type), .a(index_1_short), .b(index_1_long), .out(index_1));
    multiplexer_2_Nbit #(.N(1)) compute_done_out(.muxin(block_type), .a(compute_done_short), .b(compute_done_long), .out(compute_done));
    multiplexer_2_Nbit #(.N(1)) band_done_out(.muxin(block_type), .a(band_done_short), .b(band_done_long), .out(band_done));
endmodule


module compute_long(input wire clk,
                    input wire rst,
                    input wire [9:0] base_addr,
                    input wire block_type, // short == 0, long == 1;
                    input wire [17:0] read_data,
                    input wire all_ready, //write new value, all steps are ready
                    input wire start, //calculate new subband
                    output reg [9:0] read_addr,
                    output reg signed [17:0] computed_value_0,
                    output reg [5:0] index_0,
                    output reg signed [17:0] computed_value_1,
                    output reg [5:0] index_1,
                    output reg compute_done,
                    output reg band_done
                    );

    wire [17:0] cos_value;
    wire [17:0] computed_value;  
    wire [17:0] sumreg_computedvalue_add;  
    wire [17:0] sum_neg;
    
    reg [1:0] state, nextstate;
    reg [5:0] n;
    reg [4:0] k;
    reg [17:0] sum_reg;

    rom_imdct_cosimdctlong l(.clk(clk), .enable(block_type), .n(n), .k(k), .data(cos_value));
    
    arith18_mul multiply_values(.op1(read_data), .op2(cos_value), .product(computed_value));
    arith18_add add_val_reg(.op1(computed_value), .op2(sum_reg), .sum(sumreg_computedvalue_add));
    
    arith18_sub neg(.op1(18'd0),.op2(sum_reg),.difference(sum_neg));
    
    localparam idle = 2'b0;
    localparam calculating = 2'b01;
    localparam waiting = 2'b10;

    always @(posedge clk) begin
        if(rst)begin
            state <= idle;
        end else begin
            state <= nextstate;
        end
    end
    
    always @(posedge clk) begin
    if(rst) begin
        n <= 9;
        k <= 0;
        sum_reg <= 0; //changed
        compute_done <= 0;
    end else begin
        if(state == calculating && nextstate == waiting)begin
            compute_done <= 1;
        end else begin
            compute_done <= 0;
        end
        case(state)
            idle: begin
                n <= 9;
                k <= 0;
                sum_reg <= 0;
            end
            waiting: begin
                if(all_ready) begin
                    if(n != 27) begin
                        n <= n+1;
                        k <= 0;
                        sum_reg <= 0;
                    end
                end
            end
            
            calculating: begin
                k <= k + 1;
                if( k > 0) begin
                    sum_reg <= sumreg_computedvalue_add;
                end else begin
                    sum_reg <= 0;
                end
                
            end
        endcase
    end
    end

    always @(*)begin
        nextstate = idle;
        case(state)
            calculating: begin
                if(k == 18) begin
                    nextstate = waiting;
                end else begin
                    nextstate = calculating;
                end
            end
            waiting: begin
                if(all_ready)begin
                    if(n != 27)begin
                        nextstate = calculating;
                    end
                end else begin
                    nextstate = waiting;
                end
            end
            idle: begin
                if(start && block_type)begin
                    nextstate =  calculating;
                end 
            end
        endcase
    end

    always @(*) begin
        read_addr = 0;
        computed_value_0 = 0;
        index_0 = 0;
        computed_value_1 = 0;
        index_1 = 0;
        band_done = 0;
        case(state)
            idle: begin
                band_done = 1;
            end
            calculating: begin
                read_addr = base_addr + k;
            end
            waiting: begin
                index_0 = n;
                computed_value_0 = sum_reg;
                if(n < 18)begin
                    index_1 = 17-n;
                    if(sum_reg == 0) begin
                        computed_value_1 = sum_reg;
                    end else begin
                        computed_value_1 = (~sum_reg) +1; // changed
                    end
                end else begin
                    index_1 = 53-n;
                    computed_value_1 = sum_reg;
                end
            end
        endcase
    end
endmodule


module compute_short(input wire clk,
                    input wire rst,
                    input wire [9:0] base_addr,
                    input wire block_type, // short == 0, long == 1;
                    input wire [17:0] read_data,
                    input wire all_ready,
                    input wire start,
                    output reg [9:0] read_addr,
                    output reg [17:0] computed_value_0,
                    output reg [5:0] index_0,
                    output reg [17:0] computed_value_1,
                    output reg [5:0] index_1,
                    output reg compute_done,
                    output reg band_done
                    );


    wire [17:0] cos_value;
    wire [17:0] computed_value;
    wire [17:0] window_data;
    wire [17:0] sumreg_computedvalue_add;
    wire [17:0] sumreg_toadd_add;
    wire [17:0] sumreg_toadd_sub;
    wire [17:0] toadd_sumreg_sub;
    wire [17:0] toadd_neg;
    
    reg [4:0] ksample;
    reg [2:0] kcos;
    reg [1:0] state, nextstate;
    reg [5:0] counter;
    reg [4:0] k;
    reg [17:0] sum_reg;
    reg [17:0] value_to_add;
    reg [3:0] n;
    
    wire [17:0] sum_windowed;
    rom_imdct_cosimdctshort s(.clk(clk), .enable(~block_type), .n(n), .k(kcos), .data(cos_value));
    rom_imdct_sinwindow win_0(.clk(clk), .enable(~block_type), .window(2'b10), .n({2'b00,n}), .data(window_data));
    arith18_mul multiply_values(.op1(read_data), .op2(cos_value), .product(computed_value));
    
    arith18_mul window_mult(.op1(window_data), .op2(sum_reg), .product(sum_windowed));
    arith18_add add_val_reg(.op1(computed_value), .op2(sum_reg), .sum(sumreg_computedvalue_add));
    arith18_add toadd_reg_add(.op1(value_to_add), .op2(sum_reg), .sum(sumreg_toadd_add));
    arith18_sub toadd_reg_sub(.op1(value_to_add), .op2(sum_reg), .difference(toadd_sumreg_sub));
    arith18_sub reg_toadd_sub(.op1(sum_reg), .op2(value_to_add), .difference(sumreg_toadd_sub));
    
    arith18_sub neg(.op1(18'd0),.op2(value_to_add),.difference(toadd_neg));
    
    localparam idle = 2'b0;
    localparam calculating_1 = 2'b01;
    localparam calculating_2 = 2'b10;
    localparam waiting = 2'b11;

    always @(posedge clk) begin
        if(rst)begin
            state <= idle;
        end else begin
            state <= nextstate;
        end
    end

    always @(posedge clk) begin
        if(rst)begin
            k <= 0;
            kcos <= 0;
            ksample <= 0;
            counter <= 0;
            sum_reg <= 0;
            value_to_add <= 0;
            compute_done <= 0;
        end else begin
            if(state == calculating_2 && nextstate == waiting)begin
                compute_done <= 1;
            end else begin
                compute_done <= 0;
            end
            case(state)
                idle: begin
                    counter <= 0;
                    k <= 0;
                    sum_reg <= 0;
                    value_to_add <= 0;
                    kcos <= 0;
                    ksample <= 0;
                end
                calculating_1:begin
                    if(k == 21) begin
                        value_to_add <= sum_windowed;
                    end
                    if(counter < 6)begin
                        k <= 21;
                        sum_reg <= 0;
                    end
                    if(counter > 8 && counter < 15)begin
                        if(k != 21) begin
                            if(k > 0)sum_reg <= sumreg_computedvalue_add;
                        end else begin
                            sum_reg <= 0;
                        end
                        if(k != 21)begin 
                            k <= k+3;
                            kcos <= kcos +1;
                            ksample <= k+3;
                         end else begin
                            k <= 0;
                            kcos <= 0;
                            ksample <= 2;
                         end
                    end
                    if(counter > 20 && counter < 27)begin
                        if(k != 21) begin
                            if(k > 0)sum_reg <= sumreg_computedvalue_add;
                        end else begin
                            sum_reg <= 0;
                        end
                        if(k != 21) begin
                            k <= k+3;
                            kcos <= kcos +1;
                            ksample <= k + 5;
                        end else begin
                            k <= 0;
                            kcos <= 0;
                            ksample <= 2;
                        end
                    end
                    
                end
                calculating_2: begin
                    if(counter > 11 && counter < 15)begin
                        if(k < 21)begin
                            if(k > 0)sum_reg <= sumreg_computedvalue_add;
                        end else begin
                            sum_reg <= sum_windowed;
                        end
                        k <= k+3;
                        kcos <= kcos +1;
                        ksample <= k + 4;
                    end
                    if(counter > 20 && counter < 24)begin
                        if(k < 21) begin
                            if(k > 0)sum_reg <= sumreg_computedvalue_add;
                        end else begin
                            sum_reg <= sum_windowed;
                        end
                        k <= k+3;
                        kcos <= kcos +1;
                        ksample <= k + 4;
                    end
                    if(counter < 12 || counter > 23)begin
                        k <= 21;
                        sum_reg <= 0;
                    end
                end
                waiting: begin
                    if(all_ready)begin
                        if(counter != 26)begin
                            k <= 0;
                            kcos <= 0;
                            if(counter > 20 && counter < 27) begin
                                ksample <= 1;
                            end else begin
                                ksample <= 0;
                            end
                            sum_reg <= 0;
                            if(counter == 14)begin
                                counter <= 21;
                            end else if(counter == 5)begin
                                counter <= 9;
                            end else begin
                                counter <= counter + 1;
                            end
                        end
                    end
                end
            endcase
        end
    end

    always @(*)begin
        nextstate = idle;
        case(state)
            calculating_1: begin
                if(k == 21) begin
                    nextstate = calculating_2;                    
                end else begin
                    nextstate = calculating_1;
                end
            end
            calculating_2: begin
                if(k == 21) begin
                    nextstate = waiting;
                end else begin
                    nextstate = calculating_2;
                end
            end
            waiting: begin
                if(all_ready)begin
                    if(counter != 26)begin
                        nextstate = calculating_1;
                    end
                end else begin
                    nextstate = waiting;
                end
            end
            idle: begin
                if(start && ~block_type)begin
                    nextstate =  calculating_1;
                end 
            end
        endcase
    end

    always @(*) begin
        read_addr = 0;
        computed_value_0 = 0;
        index_0 = 0;
        computed_value_1 = 0;
        index_1 = 0;
        band_done = 0;
        n = 0;
        case(state)
            idle: begin
                band_done = 1;
            end
            calculating_1: begin
                if(counter > 8 && counter < 15)begin
                    read_addr = base_addr + ksample;
                    n = counter - 9;
                end
                if(counter > 20 && counter < 26)begin
                    read_addr = base_addr + ksample;
                    n = counter - 21;
                end
            end
            calculating_2:begin
                if(counter > 11 && counter < 15)begin
                    read_addr = base_addr + ksample;
                    n = counter - 12;
                end
                if(counter > 20 && counter < 24)begin
                    read_addr = base_addr + ksample;
                    n = counter - 18;
                end
            end

            waiting: begin
                index_0 = counter;
                if(counter < 6)begin
                    index_1 = 35-counter;
                    computed_value_0 = sum_reg;
                    computed_value_1 = sum_reg;
                end
                if(counter > 8 && counter < 12)begin
                    index_1 = counter - 3;
                    computed_value_0 = value_to_add;
                    if(value_to_add == 0)begin
                        computed_value_1 = value_to_add;
                    end else begin
                        if(value_to_add != 0)begin
                            computed_value_1 = toadd_neg;
                        end else begin
                            computed_value_1 = value_to_add;
                        end
                    end
                end
                if(counter > 11 && counter < 15)begin
                    index_1 = counter + 3;
                    computed_value_0 = toadd_sumreg_sub;
                    computed_value_1 = sumreg_toadd_add;
                end
                if(counter > 20 && counter < 24)begin
                    index_1 = counter - 3;
                    computed_value_0 = sumreg_toadd_add;
                    computed_value_1 = sumreg_toadd_sub;
                end
                if(counter > 23 && counter < 27)begin
                    index_1 = counter + 3;
                    computed_value_0 = value_to_add;
                    computed_value_1 = value_to_add;
                end
            end
        endcase
    end
endmodule