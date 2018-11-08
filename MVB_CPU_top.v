//-----------------------------------------------------------------------------
// MVB_CPU_top.v
//-----------------------------------------------------------------------------

module MVB_CPU_top
  (
    input RESET,
    input CLK,
	 output clk_3M,
	 output data_out,
	 output [3:0]led,
	 output [7:0]SMG_Data,
	 output [5:0]Scan_Sig
  );

  wire					fifo_write_clk;
  wire					fifo_write_en;
  wire	[31:0]		fifo_write_data;
  wire					fifo_write_ctr;
  wire					fifo_write_full;
  wire					fifo_read_clk;
  wire					fifo_read_en;
  wire					fifo_read_ctr;
  wire	[31:0]		fifo_read_data;
  wire					fifo_read_empty;
  wire					fifo_read_exist;
  wire 	[1:0] 		MS_frame_GPIO_IO_pin;
  wire 	[6:0]			frame_length_GPIO_IO_pin;
  wire 					send_frame_GPIO_IO_pin;
  wire	[15:0] 		cpu_sig_data;
  wire 					frame_over;
  reg		[15:0]     	clk_counter=16'h0;
  reg		[15:0]      send_counter=16'h0;
  reg		[4:0]       word_counter;
  reg             	send_frame=1'b0;
  wire            	frame_over_decode_o;
  wire        			data_get_o;
  wire        			length_error;
  wire        			signal_error;
  wire        			delimiter_error;
  wire        			quality_error;
  wire        			crc_error;
  wire	[15:0]		fifo_output;
  wire	[4:0]			fifo_read_count;
  wire	[4:0]			fifo_write_count;
  wire            	clk_24M;
  wire					clk_100M;
  reg             	clk_6M=1'b0;
  reg             	clk_3M=1'b0;
  reg		[3:0]      	clk_count=4'h0;
  reg             	rst=1'b0;
  
  
	assign fifo_read_exist=|(fifo_read_count+1);
	
	
  	always @(posedge clk_24M)begin		//分频产生6M和3M的时钟
        if(RESET==1'b0)begin
            clk_count<=4'h0;
            clk_6M<=1'b0;
            clk_3M<=1'b0;
        end else begin
				rst<=1'b1;
            clk_count<=clk_count+1;
            if(clk_count%4==0)begin
                clk_6M<=~clk_6M;
            end 
            if(clk_count%8==0)begin
                clk_3M<=~clk_3M;
            end
        end
    end


	assign fifo_write_full=1'b0;
	assign fifo_write_ctr=1'b1;
	assign fifo_read_ctr=1'b1;
	assign fifo_read_data[31:16]=16'h0;
	 
	 
  (* BOX_TYPE = "user_black_box" *)
  MVB_CPU
    MVB_CPU_i (
      .RESET 										( RESET 							),
      .CLK 											( clk_100M 						),
      .MS_frame_GPIO_IO_O_pin 				( MS_frame_GPIO_IO_pin 		),
      .frame_length_GPIO_IO_O_pin 			( frame_length_GPIO_IO_pin ),
      .send_frame_GPIO_IO_O_pin 				( send_frame_GPIO_IO_pin 	),
		.led_GPIO_IO_O_pin						( led								),
		.sig_led_data_GPIO_IO_O_pin			( cpu_sig_data					),
		.microblaze_0_FSL0_M_CLK_pin			( fifo_write_clk				),
		.microblaze_0_FSL0_M_CONTROL_pin		( fifo_write_ctr				),
		.microblaze_0_FSL0_M_DATA_pin			( fifo_write_data				),
		.microblaze_0_FSL0_M_FULL_pin			( fifo_write_full				),
		.microblaze_0_FSL0_M_WRITE_pin		( fifo_write_en				),
		.microblaze_0_FSL0_S_CLK_pin			( fifo_read_clk				),
		.microblaze_0_FSL0_S_CONTROL_pin		( fifo_read_ctr				),
		.microblaze_0_FSL0_S_DATA_pin			( fifo_read_data				),
		.microblaze_0_FSL0_S_EXISTS_pin		( fifo_read_exist				),
		.microblaze_0_FSL0_S_READ_pin			( fifo_read_en					)
    );

	/*fifo_generator_0 fifo3(
        .rst(1'b0),
		  .wr_clk(fifo_write_clk),
        .rd_clk(fifo_read_clk),
        .din(fifo_write_data[15:0]),
        .dout(fifo_read_data[15:0]),
        .wr_en(fifo_write_en),
        .rd_en(fifo_read_en),
		  .full(fifo_write_full),
		  .empty(fifo_read_empty)
	); */
 
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
        .data_in(fifo_write_data[15:0]),
        .clk_3M(clk_3M),
        .clk_6M(clk_6M),
		  .write_clk(fifo_write_clk),
		  .fifo_write_full(/*fifo_write_full*/),
		  .decode_frame_over(frame_over_decode_o),
        .fifo_write_en(fifo_write_en),
        .frame_length(frame_length_GPIO_IO_pin),
        .S_frame(MS_frame_GPIO_IO_pin[0]),
        .M_frame(MS_frame_GPIO_IO_pin[1]),
        .send_frame(send_frame_GPIO_IO_pin),
		  .fifo_write_count(fifo_write_count),
        .data_out(data_out),
        .frame_over(frame_over),
		  .fifo_data_output(fifo_output)
    );

 decode 
	decode1(				
      .clk(clk_24M),					
      .rst(rst),					
      .frame_length(frame_length_GPIO_IO_pin),		
      .data_in(data_out),			
		.fifo_rden(fifo_read_en),	
		.fifo_read_empty(fifo_read_empty),
		.fifo_rdclk(fifo_read_clk),		
      .fifo_data_out(fifo_read_data[15:0]),	
		.fifo_read_count(fifo_read_count),
		.deserialize_data(),
      .data_get(),			
      .length_error(),		
      .signal_error(),		
      .delimiter_error(),	
      .quality_error(),	
      .crc_error(),			
      .frame_over_out(frame_over_decode_o)	
    );




		 smg_interface U2
	 (
	     .CLK( clk_100M ),
		  .RSTn( RESET ),
		  .Number_Sig( {4'h0,led,cpu_sig_data}), // input - from U1
		  .SMG_Data( SMG_Data ),     // output - to top
		  .Scan_Sig( Scan_Sig )      // output - to top
	 );

endmodule

