/*****************************************************
编码控制单元：整个编码模块的控制单元��?



*****************************************************/

module EncodeCtrl (
		input 				rst,                    //��λ�ź�
		input 				clk,                    //24Mhzʱ��
		input				clk_6M,                 //6Mhzʱ��
		input				clk_3M,                 //3Mhzʱ��
		
		input 				send_frame,             //֡�����ź�
		input[6:0]			data_length,            //���ݳ���
		input				master_frame,           //���͵�֡Ϊ��֡
		input 				slave_frame,            //���͵�֡Ϊ��֡
		
		
		output reg[1:0]	    delimiter_format,       //֡�ֽ����ʽ
		output reg[1:0]	    multi_sel,              //��·ѡ���ź�
		
		output reg			manchesite_en,          //����˹�ر���ʹ���ź�
		output reg			crc_en,                 //CRCģ��ʹ���ź�
		output reg          multi_en,              //��·ѡ����ʹ���ź�
		output reg			deserialize_en,        //����ת��ʹ���ź�
		output reg			delimiter_en,          //�ֽ������ʹ���ź�
		
		output reg			data_read,             //����ת��ģ��������ź�
		output reg			data_send,             //����ת��ģ��ת�������������ź�
		output reg			delimiter_send,        //֡�ֽ�������ź�
		output reg   		crc_send,              //CRCУ�����з����ź�
		output reg			crc_ready,             //CRC�����ź�
		output reg			frame_over             //֡��������ź�

)/*synthesis preserve*/;
	parameter IDLE=4'b0000;                    //�ȴ�״̬
	parameter SET_SF=4'b0001;                  //�ñ�־λ״̬
	parameter SEND_HEADER=4'b0010;             //��ʼ����֡��ʼ�ֽ��״̬
	parameter HEADER_WAIT=4'b0011;             //�ȴ�������ʼ�ֽ��״̬
	parameter SEND_DATA=4'b0100;               //��ʼ��������״̬
	parameter DATA_WAIT=4'b0101;               //�ȴ���������״̬
	parameter SEND_CRC=4'b0110;                //��ʼ����CRCУ����״̬
	parameter CRC_WAIT=4'b0111;                //�ȴ�����CRCУ����״̬
	parameter SEND_TRAIL=4'b1000;              //��ʼ������ֹ�ֽ��״̬
	parameter TRAIL_WAIT=4'b1001;              //�ȴ�����֡�ֽ��״̬
	parameter DELAY_SF=4'b1010;                //�����־λ״̬
	
	//reg[3:0] 	clkcount;

	reg[3:0] 	next_state;
	
	reg[4:0] 	data_counter=5'h1;
	
	reg[6:0] 	word_counter=7'h0;
	reg[3:0] 	crc_counter=4'h0;
	reg[3:0]   	current_state;
	reg[4:0]   	delimiter_counter=5'h0;
	
	reg		delimiter_count_en;
	reg		data_count_en;
	reg		crc_count_en;
	reg    	send_frame_f;

	
	reg    	end_flag;
	reg    	willend_flag;
	reg    	crc_end;
	
	

	
	
	always @(posedge clk_6M  ) begin
		if(delimiter_count_en==1'b0)begin
			delimiter_counter<=5'h0;
		end else begin
			delimiter_counter<=delimiter_counter+5'h1;
		end
	end
	
	always @(negedge clk_3M) begin
	   if(send_frame==1'b1)begin
	       send_frame_f<=1'b1;
	   end else begin
	       send_frame_f<=1'b0;
	   end
	end
	
	always @(posedge clk_3M )begin
		if(send_frame_f==1'b1) begin
			word_counter<=5'h0;
		end
		if(data_counter==5'h10)begin
		   word_counter<=word_counter+1;
		end		
	end
	
	always @(posedge clk_3M ) begin

		if(data_count_en==1'b0)begin
			data_counter<=5'b00001;
		end else begin
			data_counter<=data_counter+1;
			if(data_counter==5'b10000)begin
			     data_counter<=5'b00001;
			end

		end
	end
	
	always @(posedge clk_3M  or negedge crc_count_en)begin
		if(crc_count_en==1'b0)begin
			crc_counter<=4'h0;
		end else begin
			crc_counter<=crc_counter+1;
		end
	end
	
	
	
	/*always @(posedge clk ) begin
		if(rst==1'b0) begin
			clkcount<=4'h0;
		end else begin
			clkcount<=clkcount+1;
		end
	end*/
	
	always @(posedge clk)begin
		if(rst==1'b0)begin
			current_state<=IDLE;
		end else begin
			current_state<=next_state;
		end
	end
	
	always @(*) begin
		if(rst==1'b0)begin
			next_state<=IDLE;
			manchesite_en<=1'b0;
			crc_en<=1'b0;
			data_read<=1'b0;
			data_send<=1'b0;
			crc_send<=1'b0;
			delimiter_send<=1'b0;
			crc_ready<=1'b0;
			multi_en<=1'b0;
			deserialize_en<=1'b0;
			delimiter_en<=1'b0;	
			data_count_en<=1'b0;
			delimiter_count_en<=1'b0;
			crc_count_en<=1'b0;
			data_count_en<=1'b0;
			frame_over<=1'b0;
			end_flag<=1'b0;
			willend_flag<=1'b0;
			crc_end<=1'b0;
		    multi_sel<=2'b00;
			delimiter_format<=2'b00;			
		end else begin
			/*next_state<=next_state;
			manchesite_en<=manchesite_en;
			crc_en<=crc_en;
			data_read<=data_read;
			data_send<=data_send;
			crc_send<=crc_send;
			delimiter_send<=delimiter_send;
			crc_ready<=crc_ready;
			multi_en<=multi_en;
			deserialize_en<=deserialize_en;
			delimiter_en<=delimiter_en;	
			data_count_en<=data_count_en;
			delimiter_count_en<=delimiter_count_en;
			crc_count_en<=crc_count_en;
			data_count_en<=data_count_en;
			frame_over<=frame_over;
			end_flag<=end_flag;
			willend_flag<=willend_flag;
			crc_end<=crc_end;	
		    multi_sel<=multi_sel;
			delimiter_format<=delimiter_format;*/
		case (current_state)
		
			IDLE:begin
				manchesite_en<=1'b0;
				crc_en<=1'b0;
				crc_ready<=1'b0;
				multi_en<=1'b0;
				deserialize_en<=1'b0;
				delimiter_en<=1'b0;
				delimiter_count_en<=1'b0;
				delimiter_send<=1'b0;
				data_read<=1'b0;
				data_send<=1'b0;
				crc_ready<=1'b0;
				crc_send<=1'b0;
				crc_count_en<=1'b0;
				data_count_en<=1'b0;
				data_count_en<=1'b0;
				end_flag<=1'b0;
				willend_flag<=1'b0;
				frame_over<=1'b0;
				crc_end<=1'b0;
				if(send_frame_f==1'b1)begin
					next_state<=SET_SF;
				end else begin
					next_state<=IDLE;
				end
			end
			
			SET_SF:begin
				deserialize_en<=1'b1;
				delimiter_en<=1'b1;
				manchesite_en<=1'b0;
				multi_en<=1'b1;
				next_state<=SEND_HEADER;
			end
		
			SEND_HEADER:begin
			   manchesite_en<=1'b0;
				deserialize_en<=1'b1;
				data_count_en<=1'b0;
				delimiter_en<=1'b1;
				multi_en<=1'b1;
				multi_sel<=2'b01;
				delimiter_count_en<=1'b1;
				if(master_frame==1'b1&&slave_frame==1'b0)begin
					delimiter_format<=2'b01;
				end else if(master_frame==1'b0&&slave_frame==1'b1)begin
					delimiter_format<=2'b10;
				end
				next_state<=HEADER_WAIT;
			end
			
			HEADER_WAIT:begin
			    manchesite_en<=1'b0;
				data_count_en<=1'b0;
				data_read<=1'b1;
			    if(delimiter_counter>=5'h1)begin
                    manchesite_en<=1'b1;
                    delimiter_send<=1'b1;
                    data_read<=1'b0;
			    end
				if(master_frame==1'b1&&slave_frame==1'b0)begin
                    delimiter_format<=2'b01;
                end else if(master_frame==1'b0&&slave_frame==1'b1)begin
                    delimiter_format<=2'b10;
                end			
				deserialize_en<=1'b1;
                delimiter_en<=1'b1;
                multi_en<=1'b1;
                multi_sel<=2'b01;
                delimiter_send<=1'b1;
                delimiter_count_en<=1'b1;			
				if(delimiter_counter==5'h011||delimiter_counter==5'h12||delimiter_counter==5'h10)begin
				    data_read<=1'b1;
				    data_send<=1'b0;
				end
				if(delimiter_counter==5'h13) begin
					delimiter_count_en<=1'b0;
					delimiter_send<=1'b0;
					next_state<=SEND_DATA;
				end else begin
					next_state<=HEADER_WAIT;
				end
			end
			
			SEND_DATA:begin
				data_read<=1'b1;
                data_send<=1'b0;			
                data_count_en<=1'b1;
                multi_en<=1'b1;                    
                crc_en<=1'b1;
                crc_ready<=1'b1;
                crc_send<=1'b0;
                multi_sel<=2'b10;
				deserialize_en<=1'b1;
                manchesite_en<=1'b1;				                        
				next_state<=DATA_WAIT;
			end
			
			DATA_WAIT:begin
				deserialize_en<=1'b1;			
                data_count_en<=1'b1;
                crc_en<=1'b1;
                crc_ready<=1'b1;
                crc_send<=1'b0;
                multi_sel<=2'b10;
                multi_en<=1'b1;
                manchesite_en<=1'b1;                                	               		
			     if(data_counter==5'h01)begin
                   data_read<=1'b0;
                   data_send<=1'b1;
                end 
				if(data_counter==5'h10)begin
                    data_send<=1'b0;
                    if((word_counter+1)%4==0)begin
                        data_read<=1'b0;
                    end else begin
                        data_read<=1'b1;
                    end
                    if(word_counter==data_length-1)begin
                       willend_flag<=1'b1;
                    end else begin
                        willend_flag<=1'b0;
                    end
                end 
                if(data_counter==5'h02)begin
                    /*if(willend_flag==1'b1)begin
                        data_read<=1'b0;
                    end*/
                    if(word_counter%4==0&&word_counter!=5'h0)begin
                        crc_end<=1'b1;
                    end else begin
                        crc_end<=1'b0;
                    end
                end                
				if(((word_counter%4==0)||(word_counter==data_length))&&(word_counter!=5'h0)&&(crc_end==1'b0))begin				    
					next_state<=SEND_CRC;
					if(word_counter==data_length)begin
					   end_flag<=1'b1;
					end
				end else begin
					next_state<=DATA_WAIT;
				end
			end
			
			SEND_CRC:begin
                crc_count_en<=1'b1;
                crc_en<=1'b1;
                data_count_en<=1'b0;
                data_read<=1'b0;
                data_send<=1'b0;
                multi_sel<=2'b11;
                multi_en<=1'b1;                
                crc_send<=1'b1;
                crc_ready<=1'b1;
                manchesite_en<=1'b1;
                delimiter_send<=1'b0;
				if(crc_counter==4'h07&&end_flag==1'b1)begin
				    delimiter_count_en<=1'b1;					    			    				   
	             end else if(crc_counter==4'h07)begin
	               data_read<=1'b1;
	               data_send<=1'b0;
	             end
	             if(delimiter_counter==5'h1)begin
                    delimiter_send<=1'b1;
                    delimiter_en<=1'b1;
                    delimiter_format<=2'b11;    	             
	             end
				if(crc_counter==4'h08)begin
				    crc_end<=1'b1;
				    multi_sel<=2'b01;
					next_state<=CRC_WAIT;
				end else begin
				    next_state<=SEND_CRC;
				end
			end
			
			CRC_WAIT:begin
				crc_send<=1'b0;
				crc_en<=1'b0;
				crc_ready<=1'b0;
				crc_count_en<=1'b0;
				crc_end<=1'b1;
                multi_sel<=2'b11;
                multi_en<=1'b1;
                manchesite_en<=1'b1; 				
				if(word_counter==data_length)begin
				    delimiter_count_en<=1'b1;	
                    delimiter_send<=1'b1;
                    delimiter_en<=1'b1;
                    delimiter_format<=2'b11;
                    crc_send<=1'b0;
                    multi_sel<=2'b01;				
					next_state<=SEND_TRAIL;
				end else begin
					data_read<=1'b0;
					data_send<=1'b1;
                    data_count_en<=1'b1;
                    crc_en<=1'b1;
                    crc_send<=1'b0;
                    crc_ready<=1'b1;
                    multi_sel<=2'b10;					
					next_state<=DATA_WAIT;
				end
			end
			
			SEND_TRAIL:begin
				delimiter_send<=1'b1;
				delimiter_format<=2'b11;
				delimiter_en<=1'b1;
				delimiter_count_en<=1'b1;
				data_send<=1'b0;
				data_read<=1'b0;
				data_count_en<=1'b0;
				multi_sel<=2'b01;
                multi_en<=1'b1;				
                manchesite_en<=1'b1;	
                crc_send<=1'b0;			
				if(delimiter_counter==5'h6)begin
					next_state<=TRAIL_WAIT;
				end else begin
					next_state<=SEND_TRAIL;
				end
			end
			
			TRAIL_WAIT:begin
				delimiter_count_en<=1'b0;
				delimiter_send<=1'b0;
				manchesite_en<=1'b0;
				manchesite_en<=1'b0;
                multi_en<=1'b0;
                delimiter_en<=1'b0;
                deserialize_en<=1'b0;
                data_count_en<=1'b0;
                delimiter_count_en<=1'b0;
                crc_count_en<=1'b0;
                frame_over<=1'b1;				
				next_state<=DELAY_SF;
			end
			
			DELAY_SF:begin
				manchesite_en<=1'b0;
				multi_en<=1'b0;
				delimiter_en<=1'b0;
				deserialize_en<=1'b0;
				data_count_en<=1'b0;
				delimiter_count_en<=1'b0;
				crc_count_en<=1'b0;
				frame_over<=1'b1;
				next_state<=IDLE;
			end
			
			default:begin
				next_state<=IDLE;
			end
		endcase
		end
	end

	
endmodule
