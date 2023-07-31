import defines::*;

module ift_fetch_tag(
	input 									    	clk,
	input 									    	reset,

	// output to ift data
	output 	logic[L1I_TAG_WIDTH - 1 : 0]  			ift_tags[NUM_L1I_WAYS],
	output  thread_idx_t 							ift_selected_thread_idx,
	output  li1_way_mask 							ift_way_valid_mask,
	output 											ift_tag_lookup_hit,
	output   	   	    							ift_tag_lookup_present,
	output 											ift_tag_lookup_exe_writable,
	output 											ift_tag_lookup_supervisor,
	output page_index_t								ift_tag_lookup_ppage_tag,

	// input from ift data
	input	                                        ifd_cache_miss,
	input   thread_idx_t							ifd_cache_miss_thread_idx,

	// From dcache_tag_stage
    input                       			        dt_invalidate_tlb_en,
    input                       			        dt_invalidate_tlb_all_en,
    input [ASID_WIDTH - 1:0]    			        dt_update_itlb_asid,
    input page_index_t          			        dt_update_itlb_vpage_idx,
    input                       			        dt_update_itlb_en,
    input                       			        dt_update_itlb_supervisor,
    input                       			        dt_update_itlb_global,
    input                       			        dt_update_itlb_present,
    input                       			        dt_update_itlb_executable,
    input page_index_t          			        dt_update_itlb_ppage_idx,

	//csr
	input thread_mask_t 							threadmask_en,
	
	// l1_l2_interface
	input 											l2i_fill_en,
	input l1i_set_addr_t		   			 		l2i_fill_set,
	output l1i_way_mask_t							l2i_fill_way_mask,
	input l1i_way_mask_t							l2i_upate_tag_mask,
	input l1i_set_addr_t                            l2i_update_addr,
	input [L1I_TAG_WIDTH - 1 : 0] 					l2i_update_tag,

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
	idx2oh	 idx2oh_instance1(ifd_thread_hit_idx, ifd_thread_hit_mask);

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
				else if (ifd_cache_miss && ifd_thread_hit_idx == thread_idx)
					pc_regs[thread_idx] <= pc_regs[thread_idx] - 4;
				else if (thread_selected_oh[thread_idx])
					pc_regs[thread_idx] <= pcRegs[thread_idx] + 4;
			end
		end
	endgenerate 

	assign cache_access_en = |thread_fetch_en_mask;

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
			 .read_en(cache_access_en),
			 .read_addr(pc_selected.set_idx),
			 .read_data(ift_tags[way_idx]),
			 .write_en(l2i_update_tag_en[way_idx]),
			 .write_addr(l2i_update_addr),
			 .write_data(l2i_update_tag),
			 .*
		);

		always_ff (posedge clk, posedge reset)
		begin
			if (reset)
			begin
				for (int set_idx = 0; set_idx < NUM_L1I_SETS; set_idx++)
					line_valid[set_idx] <= 0;
			end
			else if (l2i_upate_tag_en && l2i_upate_tag_way_mask[way_idx])
				line_valid[set_idx] <= 1;
		end
		
        assign way_hit_mask[way_idx] = line_valid[pc_selected.set_idx];
	end 
	endgenerate


	lru cache_lru#(
		.NUM_SETS(NUM_L1I_SETS)
	)(
		.fill_en(l2i_fill_en),
		.fill_set(l2i_fill_set),
		.fill_way_mask(l2i_fill_way_mask),
		.access_en(cache_access_en),
		.access_set(pc_selected.set_idx),
		.access_way_mask(ifd_thread_hit_mask),
		.update_en(~ifd_cache_miss),
		.*
	);

	


    page_idx_t dt_update_itlb_ppage_idx_latched;
    logic dt_update_itlb_present_latched;
    logic dt_update_itlb_executable_latched;
    logic dt_update_itlb_supervisor_latched;
    logic dt_update_itlb_global_latched;

	always_ff (posedge clk)
	begin
		dt_update_itlb_ppage_idx_latched            <= dt_update_itlb_ppage_idx  
		dt_update_itlb_present_latched              <= dt_update_itlb_present    
		dt_update_itlb_executable_latched           <= dt_update_itlb_executable 
		dt_update_itlb_supervisor_latched           <= dt_update_itlb_supervisor 
		dt_update_itlb_global_latched               <= dt_update_itlb_global     
	end

	tlb iTLB#(
		.NUM_ENTRIES(NUM_L1I_TLB_ENTRIES),
		.NUM_WAYS(NUM_L1I_TLB_WAYS)
	)(
    .lookup_en(cache_access_en),
    .update_en(dt_update_itlb_en),
    .invalidate_en(dt_invalidate_tlb_en),
    .invalidate_all_en(dt_invalidate_tlb_all_en),
    .request_vpage_idx(pc_selected.tag),
    .request_asid(dt_update_itlb_asid),
    .update_ppage_idx(dt_update_itlb_ppage_idx_lateched),
    .update_present(dt_update_itlb_present_lateched),
    .update_executable(dt_update_itlb_executable_lateched),
    .update_supervisor(dt_update_itlb_supervisor_lateched),
    .update_global(dt_update_itlb_global_lateched),

    .lookup_ppage_tag(ift_tag_lookup_ppage_tag),
    .lookup_hit(ift_tag_lookup_hit),
    .lookup_present(ift_tag_lookup_present),
    .lookup_exe_writable(ift_tag_lookup_exe_writable),
    .lookup_supervisor(ift_tag_lookup_supervisor),

    
endmodule 
