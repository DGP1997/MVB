`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/21 11:21:56
// Design Name: 
// Module Name: Encode_test
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

(*DONT_TOUCH="TRUE"*)
module Encode_test(
        input           clk,
		  input				data_in,
        output          data_out,
		  //output [3:0]		led,
		  output 	[7:0] SMG_Data,
		  output 	[5:0] Scan_Sig
    );
    
    reg				  S_frame=1'b1;
	 reg				  M_frame=1'b0;
	 reg[6:0]		  frame_length=7'h10;
    reg             rst=1'b0;
    reg[15:0] 		  data=16'h0000;
    reg             send_frame=1'b0;
    reg[15:0]       clk_counter=16'h0;
    reg[15:0]       send_counter=16'h0;
    wire            clk_24M;
	 wire				  clk_100M;
    reg[4:0]        clk_counter1=5'h0;
    reg[4:0]        word_counter;
    reg             write_en=1'b0;
	 reg				  read_en=1'b0;
	 reg				  read_clk=1'b0;
	 reg[15:0]		  data_store[15:0];
	 reg[3:0]		  index=4'h0;
	 reg[3:0]		  i=4'h0;
	 reg[22:0]		  sec_counter;
	 reg				  flag=1'b1;
    wire            frame_over;
    wire            frame_over_decode_o;
    wire[15:0]      led_out;
    
    wire        data_get_o;
    wire        length_error;
    wire        signal_error;
    wire        delimiter_error;
    wire        quality_error;
    wire        crc_error;
    wire[15:0]  data_get;
	 wire [15:0] data_out_GPIO_IO_pin;
	 wire [1:0]  MS_frame_GPIO_IO_pin;
	 wire [6:0]  frame_length_GPIO_IO_pin;
	 wire 		 send_frame_GPIO_IO_pin;
	 wire 		 fifo_write_en_GPIO_IO_pin;
	 wire 		 fifo_write_clk_GPIO_IO_pin;

   reg             clk_6M=1'b0;
   reg             clk_3M=1'b0;
	reg[3:0]        clk_count=4'h0;


	
	
	
	
	always @(posedge clk_24M)begin
        if(rst==1'b0)begin
            clk_count<=4'h0;
            clk_6M<=1'b0;
            clk_3M<=1'b0;
        end else begin
            clk_count<=clk_count+1;
            if(clk_count%4==0)begin
                clk_6M<=~clk_6M;
            end 
            if(clk_count%8==0)begin
                clk_3M<=~clk_3M;
            end
        end
    end
	 always @(posedge clk_3M) begin
			if(sec_counter==3000000)begin
				sec_counter<=0;
				i<=i+1;
			end else begin
				sec_counter<=sec_counter+1;
			end
	 end
	 
    always@(posedge clk_100M)begin
        clk_counter<=clk_counter+1;
        if(clk_counter==30'h00000010)begin
            rst<=1'b1;
        end
        if(clk_counter==2000&&clk_counter>1000)begin
            send_frame<=1'b1;
        end 
        if(send_frame==1'b1)begin
            send_counter<=send_counter+1;
        end
        if(send_counter==100)begin
            send_counter<=16'h0;
            send_frame<=1'b0;
        end
    end
    
    always @(posedge clk_3M)begin
			if(clk_counter>=13000&&clk_counter1<=5'hf&&clk_counter<=13600)begin
				read_en<=1'b1;
			end else begin
				read_en<=1'b0;
			end
	 end
	 
	 /*always @(posedge data_get_o)begin
				data_store[index]<=data_get;
				index<=index+1;
	 end*/
	 
	 always @(posedge clk_3M)begin
		 if(read_en==1'b1&&clk_counter1>=4'h1)begin
			data_store[clk_counter1-1]<=data_get;
		 end
	 end
	 
	 always @(posedge clk_3M)begin
			if(read_en==1'b1)begin
				clk_counter1<=clk_counter1+1;
				index<=index+1;
			end else if(read_en==1'b0)begin
				clk_counter1<=5'h0;
				index<=4'h0;
			end
	 end
	 
    always @( posedge clk_100M)begin
        if(clk_counter==1000)begin
            write_en<=1'b1;
        end else begin
            write_en<=write_en;
        end
        if(word_counter==5'h10)begin
            write_en<=1'b0;
        end
    end
    
    always@(posedge clk_3M)begin
        if(write_en==1'b0)begin
            data<=16'h0000;
            word_counter<=5'h0;
        end else begin
            data<=data+16'h1111;
            word_counter<=word_counter+1;
        end
    end
    
    clk_wiz_0 c0(
        .clk_in1(clk),
        .clk_24M(clk_24M),
		  .clk_100M(clk_100M)
    );
    
    
  /* MVB_CPU
    MVB_CPU_i (
      .RESET ( 1'b1),
      .CLK ( clk_100M ),
      .data_out_GPIO_IO_O_pin ( data_out_GPIO_IO_pin ),
      .MS_frame_GPIO_IO_O_pin ( MS_frame_GPIO_IO_pin ),
      .frame_length_GPIO_IO_O_pin ( frame_length_GPIO_IO_pin ),
      .send_frame_GPIO_IO_O_pin ( send_frame_GPIO_IO_pin ),
      .fifo_write_en_GPIO_IO_O_pin ( fifo_write_en_GPIO_IO_pin ),
      .fifo_write_clk_GPIO_IO_O_pin ( fifo_write_clk_GPIO_IO_pin ),
		.led_GPIO_IO_O_pin(led)
    );*/
    
	(*DONT_TOUCH="TRUE"*)
    Encode E1(
        .clk_24M(clk_24M),
        .rst(rst),//.clk_rst(1'b0),
        .data_in(data),
		  .decode_frame_over(frame_over_decode_o),
		  .write_clk(clk_3M),
        .fifo_write_en(write_en),
        .frame_length(frame_length),
        .S_frame(S_frame),
        .M_frame(M_frame),
        .send_frame(send_frame),
        .data_out(data_out),
        .frame_over(frame_over),
		  .clk_3M(clk_3M),
		  .clk_6M(clk_6M)
    );
    
	(*DONT_TOUCH="TRUE"*)
    decode d1(
        .clk(clk_24M),
        .rst(rst),
        .frame_length(frame_length),
        .data_in(data_out),
        .fifo_rden(read_en),
		  .fifo_rdclk(clk_3M),
        .data_get(data_get_o),
        .fifo_data_out(data_get),
		  .deserialize_data(),
        .length_error(length_error),
        .signal_error(signal_error),
        .delimiter_error(delimiter_error),
        .quality_error(quality_error),
        .crc_error(crc_error),
        .frame_over_out(frame_over_decode_o)
    );
    
    smg_interface 
		U2
	 (
	     .CLK( clk_100M ),
		  .RSTn( rst ),
		  .Number_Sig( {8'h11,data_store[i]}), // input - from U1
		  .SMG_Data( SMG_Data ),     // output - to top
		  .Scan_Sig( Scan_Sig )      // output - to top
	 );
endmodule
