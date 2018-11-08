`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/27 14:25:29
// Design Name: 
// Module Name: decode
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


module decode(				
            input           clk,					//24M时钟
            input           rst,					//复位
            input[4:0]      frame_length,		//帧长度
            input           data_in,			//数据输入
				input				 fifo_rden,			//fifo读使能
				input				 fifo_rdclk,		//fifo读脉冲
            output[15:0]    fifo_data_out,	//fifo数据输出
				output			 fifo_read_empty,
				output[4:0]		 fifo_read_count,
				output[15:0]	 deserialize_data,
            output          data_get,			//16数据接受完毕
            output          length_error,		//长度错误
            output          signal_error,		//信号错误
            output          delimiter_error,	//分界符错误
            output          quality_error,	//信号质量错误
            output          crc_error,			//CRC校验错误
            output reg      frame_over_out	//帧接受结束
    );

    reg             clk_6M;
    reg             clk_3M;
    wire            frame_start_o;
    wire            S_frame_o;
    wire            M_frame_o;
    wire            E_frame_o;
    wire            length_error_o;
    wire            signal_error_o;
    wire            delimiter_error_o;
    wire            quality_error_o;
    wire            crc_error_o;
    wire            frame_over_o;
    wire            frame_end_o;
    wire            start_check_en_o;
    wire            delimiter_check_en_o;
    wire            deserializer_en_o;
    wire            deserializer_wait_o;
    wire            demanchesite_en_o;
    wire            crc_check_en_o;
    wire            crc_read_o;
    wire            crc_ready_o;
    wire            org_data_o;
    wire            clk_en_o;
    
    reg             fifo_clk;
    wire            full;
    wire            empty;
    wire[15:0]      fifo_data_in;
    wire[15:0]      data_out;
    wire            fifo_write_en;
    
    wire            frame_over;
    reg             cout_count_en;
    reg[8:0]        cout_counter;
    
    assign deserialize_data=data_out;
    
    reg [2:0]   clk_counter;
    
    
    always @(posedge clk)begin
        if(clk_en_o==1'b0&&cout_count_en==1'b0)begin
            clk_counter<=3'h2;
        end else begin
            clk_counter<=clk_counter+1;
        end
    end
    
    always @(posedge clk) begin
        if(clk_en_o==1'b0&&cout_count_en==1'b0)begin
            clk_3M<=1'b0;
            clk_6M<=1'b1;
        end else begin
            if(clk_counter%4==0)begin
                clk_6M<=~clk_6M;
            end
            if(clk_counter%8==0)begin
                clk_3M<=~clk_3M;
            end
        end
    end
    
    always@(posedge clk or posedge frame_over )begin
        if(frame_over==1'b1)begin
            frame_over_out<=1'b1;
            cout_count_en<=1'b1;
        end else if(frame_over_out==1'b1&&cout_counter!=17)begin
            frame_over_out<=1'b1;
            cout_count_en<=1'b1;
        end else if(cout_counter==17)begin
            frame_over_out<=1'b0;
            cout_count_en<=1'b0;
        end else begin
            frame_over_out<=1'b0;
            cout_count_en<=1'b0;
        end
    end
    

    
    always @(posedge clk_3M)begin
        if(cout_count_en==1'b0)begin
            cout_counter<=9'h0;
        end else begin
            cout_counter<=cout_counter+1;
        end
    end
    
    
    (*DONT_TOUCH="true"*)
    decode_ctr u1(
        .clk_24M(clk),
        .clk_6M(clk_6M),
        .clk_3M(clk_3M),
        .rst(rst),
        .clk_en(clk_en_o),
        .frame_start(frame_start_o),
        .S_frame(S_frame_o),
        .M_frame(M_frame_o),
        .E_frame(E_frame_o),
        .length_error(length_error_o),
        .signal_error(signal_error_o),
        .quality_error(quality_error_o),
        .crc_error(crc_error_o),
        .delimiter_error(delimiter_error_o),
        .frame_length(frame_length),
        .start_check_en(start_check_en_o),
        .delimiter_check_en(delimiter_check_en_o),
        .deserializer_en(deserializer_en_o),
        .deserializer_wait(deserializer_wait_o),
        .demanchesite_en(demanchesite_en_o),
        .crc_ready(crc_ready_o),
        .crc_read(crc_read_o),
        .crc_check_en(crc_check_en_o),
        .frame_end(frame_end_o),
        .frame_over(frame_over)
    );
    
    (*DONT_TOUCH="true"*)
    start_check u2(
        .clk_24M(clk),
        .rst(start_check_en_o),
        .data_in(data_in),
        .frame_start(frame_start_o)
    );
    
    (*DONT_TOUCH="true"*)
    delimiter_check u3(
        .rst(delimiter_check_en_o),
        .clk_3M(clk_3M),
        .clk_6M(clk_6M),
        .data_in(data_in),
        .frame_end(frame_end_o),
        .M_frame(M_frame_o),
        .S_frame(S_frame_o),
        .E_frame(E_frame_o),
        .E_delimit(delimiter_error_o),
        .E_length(length_error_o)
    );
    
    (*DONT_TOUCH="true"*)
    demanchesite u4(
        .rst(demanchesite_en_o),
        .clk_24M(clk),
        .data_in(data_in),
        .data_out(org_data_o),
        .signal_error(signal_error_o),
        .quality_error(quality_error_o)
    );
    
    (*DONT_TOUCH="true"*)
    deserializer u5(
        .rst(deserializer_en_o),
        .clk_3M(clk_3M),
        .deserializer_wait(deserializer_wait_o),
        .data_in(org_data_o),
        .data_preserve(data_out),
        .data_get_o(data_get)
    );
    
    fifo_generator_0 fifo2(
        .rst(1'b0),
        .wr_clk(clk_3M),
		  .rd_clk(fifo_rdclk),
        .full(full),
        .empty(fifo_read_empty),
        .din(data_out),
        .dout(fifo_data_out),
        .wr_en(data_get),
        .rd_en(fifo_rden),
		  .rd_data_count(fifo_read_count)
    );
    
    
    (*DONT_TOUCH="true"*)
    crc_check u6(
        .rst(crc_check_en_o),
        .clk_3M(clk_3M),
        .crc_ready(crc_ready_o),
        .crc_read(crc_read_o),
        .data_in(org_data_o),
        .crc_error(crc_error_o)
    );
    
    
    
    
endmodule
