//-----------------------------------------------------------------------------
// MVB_CPU_top.v
//-----------------------------------------------------------------------------

module MVB_CPU_top
  (
    input RESET,
    input CLK,
	 output data_out,
	 output [3:0]led,
	 output [7:0]SMG_Data,
	 output [5:0]Scan_Sig
  );

  wire [15:0] data_out_GPIO_IO_pin;
  wire [1:0] MS_frame_GPIO_IO_pin;
  wire [6:0] frame_length_GPIO_IO_pin;
  wire send_frame_GPIO_IO_pin;
  wire fifo_write_en_GPIO_IO_pin;
  wire fifo_write_clk_GPIO_IO_pin;
  wire frame_over;
  reg[15:0]       clk_counter=16'h0;
  reg[15:0]       send_counter=16'h0;
  reg[4:0]        word_counter;
  reg             send_frame=1'b0;
  wire            frame_over_decode_o;
  wire[15:0]      led_out;
  wire        		data_get_o;
  wire        		length_error;
  wire        		signal_error;
  wire        		delimiter_error;
  wire        		quality_error;
  wire        		crc_error;
  wire[15:0]		fifo_output;
  wire            clk_24M;
  wire				clk_100M;
  reg             clk_6M=1'b0;
  reg             clk_3M=1'b0;
  reg[3:0]        clk_count=4'h0;
  reg             write_en=1'b0;
  reg[15:0] 		data=16'h7ec3;
  reg             rst=1'b0;
  
  
  	always @(posedge clk_24M)begin		//分频产生6M和3M的时钟
        if(RESET==1'b0)begin
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

    always@(posedge clk_3M)begin
        if(write_en==1'b0)begin
            data<=16'h7ec3;
            word_counter<=5'h0;
        end else begin
            data<=data+1;
            word_counter<=word_counter+1;
        end
    end

    always@(posedge clk_100M)begin
        clk_counter<=clk_counter+1;
		  if(clk_counter==30'h00000010)begin
            rst<=1'b1;
        end
        if(clk_counter%600==0&&clk_counter>1000)begin
            send_frame<=1'b1;
        end 
        if(send_frame==1'b1)begin
            send_counter<=send_counter+1;
        end
        if(send_counter==30)begin
            send_counter<=16'h0;
            send_frame<=1'b0;
        end
    end
    
    
    always @( posedge clk_100M)begin
        if(send_frame==1'b1)begin
            write_en<=1'b1;
        end else begin
            write_en<=write_en;
        end
        if(word_counter==5'h10)begin
            write_en<=1'b0;
        end
    end
	 
	 
	 
  (* BOX_TYPE = "user_black_box" *)
  MVB_CPU
    MVB_CPU_i (
      .RESET ( RESET ),
      .CLK ( clk_100M ),
      .data_out_GPIO_IO_O_pin ( data_out_GPIO_IO_pin ),
      .MS_frame_GPIO_IO_O_pin ( MS_frame_GPIO_IO_pin ),
      .frame_length_GPIO_IO_O_pin ( frame_length_GPIO_IO_pin ),
      .send_frame_GPIO_IO_O_pin ( send_frame_GPIO_IO_pin ),
      .fifo_write_en_GPIO_IO_O_pin ( fifo_write_en_GPIO_IO_pin ),
      .fifo_write_clk_GPIO_IO_O_pin ( fifo_write_clk_GPIO_IO_pin ),
		.led_GPIO_IO_O_pin(led)
    );

	 clk_wiz_0 
		c1(
        .clk_in1(CLK),
		  //.clk_3M(clk_3M),
		  //.clk_6M(clk_6M),
        .clk_24M(clk_24M),
		  .clk_100M(clk_100M)
    );
	 
	 
	 
	 Encode 
		E1(
        .clk_24M(clk_24M),
        .rst(rst),
        .data_in(data_out_GPIO_IO_pin),
        .clk_3M(clk_3M),
        .clk_6M(clk_6M),
		  .write_clk(fifo_write_clk_GPIO_IO_pin),
		  .decode_frame_over(frame_over_decode_o),
        .fifo_write_en(fifo_write_en_GPIO_IO_pin),
        .frame_length(frame_length_GPIO_IO_pin),
        .S_frame(MS_frame_GPIO_IO_pin[0]),
        .M_frame(MS_frame_GPIO_IO_pin[1]),
        .send_frame(send_frame_GPIO_IO_pin),
        .data_out(data_out),
        .frame_over(frame_over),
		  .fifo_data_output(fifo_output)
    );

	 decode 
		d1(
        .clk(clk_24M),
        .rst(rst),
        .frame_length(frame_length_GPIO_IO_pin),
        .data_in(data_out),
        .key(8'h1),
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


		 smg_interface U2
	 (
	     .CLK( clk_100M ),
		  .RSTn( RESET ),
		  .Number_Sig( {8'h15,led_out}), // input - from U1
		  .SMG_Data( SMG_Data ),     // output - to top
		  .Scan_Sig( Scan_Sig )      // output - to top
	 );

endmodule

