`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2016 16:44:18
// Design Name: 
// Module Name: requantize_calculations
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


module requantize_calculations(
    input  wire clk,
    input  wire rst,	 
	 
// ==================================================
// 576 lines
// --------------------------------------------------	 
	 
	 output wire  [9:0] granule_read_addr,
	 input  wire [17:0] granule_read_data,	 

	 output reg         granule_write_enable,
	 output reg   [9:0] granule_write_addr, 
	 output reg  [17:0] granule_write_data,	 
	 
// ==================================================
// scale factors
// --------------------------------------------------	  	 

	 output wire  [1:0] scalfac_short_read_addr_window,
	 output wire  [3:0] scalfac_short_read_addr_index,			 
	 input  wire  [3:0] scalfac_short_read_data,
	 
	 output wire  [5:0] scalfac_long_read_addr,
	 input  wire  [3:0] scalfac_long_read_data,
	 
// ==================================================
// sideinfo information
// --------------------------------------------------	  
	 
	 input  wire        sideinfo_scalefac_scale,
	 input  wire        sideinfo_preflag,
	 input  wire  [7:0] sideinfo_global_gain,
	 input  wire  [2:0] sideinfo_subblock_gain,
	 
// ==================================================
// interface to parent state machine
// --------------------------------------------------   

	 input  wire        start,         // start the computation for the given input data
	 output wire        ready,         // the module is ready to receive the next set of data in the NEXT clock cycle
	 output reg         active,        // the module is still doing some computation or data access
	 input  wire  [9:0] index,         // the index of the data to process
	 input  wire  [4:0] cb,            // the cb variable
     input  wire  [1:0] window,        // the window variable
     input  wire        calc_mode      // the type of calculation (CALC_MODE_SHORT or CALC_MODE_LONG)

    );
    
    // This is a very simple implementation which does all computing steps
    // after another. This could also be done in a 5 stage pipeline.
    
    // states
    localparam
        STATE_IDLE = 0,
        STATE_GET_INPUT = 1,
        STATE_EXPONENT_COMPUTE = 2,
        STATE_FUNCTION_LOOKUP = 3,
        STATE_MULTIPLICATION = 4;
        
    // calculation mode
    localparam
        CALC_MODE_SHORT = 0,
        CALC_MODE_LONG  = 1;

    // real registers
    reg [2:0] state;                    // the current state
    
    reg [17:0] input_abs;               // stores the absolute value of the input
    reg        input_sign;              // stores the sign of the input
    reg  [8:0] exponent;                // stores the computed exponent
    
    // combinational regs
    reg [12:0] input_abs_comb;          // the absolute value of the input
    reg        input_sign_comb;         // the sign of the input
    reg [8:0]  exponent_comb;           // the computed exponent
    reg [8:0]  summand1, summand2, summand3, summand4;      // the summands of the exponent
    reg [31:0] product;                 // the final product
    reg [17:0] non_inverted_output;     // the absolute value of the output
    reg [17:0] output_comb;             // the final output
    reg  [3:0] scalefac_selected;       // the relevant scalefac value
    
    // wires
    wire  [1:0] pretab;                 // output of the pretab table
    wire [17:0] pow43_result;           // output of the pow43 table
    wire [31:0] exp_result;             // output of the exp table
    
    
    // direct forwarding of scalefactor and data addresses
    assign scalfac_short_read_addr_window = window;
    assign scalfac_short_read_addr_index = cb[3:0];
    assign scalfac_long_read_addr = cb;
    assign granule_read_addr = index;
    
    // selection of the scalefactor
    always @(*) begin
        if (calc_mode == CALC_MODE_SHORT)
            scalefac_selected = scalfac_short_read_data;
        else begin
            scalefac_selected = scalfac_long_read_data;
        end
    end
    
    // combinational computation of absolute and sign
    always @(*) begin
        input_sign_comb = granule_read_data[17];
        if (input_sign_comb)
            input_abs_comb = (18'd0 - granule_read_data);
        else
            input_abs_comb = granule_read_data;
    end
    
    // combinational computation of the exponent
    always @(*) begin
        if (calc_mode == CALC_MODE_LONG && sideinfo_preflag)
            summand1 = sideinfo_scalefac_scale ? {5'b00000, pretab, 2'b00} : {6'b000000, pretab, 1'b0};
        else
            summand1 = 0;
            
        summand2 = sideinfo_scalefac_scale ? {3'b000, scalefac_selected, 2'b00} : {4'b0000, scalefac_selected, 1'b0};
        summand3 = 9'd255 - {1'b0, sideinfo_global_gain};
        
        if (calc_mode == CALC_MODE_SHORT)
            summand4 = {3'b000, sideinfo_subblock_gain, 3'b000};
        else
            summand4 = 0;
            
        exponent_comb = (summand1 + summand2) + (summand3 + summand4);
    end
    
    // combinational computation of the output value
    always @(*) begin
        product = exp_result * pow43_result;
        // The result needs to be shifted right by 4 bits
        // to have the correct fixed point format.
        non_inverted_output = product[21:4];
        if (input_sign)
            output_comb = 18'd0-non_inverted_output;
        else
            output_comb = non_inverted_output;
    end
    
    
    // lookup ROMs
    rom_requantize_pretab rom_pretab (
        .clk(clk),
        .enable(1'b1),
        .cb(cb),
        .data(pretab)
    );
    
    rom_requantize_pow43 rom_pow43 (
        .clk(clk),
        .enable(1'b1),
        .base(input_abs[12:0]),
        .data(pow43_result)
    );
    
    rom_requantize_exp rom_exp (
        .clk(clk),
        .enable(1'b1),
        .exponent(exponent),
        .data(exp_result)
    );


    // the state machine
    always @(posedge clk) begin
        
        if(rst) begin
            state <= STATE_IDLE;
            active <= 0;
            granule_write_enable <= 0;
         
        end
        else begin
            granule_write_enable <= 0;

            case(state)
                // the idle state, waiting for input
                STATE_IDLE: begin
                    if(start) begin
                        state <= STATE_GET_INPUT;
                        active <= 1;
                    end
                end    
                  
                // just wait a clock cycle for the memories to deliver the data  
                STATE_GET_INPUT: begin
                    state <= STATE_EXPONENT_COMPUTE;
                end
                
                // compute the exponent
                STATE_EXPONENT_COMPUTE: begin
                    exponent <= exponent_comb;
                    input_abs <= input_abs_comb;
                    input_sign <= input_sign_comb;
                    
                    state <= STATE_FUNCTION_LOOKUP;                    
                end
                
                // wait another clock cycle for function lookup
                STATE_FUNCTION_LOOKUP: begin
                    state <= STATE_MULTIPLICATION;
                end
                
                // do the final multiplication
                STATE_MULTIPLICATION: begin
                    granule_write_data <= output_comb;
                    granule_write_addr <= index;
                    granule_write_enable <= 1;
                    state <= STATE_IDLE;
                    active <= 0;
                end
        
                default: begin
                    state <= STATE_IDLE;                    
                end
                
            endcase
        end
    end
    
    // module is ready if the next state is the idle state
    assign ready = (state == STATE_MULTIPLICATION) || (state == STATE_IDLE && !start);
        
endmodule
