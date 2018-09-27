/**************************************************************
涓插苟杞崲妯″潡锛氬皢甯т腑鐨勬暟鎹拰鏍￠獙鐮佺敱骞惰鐨勬柟寮忚浆鍖栦负涓茶鏂瑰紡杈撳嚭

				








*****************************************************************/

module Deserialize(
			input 					clk_1d5M,    //3Mhz时钟信号，上升沿有效
			input 					reset,		//复位信号
			input[15:0]				data_in,	//16位输入数据
			input 					shift,		//并串转换使能
			input 					read,		//读取FIFO数据使能
			output reg 				dout 		//转换结果
);
	
	reg [4:0]        index;
	reg[15:0]        data;
	always@(posedge clk_1d5M ) begin
		if(reset==1'b0) begin
			data<=16'h0;
			dout<=1'b0;
			index<=5'h0;
		end else begin
			if(read==1'b1)begin
				data<=data_in;
				dout<=data_in[15];
				index<=5'h0;
			end else if(shift==1'b1) begin
				dout<=data[14-index];
                index<=index+1;
			end else if(shift==1'b0)begin
			    dout<=1'b0;
			    data<=16'h0;
			    index<=5'h0;
			end
		end 

	end   //end of always 
endmodule
