import defines::*;

module fetch(

);	


scalar_t  pcRegs[NUM_WRAPS_PER_CORE];

genvar wrapId;
generate
    for(wrapIdx = 0; wrapIdx <= NUM_WRAPS_PER_CORE; wrapIdx++)
	begin
		always_ff @(posedge clk, posedge reset)
		begin
			if (reset)
				pcRegs[wrapIdx] <= RESET_PC;
			else if (slectedWrapOH[wrapIdx])
				pcRegs[wrapIdx] <= pcRegs[wrapIdx] + 4;
		end
	end

endgenerate 



logic[NUM_WRAPS_PER_CORE - 1:0]  activeMask4WrapsPerSMReg;



endmodule 
