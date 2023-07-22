import defines::*;

module ift_fetch_tag(
	input 									    	clk,
	input 									    	reset,
	input 	 										pc_selected,
	output 	logic[L1I_TAG_WIDTH - 1 : 0],  			tags[NUM_L1I_WAYS],
	output  logic 									way_valid[NUM_L1I_WAYS]
);	

l1i_addr_t  								pcRegs[NUM_WARPS_PER_SM];
l1i_addr_t  								pc_selected;

logic[NUM_WARPS_PER_SM - 1:0] 				selectedWarpOH;
logic[NUM_WARPS_PER_SM_WIDTH - 1 : 0] 		selectedWarpIdx;
logic[NUM_WARPS_PER_SM - 1:0]  				activeMask4warpsPerSMReg;


rr_arbiter arbiter(clk, reset, activeMask4warpsPerSMReg, selectedWarpOH);

oh2idx   oh2idxWarp(selectedWarpOH, selectedWarpIdx);

assign pc_selected = pcRegs[selectedWarpIdx];


genvar warpIdx;
generate
    for(warpIdx = 0; warpIdx < NUM_WARPS_PER_SM; warpIdx++)
	begin
		always_ff @(posedge clk, posedge reset)
		begin
			if (reset)
				pcRegs[warpIdx] <= RESET_PC;
			else if (selectedWarpOH[warpIdx])
				pcRegs[warpIdx] <= pcRegs[warpIdx] + 4;
		end
	end
endgenerate 


genvar way_idx;
generate
for (way_idx = 0; way_idx < NUM_L1I_WAYS; way_idx++)
begin
	logic line_valid[NUM_L1I_SETS];
	sram1w1r #(
		.SETS_NUM(NUM_L1I_SETS),
		.DATA_WIDTH(L1I_TAG_WIDTH)		
	 )
	 sram_tag(
		 .read_en(1'b1),
		 .read_addr(pc_selected.set_idx),
		 .read_data(tags[way_idx]),
		 .write_en(1'b0),
		 .write_addr(0),
		 .write_data(0),
		 .*
	);
	way_valid[way_idx] = line_valid[pc_selected.set_idx];
end 
endmodule 
