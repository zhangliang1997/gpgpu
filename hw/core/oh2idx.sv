import defines::*;

module oh2idx(
	output  logic[$log2(NUM_WRAPS_PER_SM) - 1:0] idx,
	input   logic[NUM_WRAPS_PER_SM - 1:0]     oh
);

always_comb @(*)
begin 
	case (oh)
	4'b0001: idx = 0;
	4'b0010: idx = 1;
	4'b0100: idx = 2;
	4'b1000: idx = 3;
	endcase
end
endmodule
