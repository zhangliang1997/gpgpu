import defines::*;

module oh2idx(
	input   [NUM_WARPS_PER_SM - 1:0]     				oh,
	output  logic[2 - 1:0] 		idx
);

always_comb @(*)
begin 
	case (oh)
		4'b0001: idx = 2'b00;
		4'b0010: idx = 2'b01;
		4'b0100: idx = 2'b10;
		4'b1000: idx = 2'b11;
		default: idx = 2'b00;
	endcase
end
endmodule
