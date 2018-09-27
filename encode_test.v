module encode_test(
			input clk_48M,
			output data_out,
			output reg send
);

		wire 			clk_24M;
		wire			clk_6M;
		wire			clk_3M;
		wire			clk_1d5M;
		reg 			rst=1'b0;
		reg[11:0]	   clk_counter;
		reg[15:0]   data=16'b0111111011000011;
		
		
		always @(posedge clk_48M)begin
			clk_counter<=clk_counter+1;
			send<=1'b0;
			if(clk_counter==200)begin
				rst<=1'b1;
			end else begin
				rst<=rst;
			end
			if(clk_counter>=0200&&clk_counter<=0215)begin
				send<=1'b1;
			end
		end
		
		
		PLL p1 (
			.inclk0(clk_48M),
			.c0(clk_24M),
			.c1(clk_6M),
			.c2(clk_3M),
			.c3()
		);
		
		Encode e1(
			.clk_24M(clk_24M),
			.clk_6M(clk_6M),
			.clk_3M(clk_3M),
			.rst(rst),
			.M_frame(1'b1),
			.S_frame(1'b0),
			.frame_length(7'h1),
			.data_in(data),
			.send_frame(send),
			.data_out(data_out)
		)/*synthesis noprune*/ ;


endmodule
