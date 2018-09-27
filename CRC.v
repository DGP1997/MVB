/********************************************







********************************************/

module CRC(
			input clk_1d5M,       	    //3Mhz时钟信号，上升沿有效
			input data_in,			    //输入数据
			input rst,					//复位信号
			input ready,				//校验序列生成使能
			input send,					//串行发送CRC校验序列使能
			output reg		 crc_o,	    //输出校验信号
			output reg[7:0]  crc_c     //保存的8位校验码
);
    reg[3:0]  index;
	always @(posedge clk_1d5M)begin
		if(rst==1'b0)begin
			crc_c<=8'h0;
			index<=4'h0;
			crc_o<=1'b0;
		end else if(ready==1'b0)begin
			crc_c<=8'h0;
			index<=4'h0;
			crc_o<=1'h0;
		end else if(ready==1'b1&&send==1'b0)begin
			crc_c[1]<=crc_c[7]^data_in;
			crc_c[2]<=crc_c[1];
			crc_c[3]<=crc_c[2]^(data_in^crc_c[7]);
			crc_c[4]<=crc_c[3];
			crc_c[5]<=crc_c[4];
			crc_c[6]<=crc_c[5]^(data_in^crc_c[7]);
			crc_c[7]<=crc_c[6]^(data_in^crc_c[7]);
			crc_c[0]<=data_in^(^crc_c[7:1])^((data_in^crc_c[7])^1'b0);
			index<=4'h0;
			crc_o<=crc_c[6]^(data_in^crc_c[7]);
		end else if(ready==1'b1&&send==1'b1)begin
            crc_o<=crc_c[6-index];
            index<=index+1;
            if(index+1==8)begin
                crc_c<=8'h0;
            end
		end 
	end
endmodule
