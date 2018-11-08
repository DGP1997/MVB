(*DONT_TOUCH="TRUE"*)
module Encode(
			input 		 clk_24M,				//24Mhz时钟
			input        clk_3M,
			input        clk_6M,
			input			 write_clk,				//fifo写入脉冲
			output		 fifo_write_full,
			input 		 rst,						//复位
			input			 decode_frame_over,	//编码接收结束
			input 		 send_frame,			//帧发送信号
			input 		 M_frame,				//主帧信号
			input 		 S_frame,				//从帧信号
			input        fifo_write_en,		//fifo写使能
			input[6:0] 	 frame_length,			//帧长度
			input[15:0]  data_in,				//输入数据
			output[5:0]	 fifo_write_count,
			output[15:0] fifo_data_output,	//fifo输出数据
			output wire	 data_out,				//编码后输出结果
			output wire	 frame_over				//帧发送结束

)/*synthesis preserve="true"*/ ;


 wire[1:0]		delimiter_format_o;
 wire[1:0]		multi_sel_o;
 wire				manchesite_en_o;
 wire				crc_en_o;
 wire				multi_en_o;
 wire				deserialize_en_o;
 wire				delimiter_en_o;
 wire				data_read_o;
 wire				data_send_o;
 wire				delimiter_send_o;
 wire				crc_send_o;
 wire				crc_ready_o;
 
 wire				data_o;
 wire				delimiter_o;
 wire				crc_o;
 wire				multi_o;

 wire              full;
 wire              empty;
 wire[15:0]        fifo_data_out;
 wire              fifo_read_en;
 wire              fifo_rst;
 

 
 assign fifo_data_output=fifo_data_out;

 


(*DONT_TOUCH="TRUE"*)
 EncodeCtrl encodectrl1(
		.rst(rst),
		.clk(clk_24M),
		.clk_6M(clk_6M),
		.clk_3M(clk_3M),
		.send_frame(send_frame),
		.data_length(frame_length),
		.master_frame(M_frame),
		.slave_frame(S_frame),
		.decode_over(decode_frame_over),
		

		.delimiter_format(delimiter_format_o),
		.multi_sel(multi_sel_o),
		.manchesite_en(manchesite_en_o),
		.crc_en(crc_en_o),
		.multi_en(multi_en_o),
		.delimiter_en(delimiter_en_o),
		.deserialize_en(deserialize_en_o),
		
		.data_read(data_read_o),
		.data_send(data_send_o),
		.delimiter_send(delimiter_send_o),
		.crc_send(crc_send_o),
		.crc_ready(crc_ready_o),
		.frame_over(frame_over)
 
 );
 
(*DONT_TOUCH="TRUE"*)
 Deserialize deserialize1(
		.clk_1d5M(clk_3M),
		.reset(deserialize_en_o),
		.data_in(fifo_data_out),
		.read(data_read_o),
		.shift(data_send_o),
		.dout(data_o)
 );
 (*DONT_TOUCH="TRUE"*)
 fifo_generator_0 fifo1(
        .rst(1'b0),
		  .wr_clk(write_clk),
        .rd_clk(clk_3M),
        .full(fifo_write_full),
        .empty(empty),
        .din(data_in),
        .dout(fifo_data_out),
        .wr_en(fifo_write_en),
		  .wr_data_count(fifo_write_count),
        .rd_en(data_read_o)
 ); 
 (*DONT_TOUCH="TRUE"*)
 delimiter d1(
             .reset(delimiter_en_o),               
             .clk_3M(clk_6M),                
             .send_delimiter(delimiter_send_o),    
             .delimiter_format(delimiter_format_o), 
             .delimiter_out(delimiter_o)      
 
 );
 
 
(*DONT_TOUCH="TRUE"*)
 CRC crc(
		.clk_1d5M(clk_3M),
		.data_in(data_o),
		.rst(crc_en_o),
		.ready(crc_ready_o),
		.send(crc_send_o),
		
		.crc_o(crc_o)
 
 );
 
(*DONT_TOUCH="TRUE"*)
 Multiplexer MUL(
		.multi_en(multi_en_o),
		.sel(multi_sel_o),
		.delimiter_out(delimiter_o),
		.crc_out(crc_o),
		.data_out(data_o),
		
		.multi_out(multi_o)
 
 );
 
 
(* DONT_TOUCH= "true" *)
  manchesite m1(
		.clk_3M(clk_3M),
		.clk_6M(clk_6M),
		.data_in(multi_o),
		.rst(manchesite_en_o),
		
		.data_out(data_out)
 
 
 );
 

 
 
endmodule
