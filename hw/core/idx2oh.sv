import defines::*;

module idx2oh(
	input logic[$log2(NUM_WRAPS_PER_SM) - 1:0] idx,
	output logic[NUM_WRAPS_PER_SM - 1:0]     oh
);

always_comb @(*)
begin 
	case (idx)
	0: oh = 4'b0001;
	1: oh = 4'b0010;
	2: oh = 4'b0100;
	3: oh = 4'b1000;
	endcase
end
endmodule
