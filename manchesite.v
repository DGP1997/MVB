



module manchesite(
			input 			clk_3M,       //3Mhzʱ���ź�
			input           clk_6M,       //6Mhzʱ���ź�
			input 			data_in,      //��������
			input 			rst,          //��λ�ź�
			output reg 		data_out      //�������
);

	always @(posedge clk_6M)begin
		if(rst==1'b0) begin
			data_out<=1'b0;
		end else  begin
			data_out<=data_in^(~clk_3M);
		end
	end

endmodule
