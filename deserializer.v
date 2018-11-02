`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 14:07:12
// Design Name: 
// Module Name: deserializer
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
module deserializer(
        input               clk_3M,                 //3Mhz时钟
        input               rst,                    //复位信号
        input               deserializer_wait,      //串并转换暂停信号
        input               data_in,                //输入数据
        output reg[15:0]    data_preserve,          //输出数据
        output reg          data_get_o,             //16位数据有效信号
		  output reg			 data_get_org
    );
    
    reg[4:0]    index=5'h0;
	 reg[15:0]	 data_pre=16'h0;
    reg         data_get;
    reg         pre_rst;
	 reg			 pre_pre_rst;
	 reg[15:0] 	 data_out=16'h0;
    
    always @(posedge clk_3M ) begin
        data_get_org<=data_get;
        pre_rst<=rst;
		  pre_pre_rst<=pre_rst;
        if(rst==1'b0)begin
            data_out<=16'h0000;
            index<=5'h0;
				data_get_org<=1'b0;
        end else if(deserializer_wait==1'b0) begin
            index<=index+1;
            if(index==5'hf)begin
                index<=5'h0;
            end
            data_out[15-index]<=data_in;
        end else begin
            data_out<=data_out;
            index<=5'h0;
        end
    end
    

    
	 always @(posedge data_get)begin
		if(rst==1'b0)begin
			data_preserve<=16'h0000;
		end else begin
			data_preserve<=data_out;
		end
	 end
	 
    always @(negedge clk_3M)begin
        if(data_get_org==1'b0&&data_get==1'b1)begin
            data_get_o<=1'b1;
        end else begin
            data_get_o<=1'b0;
        end
    end
    
    always @(posedge clk_3M) begin
        if(rst==1'b0)begin
            data_get<=1'b0;
        end else begin
            if(index==5'h0&&pre_rst!=1'b0)begin
                data_get<=1'b1;
            end else begin
                data_get<=1'b0;
            end
        end
    end
    
    
endmodule
