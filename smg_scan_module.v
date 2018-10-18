module smg_scan_module
(
    input CLK, 
	 input RSTn, 
	 output [5:0]Scan_Sig
);
	 
	 /*****************************/
	 
	 parameter T1MS = 16'd49999;
	 
	 /*****************************/
	 
	 reg [15:0]C1;
	 
	 always @ ( posedge CLK or negedge RSTn )
	     if( !RSTn )
		      C1 <= 16'd0;
		  else if( C1 == T1MS )
		      C1 <= 16'd0;
		  else
		      C1 <= C1 + 1'b1;
	
	 /*******************************/
	 
	 reg [3:0]i;
	 reg [5:0]rScan;
	 
	 always @ ( posedge CLK or negedge RSTn )
	     if( !RSTn )
		      begin
		          i <= 4'd0;
		          rScan <= 6'b100_000;
			   end
		  else 
		      case( i )
				    
					 0:
		          if( C1 == T1MS ) i <= i + 1'b1;
					 else rScan <= 6'b011_111;                      //��һ������ѡͨ
					 
					 1:
					 if( C1 == T1MS ) i <= i + 1'b1;
					 else rScan <= 6'b101_111;                      //�ڶ�������ѡͨ
					 
					 2:
					 if( C1 == T1MS ) i <= i + 1'b1;
					 else rScan <= 6'b110_111;                      //����������ѡͨ
					 
					 3:
					 if( C1 == T1MS ) i <= i + 1'b1;
					 else rScan <= 6'b111_011;                      //���ĸ�����ѡͨ
					 
					 4:
					 if( C1 == T1MS ) i <= i + 1'b1;
					 else rScan <= 6'b111_101;                      //���������ѡͨ
					 
					 5:
					 if( C1 == T1MS ) i <= 4'd0;
					 else rScan <= 6'b111_110;                      //����������ѡͨ
					 
					 
				endcase
				
	 /******************************/
	 
	 assign Scan_Sig = rScan;
	 
	 /******************************/
		      

endmodule
