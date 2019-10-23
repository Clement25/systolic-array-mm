`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/23 16:32:44
// Design Name: 
// Module Name: mm4x4
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

module mm4x4
#(
    parameter BW = 16,
    parameter ROW = 4,
    parameter LOG_RAM_DEPTH = 2
)
(
    input clk,
    input rst,

    // here load indicates loading multiplier
    input load,

    // enable process engine
    input pe_en,
    input buf_wea,

    // expose input array as port input
    input signed[BW-1:0] a_row1,
    input signed[BW-1:0] a_row2,
    input signed[BW-1:0] a_row3,
    input signed[BW-1:0] a_row4,
    
    input signed[BW-1:0] b_row1,
    input signed[BW-1:0] b_row2,
    input signed[BW-1:0] b_row3,
    input signed[BW-1:0] b_row4,
    
    input [LOG_RAM_DEPTH-1:0] addr,
    input [LOG_RAM_DEPTH-1:0] addr_res_read,
    
    output signed[2*BW:0] c_col1,
    output signed[2*BW:0] c_col2,
    output signed[2*BW:0] c_col3,
    output signed[2*BW:0] c_col4,
    output done
);

// connect read buffer to first column
wire signed[BW-1:0] x_buf_11, x_buf_21, x_buf_31, x_buf_41;

wire signed[BW-1:0] x_11_12, x_12_13, x_13_14;
wire signed[BW-1:0] x_21_22, x_22_23, x_23_24;
wire signed[BW-1:0] x_31_32, x_32_33, x_33_34;
wire signed[BW-1:0] x_41_42, x_42_43, x_43_44;

wire signed[2*BW:0] y_11_21, y_21_31, y_31_41;
wire signed[2*BW:0] y_12_22, y_22_32, y_32_42;
wire signed[2*BW:0] y_13_23, y_23_33, y_33_43;
wire signed[2*BW:0] y_14_24, y_24_34, y_34_44;

wire signed[2*BW:0] y_41_cbuf,y_42_cbuf,y_43_cbuf,y_44_cbuf;
wire [LOG_RAM_DEPTH-1:0] addr_res_1,addr_res_2,addr_res_3,addr_res_4;
wire [LOG_RAM_DEPTH-1:0] addr_a1, addr_a2, addr_a3, addr_a4;

// ram out
wire signed[BW-1:0] dout_a_1, dout_a_2, dout_a_3, dout_a_4;
wire signed[BW-1:0] dout_b_1, dout_b_2, dout_b_3, dout_b_4;

// global counter
reg [3:0] count;
reg reg_done;

// valid bit
reg valid_1, valid_2, valid_3, valid_4;
// read in address
reg [LOG_RAM_DEPTH-1:0] addr_rd_1, addr_rd_2, addr_rd_3, addr_rd_4;
// write back address
reg [LOG_RAM_DEPTH-1:0] addr_wb_1, addr_wb_2, addr_wb_3, addr_wb_4;

assign done = reg_done;

assign x_buf_11 = load ? dout_b_1 : dout_a_1;
assign x_buf_21 = load ? dout_b_2 : dout_a_2;
assign x_buf_31 = load ? dout_b_3 : dout_a_3;
assign x_buf_41 = load ? dout_b_4 : dout_a_4;

assign addr_a1 = pe_en ? addr_rd_1 : addr;
assign addr_a2 = pe_en ? addr_rd_2 : addr;
assign addr_a3 = pe_en ? addr_rd_3 : addr;
assign addr_a4 = pe_en ? addr_rd_4 : addr;

assign addr_res_1 = valid_1 ? addr_wb_1 : addr_res_read;
assign addr_res_2 = valid_2 ? addr_wb_2 : addr_res_read;
assign addr_res_3 = valid_3 ? addr_wb_3 : addr_res_read;
assign addr_res_4 = valid_4 ? addr_wb_4 : addr_res_read;

always@(posedge clk)begin
    if(rst) begin
        reg_done <= 0;
        count <= 0;
        valid_1 <= 0;
        valid_2 <= 0;
        valid_3 <= 0;
        valid_4 <= 0;
    end
    else if(pe_en) begin
        if(!reg_done)
            count <= count + 1;
            addr_rd_1 <= addr_rd_1 + 1;
            addr_rd_2 <= addr_rd_2 + 1;
            addr_rd_3 <= addr_rd_3 + 1;
            addr_rd_4 <= addr_rd_4 + 1;
        if(count == 1) begin
            addr_rd_1 <= 0;
        end
        if(count == 2) begin
            addr_rd_2 <= 0;
        end
        if(count == 3) begin
            addr_rd_3 <= 0;
        end
        if(count == 4) begin
            addr_rd_4 <= 0;
        end
        if(count == 5) begin
            valid_1 <= 1'b1;
            addr_wb_1 <= 2'b0;
        end
        if(count == 6) begin
            valid_2 <= 1'b1;
            addr_wb_2 <= 2'b0;
        end
        if(count == 7) begin
            valid_3 <= 1'b1;
            addr_wb_3 <= 2'b0;
        end
        if(count == 8) begin
            valid_4 <= 1'b1;
            addr_wb_4 <= 2'b0;
        end
        if(count == 9)
            valid_1 <= 1'b0;
        if(count == 10)
            valid_2 <= 1'b0;
        if(count == 11)
            valid_3 <= 1'b0;
        if(count == 12) begin
            valid_4 <= 1'b0;
            count <= 0;
            reg_done <= 1;
        end
    end
end

always@(posedge clk)begin
    if(valid_1)
        addr_wb_1 <= addr_wb_1 + 1;
    if(valid_2)
        addr_wb_2 <= addr_wb_2 + 1;
    if(valid_3)
        addr_wb_3 <= addr_wb_3 + 1;
    if(valid_4)
        addr_wb_4 <= addr_wb_4 + 1;
end

// instantiate buffer
ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_a_row1(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr_a1),
    .data_in(a_row1),
    .data_out(dout_a_1)
);

ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_a_row2(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr_a2),
    .data_in(a_row2),
    .data_out(dout_a_2)
);

ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_a_row3(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr_a3),
    .data_in(a_row3),
    .data_out(dout_a_3)
);

ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_a_row4(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr_a4),
    .data_in(a_row4),
    .data_out(dout_a_4)
);

ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_b_row1(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr),
    .data_in(b_row1),
    .data_out(dout_b_1)
);

ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_b_row2(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr),
    .data_in(b_row2),
    .data_out(dout_b_2)
);

ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_b_row3(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr),
    .data_in(b_row3),
    .data_out(dout_b_3)
);

ram_buffer #(
    .BW(BW),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_b_row4(
    .clk(clk),
    .rst(rst),
    .wea(buf_wea),
    .addr(addr),
    .data_in(b_row4),
    .data_out(dout_b_4)
);

ram_buffer #(
    .BW(2*BW+1),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_c_col1(
    .clk(clk),
    .rst(rst),
    .wea(valid_1),
    .addr(addr_res_1),
    // .addr(addr_res_read),
    .data_in(y_41_cbuf),
    .data_out(c_col1)
);

ram_buffer #(
    .BW(2*BW+1),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_c_col2(
    .clk(clk),
    .rst(rst),
    .wea(valid_2),
    .addr(addr_res_2),
    .data_in(y_42_cbuf),
    .data_out(c_col2)
);

ram_buffer #(
    .BW(2*BW+1),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_c_col3(
    .clk(clk),
    .rst(rst),
    .wea(valid_3),
    .addr(addr_res_3),
    .data_in(y_43_cbuf),
    .data_out(c_col3)
);

ram_buffer #(
    .BW(2*BW+1),
    .RAM_DEPTH(ROW),
    .LOG_RAM_DEPTH(LOG_RAM_DEPTH)
)   buffer_c_col4(
    .clk(clk),
    .rst(rst),
    .wea(valid_4),
    .addr(addr_res_4),
    .data_in(y_44_cbuf),
    .data_out(c_col4)
);

madd_pe #(
    .BW(BW)
)   pe_1_1(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_buf_11),
    // The first row has no accumulate results
    .in_y(0),
    .out_x(x_11_12),
    .out_y(y_11_21)
);

madd_pe #(
    .BW(BW)
)   pe_1_2(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_11_12),
    // The first row has no accumulate results
    .in_y(0),
    .out_x(x_12_13),
    .out_y(y_12_22)
);

madd_pe #(
    .BW(BW)
)   pe_1_3(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_12_13),
    .in_y(0),
    .out_x(x_13_14),
    .out_y(y_13_23)
);

madd_pe #(
    .BW(BW)
)   pe_1_4(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_13_14),
    .in_y(0),
    .out_x(),
    .out_y(y_14_24)
);

madd_pe #(
    .BW(BW)
)   pe_2_1(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_buf_21),
    .in_y(y_11_21),
    .out_x(x_21_22),
    .out_y(y_21_31)
);

madd_pe #(
    .BW(BW)
)   pe_2_2(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_21_22),
    .in_y(y_12_22),
    .out_x(x_22_23),
    .out_y(y_22_32)
);

madd_pe #(
    .BW(BW)
)   pe_2_3(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_22_23),
    .in_y(y_13_23),
    .out_x(x_23_24),
    .out_y(y_23_33)
);

madd_pe #(
    .BW(BW)
)   pe_2_4(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_23_24),
    .in_y(y_14_24),
    .out_x(),
    .out_y(y_24_34)
);

madd_pe #(
    .BW(BW)
)   pe_3_1(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_buf_31),
    .in_y(y_21_31),
    .out_x(x_31_32),
    .out_y(y_31_41)
);

madd_pe #(
    .BW(BW)
)   pe_3_2(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_31_32),
    .in_y(y_22_32),
    .out_x(x_32_33),
    .out_y(y_32_42)
);

madd_pe #(
    .BW(BW)
)   pe_3_3(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_32_33),
    .in_y(y_23_33),
    .out_x(x_33_34),
    .out_y(y_33_43)
);

madd_pe #(
    .BW(BW)
)   pe_3_4(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_33_34),
    .in_y(y_24_34),
    .out_x(),
    .out_y(y_34_44)
);

madd_pe #(
    .BW(BW)
)   pe_4_1(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_buf_41),
    .in_y(y_31_41),
    .out_x(x_41_42),
    .out_y(y_41_cbuf)
);

madd_pe #(
    .BW(BW)
)   pe_4_2(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_41_42),
    .in_y(y_32_42),
    .out_x(x_42_43),
    .out_y(y_42_cbuf)
);

madd_pe #(
    .BW(BW)
)   pe_4_3(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_42_43),
    .in_y(y_33_43),
    .out_x(x_43_44),
    .out_y(y_43_cbuf)
);

madd_pe #(
    .BW(BW)
)   pe_4_4(
    .clk(clk),
    .rst(rst),
    .load(load),
    .en(pe_en),
    .in_x(x_43_44),
    .in_y(y_34_44),
    .out_x(),
    .out_y(y_44_cbuf)
);
endmodule

