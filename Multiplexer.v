/********************************************************
多路选择模块：根据主控模块发出的控制信号选择通过分界符或数据或CRC校验�?





********************************************************/

module Multiplexer (
				input[1:0] 		sel,                    //ѡ���ź�
				input			delimiter_out,          //�ֽ������
				input			crc_out,                //CRCУ����������
				input 			data_out,               //����ת������
				input 			multi_en,               //ģ��ʹ���ź�
				output reg		multi_out               //���
);

	always @(*)begin
		if(multi_en==1'b0)begin
			multi_out=1'b0;
		end else begin
			case(sel) 
				2'b01: multi_out=delimiter_out;  
				2'b10: multi_out=data_out;       
				2'b11: multi_out=crc_out;
				2'b00: multi_out=1'b0;
			endcase
		end
	end

endmodule
