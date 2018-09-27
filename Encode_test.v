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

(*DONT_TOUCH="true"*)
module Encode_test(
        input           clk,
        input           data_in,
        input [7:0]     switch,
        output          data_out,
        output          data_out2,
        output[15:0]    led
    );
    
    
    reg             rst=1'b0;
    reg[6:0]        frame_length=7'h10;
    reg             M_frame=1'b0;
    reg             S_frame=1'b1;
    reg[15:0]       data=16'b0111111011000011;
    reg             send_frame=1'b0;
    reg[15:0]       clk_counter=16'h0;
    reg[6:0]        send_counter=7'h0;
    wire            clk_24M;
    reg             clk_6M;
    reg             clk_3M;
    reg[3:0]        clk_count;
    reg[4:0]        word_counter;
    reg             write_en=1'b0;
    wire             frame_over;
    wire             frame_over_decode_o;
    wire[15:0]      led_out;
    
    wire        data_get_o;
    wire        length_error;
    wire        signal_error;
    wire        delimiter_error;
    wire        quality_error;
    wire        crc_error;
    wire[15:0]  data_get;

    assign data_out2=data_out;
    assign led=~led_out;
    
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
    
    always@(posedge clk)begin
        clk_counter<=clk_counter+1;
        if(clk_counter==30'h00000010)begin
            rst<=1'b1;
        end
        if(clk_counter%25000==0&&clk_counter>1000)begin
            send_frame<=1'b1;
        end 
        if(send_frame==1'b1)begin
            send_counter<=send_counter+1;
        end
        if(send_counter==30)begin
            send_counter<=7'h0;
            send_frame<=1'b0;
        end
    end
    
    
    always @( posedge clk)begin
        if(send_frame==1'b1)begin
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
            data<=16'h7ec3;
            word_counter<=5'h0;
        end else begin
            data<=data+1;
            word_counter<=word_counter+1;
        end
    end
    
    clk_wiz_0 c0(
        .clk_in1(clk),
        .clk_24M(clk_24M)
    );
    
    
    
    
   (*DONT_TOUCH="true"*)
    Encode E1(
        .clk_24M(clk_24M),
        .rst(rst),.clk_rst(1'b0),
        .data_in(data),
        .clk_3M(clk_3M),
        .clk_6M(clk_6M),
        .fifo_write_en(write_en),
        .frame_length(frame_length),
        .S_frame(S_frame),
        .M_frame(M_frame),
        .send_frame(send_frame),
        .data_out(data_out),
        .frame_over(frame_over)
    );
    
    (*DONT_TOUCH="true"*)
    decode d1(
        .clk(clk_24M),
        .rst(rst),
        .frame_length(frame_length),
        .data_in(data_out),
        .key(switch),
        .data_get(data_get_o),
        .fifo_data_out(data_get),
        .length_error(length_error),
        .signal_error(signal_error),
        .delimiter_error(delimiter_error),
        .quality_error(quality_error),
        .crc_error(crc_error),
        .frame_over_out(frame_over_decode_o),
        .led(led_out)
    );
    
    
endmodule
