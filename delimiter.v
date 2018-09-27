/****************************************************
分界符生成模块：产生主帧和从帧的帧分界符





******************************************************/

module delimiter (
			input 		reset,				//��λ�ź�
            input 		clk_3M,				//6Mhzʱ���źţ���������Ч
			input 		send_delimiter,     //���ͷֽ��ʹ��
			input[1:0]	delimiter_format,   //֡��ʽ��01����֡��ʼ��  10����֡��ʼ��  11��֡�����ֽ����
			output reg	delimiter_out		//�������

);


	parameter  M_delimiter=18'b11_10_01_00_10_01_00_00_00;  
	parameter  S_delimiter=18'b11_11_11_11_01_10_11_01_10;  
	parameter  frame_end=4'b0110;
	reg[5:0]  index;
	
	
	always @(posedge clk_3M )begin
	   if(reset==1'b0)begin
	       index<=1'b0;
	   end else if(send_delimiter==1'b1) begin
	       index<=index+1;
           if(delimiter_format==2'b01&&index==6'h12)begin
                index<=0;
           end else if(delimiter_format==2'b10&&index==6'h12)begin
                index<=0;
           end else if(delimiter_format==2'b11&&index==6'h03)begin
                index<=0;
           end 
        end
	end
	
	
	always @( posedge clk_3M  ) begin
		if(reset==1'b0)begin
			delimiter_out<=1'b0;
		end else if(send_delimiter==1'b1) begin	      
			case(delimiter_format) 
				2'b01: begin
					delimiter_out<=M_delimiter[17-index];
				end
				2'b10:begin
					delimiter_out<=S_delimiter[17-index];
				end
				2'b11:begin
					delimiter_out<=frame_end[3-index];
				end
				default:begin
				    delimiter_out<=1'b0;
				end
			endcase
		end else if(send_delimiter==1'b0)begin
			delimiter_out<=1'b0;
		end
	end

endmodule
