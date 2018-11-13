`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 09:38:11
// Design Name: 
// Module Name: delimiter_check
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


module delimiter_check(
            input           rst,                    //复位信号
            input           clk_3M,                 //3M时钟信号
            input           clk_6M,                 //6M时钟信号
            input           data_in,                //输入数据
            input           frame_end_check,        //帧末尾信号
				input				 SF_check,
            output reg      M_frame,               //主帧起始信号
            output reg      S_frame,               //从帧起始信号
            output reg      E_frame,               //帧终止信号
            output reg      E_delimit,             //分界符错误信号
            output reg      E_length               //长度错误信号
    );
    reg[4:0]        delimiter_counter=5'h0;
    reg[15:0]       delimiter_in=16'h0;
    wire            data;
	 parameter      M_delimiter=16'b1100011100010101;  
    parameter      S_delimiter=16'b1010100011100011;  
    parameter      E_delimiter=4'b0011;
    
    
    assign data=data_in^clk_3M;
    
    always @(negedge clk_6M or negedge rst)begin
        if(rst==1'b0)begin
            delimiter_in<=16'h0;
            delimiter_counter<=5'h0;
        end else begin
				if(SF_check==1'b1||frame_end_check==1'b1)begin
					delimiter_in[0]<=data_in;
					delimiter_in[15:1]<=delimiter_in[14:0];
				end else begin
					delimiter_in<=16'h0;
				end
				if(SF_check==1'b1) begin
					delimiter_counter<=delimiter_counter+1;
				end else begin
					delimiter_counter<=5'h0;
				end
        end
    end
    
    always @(*) begin
        if(rst==1'b0)begin
            M_frame<=1'b0;
            S_frame<=1'b0;
            E_frame<=1'b0;
            E_delimit<=1'b0;
            E_length<=1'b0;
        end else if(frame_end_check==1'b1)begin
            if(delimiter_in[3:0]==E_delimiter)begin
                M_frame<=1'b0;
                S_frame<=1'b0;
                E_frame<=1'b1;
                E_delimit<=1'b0;
                E_length<=1'b0;                
            end  else begin
                M_frame<=1'b0;
                S_frame<=1'b0;
                E_frame<=1'b0;
                E_delimit<=1'b0;            
                E_length<=1'b0;
            end
        end  else if(delimiter_counter==5'h11&&SF_check==1'b1)begin
                if(delimiter_in==M_delimiter)begin
                    M_frame<=1'b1;
                    S_frame<=1'b0;
                    E_frame<=1'b0;
                    E_delimit<=1'b0;
                    E_length<=1'b0;
                end else if(delimiter_in==S_delimiter)begin
                    S_frame<=1'b1;
                    M_frame<=1'b0;
                    E_frame<=1'b0;
                    E_delimit<=1'b0;
                    E_length<=1'b0;                
                end else begin
                    S_frame<=1'b0;
                    M_frame<=1'b0;
                    E_frame<=1'b0;
                    E_delimit<=1'b1;
                    E_length<=1'b0;
                end
        end else begin
            M_frame<=M_frame;
            S_frame<=S_frame;
            E_frame<=E_frame;
            E_delimit<=1'b0;
            E_length<=E_length;            
        end
     end
     

    
    
    
endmodule
