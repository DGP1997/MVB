`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 14:25:59
// Design Name: 
// Module Name: decode_ctr
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


module decode_ctr(
            input           clk_24M,                //24Mʱ���ź�
            input           clk_6M,                 //6Mʱ���ź�
            input           clk_3M,                 //3Mʱ���ź�
            input           rst,                    //��λ�ź�
            input           frame_start,            //֡��ʼ�ź�
            input           S_frame,                //��֡�ֽ��
            input           M_frame,                //��֡�ֽ��
            input           E_frame,                //֡��ֹ�ֽ��
            input           delimiter_error,        //֡�ֽ������
            input           crc_error,              //crcУ�����
            input           length_error,           //���ȴ���
            input           signal_error,           //�źŴ���
            input           quality_error,          //�ź���������
            input [4:0]     frame_length,           //֡����
				output  reg		 SF_check,
            output  reg     clk_en,                //֡ͬ��ʱ��ʹ��
            output  reg     start_check_en,         //��ʼλ���ģ��ʹ��
            output  reg     delimiter_check_en,     //�ֽ�����ģ��ʹ��
            output  reg     deserializer_en,        //����ת��ģ��ʹ��
            output  reg     deserializer_wait,      //����ת����ͣ
            output  reg     crc_ready,              //CRCУ��������
            output  reg     crc_read,               //CRCУ�����ȡ
            output  reg     crc_check_en,           //CRCУ��ģ��ʹ��
            output  reg     demanchesite_en,        //����˹�ؽ���ʹ��
            output  reg     frame_over              //֡�����ź�
    );
    
    parameter IDEL=3'b000;                  //�ȴ�״̬
    parameter CHECK_DELIMITER=3'b001;       //�ֽ�����״̬
    parameter GET_DATA=3'b010;              //��������״̬
    parameter CHECK_END=3'b011;             //��ֹ��У��״̬
    parameter END=3'b100;                   //��ֹ״̬
    
    reg[2:0]    current_state;
    reg[2:0]    next_state;
    reg[4:0]    frame_length_reg;
    reg         delimiter_count_en=1'b0;

    
    reg[4:0]    delimiter_counter=5'h0;
    reg[3:0]    crc_counter=4'h0;
	 reg[3:0]	 wait_counter;
    
    
    always @(posedge clk_6M or negedge delimiter_count_en)begin
        if(delimiter_count_en==1'b0)begin
            delimiter_counter<=5'h0;
        end else begin
            delimiter_counter<=delimiter_counter+1;
            if(SF_check==1'b0)begin
                    delimiter_counter<=5'h0;
            end else if(delimiter_counter==5'h11)begin
                delimiter_counter<=5'h0;
            end
        end
    end
    

    

    
	 always @(posedge clk_24M)begin
		if(current_state==CHECK_END)begin
			wait_counter<=wait_counter+1;
		end else begin
			wait_counter<=4'h0;
		end
	 end
	 
    always @(posedge clk_24M) begin
        if(rst==1'b0)begin
            current_state<=IDEL;
        end else begin
            current_state<=next_state;
        end
    end
    
    always @(posedge clk_24M)begin
        if(rst==1'b0) begin
            frame_length_reg<=4'h0;
        end else if(M_frame==1'b1)begin
            frame_length_reg<=4'h1;
        end else if(S_frame==1'b1)begin
            frame_length_reg<=frame_length;
        end else begin
            frame_length_reg<=frame_length_reg;
        end
    end
    

	 
    always @(*) begin
        if(rst==1'b0) begin
            next_state<=IDEL;
        end else begin
            case(current_state) 
                IDEL:   begin
                    start_check_en<=1'b1;
                    delimiter_check_en<=1'b0;
                    deserializer_en<=1'b0;
                    demanchesite_en<=1'b0;
                    delimiter_count_en<=1'b0;
						  SF_check<=1'b0;
                    frame_over<=1'b0;
                    clk_en<=1'b0;
                    if(frame_start==1'b1)begin
                        clk_en<=1'b1;
                        next_state<=CHECK_DELIMITER;
                    end else begin
                        next_state<=IDEL;
                    end
                end
                
                CHECK_DELIMITER:begin
                    start_check_en<=1'b0;
                    delimiter_check_en<=1'b1;
						  SF_check<=1'b1;
                    delimiter_count_en<=1'b1;
                    deserializer_en<=1'b0;
                    demanchesite_en<=1'b0;
                    frame_over<=1'b0;
                    clk_en<=1'b1;
                    if(delimiter_counter>=5'h11)begin
                        if(S_frame==1'b1||M_frame==1'b1)begin
                            demanchesite_en<=1'b1;
                            next_state<=GET_DATA;
                        end else if(delimiter_error==1'b1)begin
                            next_state<=END;
                        end else begin
                            next_state<=END;
                        end
                    end else begin
                        next_state<=CHECK_DELIMITER;
                    end
                end
                
                GET_DATA:begin
                    start_check_en<=1'b0;
						  SF_check<=1'b0;
                    delimiter_check_en<=1'b1;
                    delimiter_count_en<=1'b0;
                    demanchesite_en<=1'b1;
                    delimiter_count_en<=1'b0;
                    frame_over<=1'b0;
                    clk_en<=1'b1;
                    deserializer_en<=1'b1;
						  if(E_frame==1'b1)begin
								next_state<=CHECK_END;
						  end else begin
								next_state<=GET_DATA;
						  end
							
                end
                
              
                
                CHECK_END:begin
                    start_check_en<=1'b0;
                    delimiter_check_en<=1'b1;
                    delimiter_count_en<=1'b1;
                    //frame_end<=1'b1;
                    demanchesite_en<=1'b0;
                    deserializer_en<=1'b0;
                    clk_en<=1'b1;
                    frame_over<=1'b1;
						  if(wait_counter==4'h8)begin
								next_state<=END;
						  end else begin
								next_state<=CHECK_END;
						  end
                end
                
                END:begin
                    start_check_en<=1'b0;
                    delimiter_check_en<=1'b0;
                    delimiter_count_en<=1'b0;
                    //frame_end<=1'b0;
                    crc_check_en<=1'b0;
                    crc_ready<=1'b0;
                    crc_read<=1'b0;
                    clk_en<=1'b0;
						  frame_over<=1'b1;
                    demanchesite_en<=1'b0;
                    deserializer_en<=1'b0;
                    deserializer_wait<=1'b0;
                    next_state<=IDEL;
                end
                
                default:begin
                    next_state<=IDEL;
                end
                
            endcase
				if(current_state>=GET_DATA)begin
					deserializer_en<=1'b1;
				end else begin
					deserializer_en<=1'b0;
				end
        end
    end
    
    
endmodule
