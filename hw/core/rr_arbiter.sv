import defines::*;

module rr_arbiter(
	input								clk,
	input								reset,
	input[NUM_WARPS_PER_SM - 1:0]      	request,
	output[NUM_WARPS_PER_SM - 1:0]     	grantOH,

);

logic[NUM_WARPS_PER_SM - 1:0] 		  	preSelectedWarpOHReg;

always_ff @(posedge clk, posedge reset)
begin
	if (reset)
		preSelectedWarpOHReg <= 0;
	else
		preSelectedWarpOHReg <= grantOH;
end

always_comb @(*)
begin
	if (preSelectedWarpOHReg == 4'b0000)
	begin
		case requset:
		4'b0000:  grantOH = 4'b0000;
		4'bxxx1:  grantOH = 4'b0001;
		4'bxx10:  grantOH = 4'b0010;
		4'bx100:  grantOH = 4'b0100;
		4'b1000:  grantOH = 4'b1000;
	end
	else if (preSelectedWarpOHReg == 4'b0001)
	begin
		case requset:
		4'bxx1x:  grantOH = 4'b0010;
		4'bx10x:  grantOH = 4'b0100;
		4'b100x:  grantOH = 4'b1000;
		4'b000x:  grantOH = request
	end
	else if (preSelectedWarpOHReg == 4'b0010)
	begin
		case requset:
		4'bx1xx:  grantOH = 4'b0100;
		4'b10xx:  grantOH = 4'b1000;
		4'b00x1:  grantOH = 4'b0001;
		4'b00x0:  grantOH = request
	end
	else if (preSelectedWarpOHReg == 4'b0100)
	begin
		case requset:
		4'b1xxx:  grantOH = 4'b1000;
		4'b0xx1:  grantOH = 4'b0001;
		4'b0x10:  grantOH = 4'b0010;
		4'b0x00:  grantOH = request
	end
	else if (preSelectedWarpOHReg == 4'b1000)
	begin
		case requset:
		4'bxxx1:  grantOH = 4'b0001;
		4'bxx10:  grantOH = 4'b0010;
		4'bx100:  grantOH = 4'b0100;
		4'bx000:  grantOH = request
	end
end


		/* 4'b0000:  grantOH = 4'b0000; */
		/* 4'b0001:  grantOH = 4'b0001; */
		/* 4'b0010:  grantOH = 4'b0010; */
		/* 4'b0011:  grantOH = 4'b0010; */
		/* 4'b0100:  grantOH = 4'b0100; */
		/* 4'b0101:  grantOH = 4'b0100; */
		/* 4'b0110:  grantOH = 4'b0010; */
		/* 4'b0111:  grantOH = 4'b0010; */
		/* 4'b1000:  grantOH = 4'b1000; */
		/* 4'b1001:  grantOH = 4'b1000; */
		/* 4'b1010:  grantOH = 4'b0010; */
		/* 4'b1011:  grantOH = 4'b0010; */
		/* 4'b1100:  grantOH = 4'b0100; */
		/* 4'b1101:  grantOH = 4'b0100; */
		/* 4'b1110:  grantOH = 4'b0010; */
		/* 4'b1111:  grantOH = 4'b0010; */


endmodule
