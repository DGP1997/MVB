`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 11:19:37
// Design Name: 
// Module Name: demanchesite
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


module demanchesite(
            input           rst,                //复位信号
            input           clk_24M,            //24M时钟信号
            input           data_in,            //数据输入
            output  reg     data_out,          //数据输出
            output  reg     signal_error,      //信号错误
            output  reg     quality_error      //信号质量错误
    );
    
    reg[4:0]    counter;
    reg[3:0]    data;
    
    always @(posedge clk_24M)begin
        if(rst==1'b0)begin
            counter<=5'h1;
        end else begin
            counter<=counter+1;
            if(counter==5'h0f)begin
                counter<=5'h0;
            end
        end
    end
    
    
    always @(posedge clk_24M)begin
        if(rst==1'b0)begin
            data_out<=1'b0;
            signal_error<=1'b0;
            quality_error<=1'b0;
            data<=4'h0;
        end else if(counter==5'h2)begin
            data[0]<=data_in;
        end else if(counter==5'h6)begin
            data[1]<=data_in;
        end else if(counter==5'ha)begin
            data[2]<=data_in;
        end else if(counter==5'he)begin
            data[3]<=data_in;
        end else if(counter==5'hf)begin
            if(data[1]==data[2])begin
                quality_error<=1'b1;
            end else if(data[0]==1'b1&&data[3]==1'b0)begin
                data_out<=1'b1;
            end else if(data[0]==1'b0&&data[3]==1'b1)begin
                data_out<=1'b0;
            end else begin
                signal_error<=1'b1;
            end
        end
    end
    
    
endmodule
