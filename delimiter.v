/****************************************************
鍒嗙晫绗︾敓鎴愭ā鍧楋細浜х敓涓诲抚鍜屼粠甯х殑甯у垎鐣岀





******************************************************/

module delimiter (
			input 		reset,				//复位信号
            input 		clk_3M,				//6Mhz时钟信号，上升沿有效
			input 		send_delimiter,     //发送分界符使能
			input[1:0]	delimiter_format,   //帧格式（01：主帧起始符  10：从帧起始符  11：帧结束分界符）
			output reg	delimiter_out		//输出数据

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
