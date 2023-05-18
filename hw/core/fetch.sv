import defines::*;

module fetch(

	logic clk,
	logic reset

);	



scalar_t  pcRegs[NUM_WARPS_PER_SM];
logic[NUM_WARPS_PER_SM - 1:0] selectedWrapOH;

genvar wrapIdx;
generate
    for(wrapIdx = 0; wrapIdx <= NUM_WARPS_PER_SM; wrapIdx++)
	begin
		always_ff @(posedge clk, posedge reset)
		begin
			if (reset)
				pcRegs[wrapIdx] <= RESET_PC;
			else if (selectedWrapOH[wrapIdx])
				pcRegs[wrapIdx] <= pcRegs[wrapIdx] + 4;
		end
	end

endgenerate 

logic[NUM_WARPS_PER_SM - 1:0]  activeMask4WrapsPerSMReg;

rr_arbiter arbiter(clk, reset, activeMask4WrapsPerSMReg, selectedWrapOH);




endmodule 
