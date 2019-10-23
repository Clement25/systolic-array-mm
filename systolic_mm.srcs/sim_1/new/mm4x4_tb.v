`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/24 02:38:06
// Design Name: 
// Module Name: mm4x4_tb
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


module mm4x4_tb();
parameter BW=16;
parameter ROW=4;
parameter LOG_RAM_DEPTH=2;

reg clk, rst, load;
reg pe_en, buf_wea;

// expose input array as port input
reg signed[BW-1:0] a_row1;
reg signed[BW-1:0] a_row2;
reg signed[BW-1:0] a_row3;
reg signed[BW-1:0] a_row4;

reg signed[BW-1:0] b_row1;
reg signed[BW-1:0] b_row2;
reg signed[BW-1:0] b_row3;
reg signed[BW-1:0] b_row4;

reg [LOG_RAM_DEPTH-1:0] addr;
reg [LOG_RAM_DEPTH-1:0] addr_res_read;

wire signed[2*BW:0] c_col1;
wire signed[2*BW:0] c_col2;
wire signed[2*BW:0] c_col3;
wire signed[2*BW:0] c_col4;
wire done;

mm4x4
#(
    .BW(BW),
    .ROW(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   uut (
    .clk(clk),
    .rst(rst),

    // here load indicates loading multiplier
    .load(load),

    // enable process engine
    .pe_en(pe_en),
    .buf_wea(buf_wea),

    // expose input array as port input
    .a_row1(a_row1),
    .a_row2(a_row2),
    .a_row3(a_row3),
    .a_row4(a_row4),
    
    .b_row1(b_row1),
    .b_row2(b_row2),
    .b_row3(b_row3),
    .b_row4(b_row4),
    
    .addr(addr),
    .addr_res_read(addr_res_read),
    
    .c_col1(c_col1),
    .c_col2(c_col2),
    .c_col3(c_col3),
    .c_col4(c_col4),
    .done(done)
);

initial begin
    #5
    clk=0; rst=1; load=0;
    pe_en=0; buf_wea=0;
    # 15
    rst=0; buf_wea=1;
    addr = 2'b00;
    a_row1 = 1; a_row2 = 0; a_row3 =0; a_row4 = 0;
    b_row1 = -2; b_row2 = 3; b_row3 = 3; b_row4 = 5;
    # 10
    addr = 2'b01;
    a_row1 = 0; a_row2 = 1; a_row3 =0; a_row4 = 0;
    b_row1 = 9; b_row2 = -8; b_row3 = -6; b_row4 = 8;
    # 10
    addr = 2'b10;
    a_row1 = 0; a_row2 = 0; a_row3 =1; a_row4 = 0;
    b_row1 = 12; b_row2 = -3; b_row3 = 7; b_row4 = 4;
    # 10
    addr = 2'b11;
    a_row1 = 0; a_row2 = 0; a_row3 =0; a_row4 = 1;
    b_row1 = -5; b_row2 = 4; b_row3 = 2; b_row4 = 10;
    # 10
    // TODO: MOVE THIS PART INSIDE PE
    buf_wea=0; load=1;
    addr = 2'b00;
    # 10
    addr = 2'b01;
    # 10
    addr = 2'b10;
    # 10
    addr = 2'b11;
    # 10
    load = 0; pe_en=1;
    # 300
    addr_res_read = 2'b00;
    # 10
    addr_res_read = 2'b01;
    # 10
    addr_res_read = 2'b10;
    # 10
    addr_res_read = 2'b11;
end

always #5 clk=~clk;
endmodule
