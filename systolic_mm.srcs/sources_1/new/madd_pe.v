`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/23 14:31:22
// Design Name: 
// Module Name: madd_pe
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

module madd_pe
#(
    parameter BW = 16
)
(
    input clk,
    input rst,
    // signal to load multiplier
    input load,
    input en,
    input signed [BW-1:0] in_x,
    input signed [BW-1:0] in_y,
    // x direction: shift one multiplicand to the right
    output signed [BW-1:0] out_x,
    // y direction: multiplication output
    output signed [BW*2:0] out_y
);

reg signed[BW-1:0] reg_a;
reg signed[BW-1:0] reg_b;
reg signed[2*BW:0] reg_res;

assign out_x = reg_a;
assign out_y = reg_res;

always@(posedge clk)begin
    if(rst) begin
        reg_a <= 0;
        reg_b <= 0;
        reg_res <= 0;
    end
    else if(load) begin
//  load multipliers
        reg_a <= in_x;
        reg_b <= in_x;
    end
    else if(en) begin
        reg_a <= in_x;
        reg_res <= in_x * reg_b + in_y;
    end
end
endmodule
