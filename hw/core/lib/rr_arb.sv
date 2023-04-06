//https://zhuanlan.zhihu.com/p/474350337
module rr_arb(
	input  clk,
	input  rst_n,

	input  req1,
	input  req2,
	input  req3,
	input  req4,

	input  busy,
	output reg [3:0] nx_arb_gnt
);
localparam  S1=4'b0001,
	    S2=4'b0010,
	    S3=4'b0100,
	    S4=4'b1000;
reg [3:0] cur_arb_gnt_r;
wire [3:0] cur_arb_gnt;
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cur_arb_gnt_r <= S1; // S1
	end
	else if (~busy) begin
		cur_arb_gnt_r <= nx_arb_gnt;
	end
end
assign cur_arb_gnt = cur_arb_gnt_r;
always @(*) begin
	if (~busy) begin
		case(cur_arb_gnt)		//循环仲裁
			S1:begin 
				case(1'b1)
					req2:nx_arb_gnt = S2;
					req3:nx_arb_gnt = S3;
					req4:nx_arb_gnt	= S4;
					req1:nx_arb_gnt = S1;
					default:nx_arb_gnt = S1;
				endcase
			end
			S2:begin 
				case(1'b1)
					req3:nx_arb_gnt = S3;
					req4:nx_arb_gnt = S4;
					req1:nx_arb_gnt = S1;
					req2:nx_arb_gnt = S2;
					default:nx_arb_gnt = S2;
				endcase
			end
			S3:begin 
				case(1'b1)
					req4:nx_arb_gnt = S4;
					req1:nx_arb_gnt = S1;
					req2:nx_arb_gnt = S2;
					req3:nx_arb_gnt = S3;
					default:nx_arb_gnt = S3;
				endcase
			end
			S4:begin
				case(1'b1)
					req1:nx_arb_gnt = S1;
					req2:nx_arb_gnt = S2;
					req3:nx_arb_gnt = S3;
					req4:nx_arb_gnt = S4;
					default:nx_arb_gnt 	= S4;
			endcase
		end
		default: nx_arb_gnt = S1;
		endcase
	end
	else begin
		nx_arb_gnt = cur_arb_gnt;
	end
end
endmodule
