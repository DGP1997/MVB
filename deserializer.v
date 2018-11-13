`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 14:07:12
// Design Name: 
// Module Name: deserializer
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

(*DONT_TOUCH="true"*)
module deserializer(
        input               clk_3M,                 //3Mhz时钟
        input               rst,                    //复位信号
        input               deserializer_wait,      //串并转换暂停信号
        input               data_in,                //输入数据
		  input					 quality_error,
        output reg[15:0]    data_preserve,          //输出数据
        output reg          data_get_o,             //16位数据有效信号
		  output reg			 data_get_org,
		  output reg			 crc_error,
		  output reg[8:0]	 	 data_counter,
		  output reg[4:0]		 word_counter,
		  output reg			 frame_end_check
    );
    
    reg[4:0]    index=5'h0;
	 reg[15:0]	 data_pre=16'h0;
    reg         data_get;
    reg         pre_rst;
	 reg			 pre_pre_rst;
	 reg[15:0] 	 data_out=16'h0;
	 reg[7:0]	 crc_get[3:0];
	 reg[7:0]	 crc_new[3:0];
	 reg[7:0]	 crc_c;
	 reg[7:0]	 crc_r;
	 integer 	 i;
	 
	 always @(posedge clk_3M)begin
		if(rst==1'b0)begin
			frame_end_check<=1'b0;
		end else if((data_counter>=24&&data_counter<=25)||
						(data_counter>=40&&data_counter<=41)||
						(data_counter>=72&&data_counter<=73)||
						(data_counter>=144&&data_counter<=145)||
						(data_counter>=288&&data_counter<=289))begin
			frame_end_check<=1'b1;
		end else begin
			frame_end_check<=1'b0;
		end
	 end
	 
	 
	 always @(clk_3M)begin
		if(rst==1'b0)begin
			crc_error<=1'b0;
		end else if(frame_end_check==1'b1)begin
			if(crc_get[0]!=crc_new[0]||
				crc_get[1]!=crc_new[1]||
				crc_get[2]!=crc_new[2]||
				crc_get[3]!=crc_new[3])begin
					crc_error<=1'b1;
			end else begin
				crc_error<=1'b0;
			end
		end else begin
			crc_error<=1'b0;
		end
	 end
	 
	 
	 always @(posedge clk_3M)begin
		if(rst==1'b0)begin
			data_counter<=9'h0;
			for(i=0;i<4;i=i+1) begin
				crc_new[i]<=8'h0;
				crc_get[i]<=8'h0;
			end
		end else begin
			data_counter<=data_counter+1;
			case (data_counter) 
				9'd16:begin
					crc_new[0]<=crc_c;
				end
				9'd24:begin
					crc_get[0]<=crc_r;
				end
				9'd32:begin
					crc_new[0]<=crc_c;
				end
				9'd40:begin
					crc_get[0]<=crc_r;
				end
				9'd64:begin
					crc_new[0]<=crc_c;
				end
				9'd72:begin
					crc_get[0]<=crc_r;
				end
				9'd136:begin
					crc_new[1]<=crc_c;
				end
				9'd144:begin
					crc_get[1]<=crc_r;
				end
				9'd208:begin
					crc_new[2]<=crc_c;
				end
				9'd216:begin
					crc_get[2]<=crc_r;
				end
				9'd280:begin
					crc_new[3]<=crc_c;
				end
				9'd288:begin
					crc_get[3]<=crc_r;
				end
			endcase
		end
	 end
	 
    always @(posedge clk_3M ) begin
        data_get_org<=data_get;
        pre_rst<=rst;
		  pre_pre_rst<=pre_rst;
        if(rst==1'b0)begin
            data_out<=16'h0000;
            index<=5'h0;
				crc_r<=8'h0;
				data_get_org<=1'b0;
        end else if((data_counter>=64&&data_counter<72)||
						  (data_counter>=136&&data_counter<144)||
						  (data_counter>=208&&data_counter<216)||
						  (data_counter>=280&&data_counter<288))begin
            data_out<=data_out;
				crc_r[0]<=data_in;
				crc_r[7:1]<=crc_r[6:0];
            index<=5'h0;
        end else  begin
            index<=index+1;
            if(index==5'hf)begin
                index<=5'h0;
            end
				if(quality_error!=1'b1)begin
					data_out[15-index]<=data_in;
				end else begin
					data_out<=data_out;
				end
			end
    end
    
    always @(posedge clk_3M )begin
        if(rst==1'b0)begin
            crc_c<=8'h0;
            //crc_code<=8'h0;
		  end else if(data_counter==9'd72||data_counter==9'd144||data_counter==9'd216)begin
				crc_c<=8'h0;
        end else  begin
            crc_c[1]<=crc_c[7]^data_in;
            crc_c[2]<=crc_c[1];
            crc_c[3]<=crc_c[2]^(data_in^crc_c[7]);
            crc_c[4]<=crc_c[3];
            crc_c[5]<=crc_c[4];
            crc_c[6]<=crc_c[5]^(data_in^crc_c[7]);
            crc_c[7]<=crc_c[6]^(data_in^crc_c[7]);
            crc_c[0]<=data_in^(^crc_c[7:1])^((data_in^crc_c[7])^1'b0);
            /*crc_code<={crc_c[6]^(data_in^crc_c[7]),crc_c[5]^(data_in^crc_c[7]),crc_c[4],crc_c[3],crc_c[2]^(data_in^crc_c[7])
											,crc_c[1],crc_c[7]^data_in,data_in^(^crc_c[7:1])^((data_in^crc_c[7])^1'b0)};*/
        end 
    end
    
	 always @(posedge clk_3M)begin
		if(rst==1'b0)begin
			data_preserve<=16'h0000;
		end else if(index==0)begin
			data_preserve<=data_out;
		end else begin
			data_preserve<=data_preserve;
		end
	 end
	 
    always @(negedge clk_3M)begin
        if(data_get_org==1'b0&&data_get==1'b1)begin
            data_get_o<=1'b1;
        end else begin
            data_get_o<=1'b0;
        end
    end
    
    always @(posedge clk_3M) begin
        if(rst==1'b0)begin
            data_get<=1'b0;
				word_counter<=5'h0;
        end else begin
            if(index==5'h0&&pre_rst!=1'b0)begin
					if((data_counter>=64&&data_counter<72)||
							(data_counter>=136&&data_counter<144)||
							(data_counter>=208&&data_counter<216)||
							(data_counter>=280&&data_counter<288))begin
						data_get<=1'b0;
						word_counter<=word_counter;
					 end else begin
						data_get<=1'b1;
						word_counter<=word_counter+1;
					 end
            end else begin
                data_get<=1'b0;
            end
        end
    end
    
    
endmodule
