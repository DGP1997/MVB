/********************************************************
澶氳矾閫夋嫨妯″潡锛氭牴鎹富鎺фā鍧楀彂鍑虹殑鎺у埗淇″彿閫夋嫨閫氳繃鍒嗙晫绗︽垨鏁版嵁鎴朇RC鏍￠獙鐮?





********************************************************/

module Multiplexer (
				input[1:0] 		sel,                    //选择信号
				input			delimiter_out,          //分界符输入
				input			crc_out,                //CRC校验序列输入
				input 			data_out,               //并串转换输入
				input 			multi_en,               //模块使能信号
				output reg		multi_out               //输出
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
