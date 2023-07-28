import defines::*;

module ift_fetch_tag(
	input 									    	clk,
	input 									    	reset,
	input 	 										pc_selected,


	// output to ift data
	output 	logic[L1I_TAG_WIDTH - 1 : 0]  			ift_tags[NUM_L1I_WAYS],
	output  logic[NUM_L1I_WAYS - 1 : 0] 			ift_way_valid,
	output  thread_idx_t 							ift_selected_thread_idx,
	output  li1_way_mask 							ift_way_valid_mask,

	// input from ift data
	input 											ifd_upate_tag_en,
	input 	l1i_tag_mask_t							ifd_upate_tag_way_mask,
	input	                                        ifd_cache_miss,
	/* input   thread_idx_t							ifd_cache_miss_thread_idx, */

	//csr
	input thread_mask_t 								threadmask_en,
	
	// l1_l2_interface
	input 											l12i_fill_en,
	input [L1I_SETS_WIDTH - 1 : 0]					l12i_fill_set,
	output logic[NUM_L1I_WAYS - 1 : 0]				l12i_fill_way_oh,

	// thread_select_stage
	input thread_mask_t								ts_thread_fetch_en_mask, 
	// writeback module
	input 											write_back_en,
	input 											write_back_pc,
	input 											write_back_threadId,


);	

	l1i_addr_t  								pcRegs[NUM_THREADS_PER_SM];
	l1i_addr_t  								pc_selected;

	logic[NUM_THREADS_PER_SM - 1:0] 				selected_thread_oh;
	logic[NUM_THREADS_PER_SM_WIDTH - 1 : 0] 		selected_thread_idx;
	thread_mask_t					  				thread_active_mask;
	thread_mask_t					  				thread_fetch_en_mask;

	always_ff @(posedge clk, posedge reset)
	begin
		if (reset)
			thread_active_mask <= ts_thread_fetch_en_mask;
		else
			thread_active_mask <= thread_fetch_en_mask;
		
	end

	assign thread_fetch_en_mask = (thread_active_mask | l2_response_thread_wakeup_mask) & ~icache_wait_mask & ts_thread_fetch_en_mask;  
	assign icache_wait_mask = {{NUM_THREADS_PER_SM{ifd_cache_miss}} & selected_thread_oh_latched};

	rr_arbiter arbiter(clk, reset, thread_fetch_en_mask, thread_selected_oh);

	oh2idx   oh2idx_thread(thread_selected_oh, thread_selected_idx);

	assign pc_selected = pcRegs[thread_selected_idx];


	genvar thread_idx;
	generate
		for(thread_idx = 0; thread_idx < NUM_WARPS_PER_SM; thread_idx++)
		begin
			always_ff @(posedge clk, posedge reset)
			begin
				if (reset)
					pc_regs[thread_idx] <= RESET_PC;
				else if (wb_rollback_en && wb_rollback_thread_idx == thread_idx)
					pc_regs[thread_Idx] <= wb_rollback_pc;
				else if (ifd_cache_miss && ifd_thread_idx == thread_idx)
					pc_regs[thread_idx] <= pc_regs[thread_idx] - 4;
				else if (thread_selected_oh[thread_idx])
					pc_regs[thread_idx] <= pcRegs[thread_idx] + 4;
			end
		end
	endgenerate 

	assign sram_tag_read_en = |thread_fetch_en_mask;

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
			 .read_en(sram_tag_read_en),
			 .read_addr(pc_selected.set_idx),
			 .read_data(sram_tag_read_data[way_idx]),
			 .write_en(sram_tag_write_en),
			 .write_addr(sram_tag_write_addr),
			 .write_data(sram_tag_write_data[way_idx]),
			 .*
		);

		always_ff (posedge clk, posedge reset)
		begin
			if (reset)
			begin
				for (int set_idx = 0; set_idx < NUM_L1I_SETS; set_idx++)
					line_valid[set_idx] <= 0;
			end
			else if(
		end
		
        assign way_hit_mask[way_idx] = line_valid[pc_selected.set_idx];
	end 
	endgenerate


	lru cache_lru#(
		.NUM_SETS()
	)(
		.fill_en(),
		.fill_set(),
		.fill_way_mask(),
		.access_en(),
		.update_en(),
		.access_set(),
		.access_way_mask(),
		.*
	);

	
	tlb iTLB#(
		.NUM_ENTRIES(),
		.NUM_WAYS()
	)(
    .lookup_en(),
    .update_en(),
    .invalidate_en(),
    .invalidate_all_en(),
    .request_vpage_idx(),
    .request_asid(),
    .update_ppage_idx(),
    .update_present(),
    .update_exe_writable(),
    .update_supervisor(),
    .update_global(),

    .lookup_ppage_idx(),
    .lookup_hit(),
    .lookup_present(),
    .lookup_exe_writable(),
    .lookup_supervisor(),

	
endmodule 
