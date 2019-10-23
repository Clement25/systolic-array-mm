`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/24 02:30:01
// Design Name: 
// Module Name: ram_buf
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

module ram_buffer 
#(
    parameter BW=16,
    parameter RAM_DEPTH=4,
    parameter LOG_RAM_DEPTH=2
)
(
    input clk,
    input rst,
    input wea,
    input [LOG_RAM_DEPTH-1:0]addr,
    input [BW-1:0] data_in,
    output [BW-1:0] data_out
);

reg [BW-1:0] data_ram[0:RAM_DEPTH];

assign data_out = data_ram[addr];

integer i;

always@(posedge clk)begin
    if(rst)begin
        for(i=0;i<RAM_DEPTH;i=i+1)begin
            data_ram[i] <= 0;
        end
    end
    else if(wea) begin
        data_ram[addr] <= data_in;
    end
end
endmodule
