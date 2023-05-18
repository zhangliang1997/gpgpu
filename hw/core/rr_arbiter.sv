import defines::*;

module rr_arbiter(
	input								clk,
	input								reset,
	input[NUM_WARPS_PER_SM - 1:0]      	request,
	output logic[NUM_WARPS_PER_SM - 1:0]     	grantOH

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
	case(preSelectedWarpOHReg)
	4'b0001:
		begin
			case(1'b1)
				request[0]:  grantOH = 4'b0001;
				request[1]:  grantOH = 4'b0010;
				request[2]:  grantOH = 4'b0100;
				request[3]:  grantOH = 4'b1000;
				default   :  grantOH = 4'b1000;
			endcase  
		end
	4'b0010:
		begin
			case(1'b1)
				request[0]:  grantOH = 4'b0001;
				request[1]:  grantOH = 4'b0010;
				request[2]:  grantOH = 4'b0100;
				request[3]:  grantOH = 4'b1000;
				default   :  grantOH = 4'b1000;
			endcase  
		end
	4'b0100:
		begin
			case(1'b1)
				request[0]:  grantOH = 4'b0001;
				request[1]:  grantOH = 4'b0010;
				request[2]:  grantOH = 4'b0100;
				request[3]:  grantOH = 4'b1000;
				default   :  grantOH = 4'b1000;
			endcase  
		end
	4'b1000:
		begin
			case(1'b1)
				request[0]:  grantOH = 4'b0001;
				request[1]:  grantOH = 4'b0010;
				request[2]:  grantOH = 4'b0100;
				request[3]:  grantOH = 4'b1000;
				default   :  grantOH = 4'b1000;
			endcase  
		end
	default: grantOH = 4'b0001;
	endcase
end
endmodule
