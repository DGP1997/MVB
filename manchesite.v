



module manchesite(
			input 			clk_3M,       //3Mhz时钟信号
			input           clk_6M,       //6Mhz时钟信号
			input 			data_in,      //输入数据
			input 			rst,          //复位信号
			output reg 		data_out      //输出数据
);

	always @(posedge clk_6M)begin
		if(rst==1'b0) begin
			data_out<=1'b0;
		end else  begin
			data_out<=data_in^(~clk_3M);
		end
	end

endmodule
