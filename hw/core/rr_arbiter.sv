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
		4'b???1:  grantOH = 4'b0001;
		4'b??10:  grantOH = 4'b0010;
		4'b?100:  grantOH = 4'b0100;
		4'b1000:  grantOH = 4'b1000;
	end
	else if (preSelectedWarpOHReg == 4'b0001)
	begin
		case requset:
		4'b??1?:  grantOH = 4'b0010;
		4'b?10?:  grantOH = 4'b0100;
		4'b100?:  grantOH = 4'b1000;
		4'b000?:  grantOH = request
	end
	else if (preSelectedWarpOHReg == 4'b0010)
	begin
		case requset:
		4'b?1??:  grantOH = 4'b0100;
		4'b10??:  grantOH = 4'b1000;
		4'b00?1:  grantOH = 4'b0001;
		4'b00?0:  grantOH = request
	end
	else if (preSelectedWarpOHReg == 4'b0100)
	begin
		case requset:
		4'b1???:  grantOH = 4'b1000;
		4'b0??1:  grantOH = 4'b0001;
		4'b0?10:  grantOH = 4'b0010;
		4'b0?00:  grantOH = request
	end
	else if (preSelectedWarpOHReg == 4'b1000)
	begin
		case requset:
		4'b???1:  grantOH = 4'b0001;
		4'b??10:  grantOH = 4'b0010;
		4'b?100:  grantOH = 4'b0100;
		4'b?000:  grantOH = request
	end
end
endmodule
