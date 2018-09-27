`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 13:23:21
// Design Name: 
// Module Name: crc_check
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

(*DONT_TOUCH="true"*)
module crc_check(
            input           clk_3M,             //3M时钟信号
            input           rst,                //复位信号
            input           crc_ready,          //CRC校验序列生成信号
            input           crc_read,           //CRC校验码输入信号
            input           data_in,            //输入数据
            output reg      crc_error          //CRC校验错误
    )/* synthesis syn_preserve = 1*/;
    
    reg[7:0]     crc_c/*synthesis noprune*/;
    reg[7:0]     crc_code/*synthesis noprune*/;
    reg[7:0]     crc_get/*synthesis noprune*/;
    reg[3:0]     index/*synthesis noprune*/;
    
    always @(posedge clk_3M )begin
        if(rst==1'b0)begin
            crc_c<=8'h0;
            crc_get<=8'h0;
            crc_code<=8'h0;
            index<=4'h0;
        end else if(crc_ready==1'b1&&crc_read==1'b0) begin
            crc_c[1]<=crc_c[7]^data_in;
            crc_c[2]<=crc_c[1];
            crc_c[3]<=crc_c[2]^(data_in^crc_c[7]);
            crc_c[4]<=crc_c[3];
            crc_c[5]<=crc_c[4];
            crc_c[6]<=crc_c[5]^(data_in^crc_c[7]);
            crc_c[7]<=crc_c[6]^(data_in^crc_c[7]);
            crc_c[0]<=data_in^(^crc_c[7:1])^((data_in^crc_c[7])^1'b0);
            crc_get<=8'h0;
            crc_code<={crc_c[6]^(data_in^crc_c[7]),crc_c[5]^(data_in^crc_c[7]),crc_c[4],crc_c[3],crc_c[2]^(data_in^crc_c[7]),crc_c[1],crc_c[7]^data_in,data_in^(^crc_c[7:1])^((data_in^crc_c[7])^1'b0)};
            index<=4'h0;
        end else if(crc_ready==1'b1&&crc_read==1'b1)begin
            crc_code<=crc_code;
            crc_get[7-index]<=data_in;
            index<=index+1;
            if(index==4'h8)begin
                index<=4'h0;
                crc_c<=8'h0;
            end
        end
    end
    
    always @(*)begin
        if(rst==1'b0)begin
            crc_error<=1'b0;
        end else if(index==4'h9)begin
            if(crc_get==crc_code)begin
                crc_error<=1'b0;
            end else begin
                crc_error<=1'b1;
            end
        end else begin
            crc_error<=1'b0;
        end
    end
    
endmodule
