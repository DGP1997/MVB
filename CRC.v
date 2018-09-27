/********************************************







********************************************/

module CRC(
			input clk_1d5M,       	    //3Mhzʱ���źţ���������Ч
			input data_in,			    //��������
			input rst,					//��λ�ź�
			input ready,				//У����������ʹ��
			input send,					//���з���CRCУ������ʹ��
			output reg		 crc_o,	    //���У���ź�
			output reg[7:0]  crc_c     //�����8λУ����
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
