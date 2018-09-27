/**************************************************************
串并转换模块：将帧中的数据和校验码由并行的方式转化为串行方式输出

				








*****************************************************************/

module Deserialize(
			input 					clk_1d5M,    //3Mhzʱ���źţ���������Ч
			input 					reset,		//��λ�ź�
			input[15:0]				data_in,	//16λ��������
			input 					shift,		//����ת��ʹ��
			input 					read,		//��ȡFIFO����ʹ��
			output reg 				dout 		//ת�����
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
