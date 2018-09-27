`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 09:19:06
// Design Name: 
// Module Name: start_check
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


module start_check(
           input            rst,                //复位信号
           input            clk_24M,            //24M时钟信号
           input            data_in,            //输入数据
           output reg      frame_start         //帧起始位检测有效信号
    );
    
    reg     org_data;
    
    always @(posedge clk_24M)begin
        org_data<=data_in;
    end
    
    always @(posedge clk_24M) begin
        if(rst==1'b0)begin
            frame_start<=1'b0;
        end else begin
            if(frame_start==1'b0&&(org_data==1'b1&&data_in==1'b0))begin
                frame_start<=1'b1;
            end else begin
                frame_start<=1'b0;
            end
        end
    end
    
endmodule
