import defines::*;


module tlb
#(
    parameter  NUM_ENTRIES = 64,
    parameter  NUM_WAYS    = 4
)
(
    input                     clk,
    input                     reset,

    input                     lookup_en,
    input                     update_en,
    input                     invalidate_en,
    input                     invalidate_all_en,
    input page_index_t        request_vpage_idx,
    input [ASID_WIDTH - 1:0]  request_asid,
    input page_index_t        update_ppage_idx,
    input                     update_present,
    input                     update_exe_writable,
    input                     update_supervisor,
    input                     update_global,

    output page_index_t       lookup_ppage_idx,
    output logic              lookup_hit,
    output logic              lookup_present,
    output logic              lookup_exe_writable,
    output logic              lookup_supervisor
);



	logic NUM_SETS = NUM_ENTRIES / NUM_WAYS;
	logic tlb_read_en;
	logic SET_WIDTH = $clog2(NUM_SETS);
	logic tlb_read_addr = request_vpage_idx[SET_WIDTH - 1 : 0];
	logic page_index_t vpage_idx_all_ways[NUM_WAYS];
	logic page_index_t ppage_idx_all_ways[NUM_WAYS];
	logic [ASID_WIDTH - 1 : 0]  asid_all_ways[NUM_WAYS];
	logic global_all_ways[NUM_WAYS];
	logic supervisor_all_ways[NUM_WAYS];
	logic exe_writable_all_ways[NUM_WAYS];
	logic present_all_way[NUM_WAYS];
	logic way_hit_oh[NUM_WAYS];
    logic page_index_t  update_ppage_idx_latched;
    logic page_index_t  update_vpage_idx_latched;
    logic update_present_latched;
    logic update_exe_writable_latched;
    logic update_supervisor_latched;
    logic update_global_latched;
    logic [ASID_WIDTH - 1 : 0 ] update_asid_latched;
	logic tlb_write_addr = update_vpage_idx_latched[SET_WIDTH - 1 : 0];

	logic page_index_t 			read_vpage_idx_all_ways[NUM_WAYS];
	logic page_index_t 			read_ppage_idx_all_ways[NUM_WAYS];
	logic 						read_supervisor[NUM_WAYS];
	logic 						read_exe_writable[NUM_WAYS];
	logic 						read_present[NUM_WAYS];
	logic invalidate_en_latched;

	assign tlb_read_en = lookup_en || update_en || invalidate_en;


	genvar way_idx;
	generate
	for (way_idx = 0; way_idx < NUM_WAYS; way_idx++)
	begin
		logic entry_valid[NUM_SETS];
		logic [ASID_WIDTH - 1 : 0] asid;
		logic way_valid;
		sram1w1r #(
			.SETS_NUM(NUM_SETS),
			.DATA_WIDTH(PAGE_INDEX_BITS * 2 + ASID_WIDTH + 4)
		) 
		tlb_ram(
			.read_en(tlb_read_en),
			.read_addr(tlb_read_addr),
			.read_data({read_vpage_idx_all_ways[way_idx],
						read_ppage_idx_all_ways[way_idx],
						asid,
						global,
						read_supervisor[way_idx],
						read_exe_writable[way_idx],
						read_present[way_idx]}),
			.write_en(update_en_latched && way_updated_oh[way_idx]),
			.write_addr(tlb_write_addr),
			.write_data({update_vpage_idx_latched,
						 update_ppage_idx_latched,
					 	 update_asid_latched,
						 update_global_latched,
					 	 update_supervisor_latched,
					     update_exe_writable_latched,
						 update_present_latched}),
			.*
		);

		always_ff @(posedge clk, posedge reset)
		begin
			if (reset) 
			begin
				for (unsigned i = 0; i < NUM_SETS; i++)
					entry_valid[i] <= 0;        
				else if (invalidate_en_latched && way_update_oh[way_idx] )
                	entry_valid[tlb_write_addr] <= 0;
				else if (update_en_latched && way_update_oh[way_idx])
					entry_valid[tlb_write_addr] <= 1;
			end 

		end
		always_comb @(*)
		begin
			if (invalidate_en_latched && way_updated_oh[way_idx] && tlb_write_addr == tlb_read_addr)
				way_valid = 0;
			else
				way_valid = entry_valid[tlb_read_addr];
		end
		assign way_hit_oh[way_idx] = (vpage_idx_all_ways[way_idx] == request_vpage_idx) 
									 && way_valid && ((asid == request_asid) || global);

	end
	endgenerate

	assign lookup_hit = |way_hit_oh;

	always @(posedge clk, posedge reset)
	begin
		update_vpage_idx_latched       <= request_vpage_idx;
		update_ppage_idx_latched       <= update_ppage_idx;
		update_present_latched         <= update_present;
		update_exe_writable_latched    <= update_exe_writable;
		update_supervisor_latched      <= update_supervisor;
		update_global_latched          <= update_global;
		update_asid_latched			   <= request_asid;
		invalidate_en_latched 	 	   <= invalidate_en;
	end
	
	always_comb @(*)
	begin
 		case (way_hit_oh)
			4'b0001:
				begin
					lookup_ppage_idx     	=   read_ppage_idx_all_ways[0];
					lookup_present     		=   read_present_all_ways[0];
					lookup_exe_writable     =   read_exe_writable_all_ways[0];
					lookup_supervisor     	=   read_supervisor_all_ways[0];
				end
			4'b0010:
				begin
					lookup_ppage_idx     	=   read_ppage_idx_all_ways[1];
					lookup_present     		=   read_present_all_ways[1];
					lookup_exe_writable     =   read_exe_writable_all_ways[1];
					lookup_supervisor     	=   read_supervisor_all_ways[1];
				end
			4'b0100:
				begin
					lookup_ppage_idx     	=   read_ppage_idx_all_ways[2];
					lookup_present     		=   read_present_all_ways[2];
					lookup_exe_writable     =   read_exe_writable_all_ways[2];
					lookup_supervisor     	=   read_supervisor_all_ways[2];
				end
			4'b1000:
				begin
					lookup_ppage_idx     	=   read_ppage_idx_all_ways[3];
					lookup_present     		=   read_present_all_ways[3];
					lookup_exe_writable     =   read_exe_writable_all_ways[3];
					lookup_supervisor     	=   read_supervisor_all_ways[3];
				end
			default:
				begin
					lookup_ppage_idx     	=   0;
					lookup_present     		=   0;
					lookup_exe_writable     =   0;
					lookup_supervisor     	=   0;
				end
		endcase
	end

	always_ff @(posedge clk, posedge reset)
	begin
		if (reset)
			way_update_oh <= NUM_WAYS'(1);
		else if (update_en_latched)
			way_udpate_oh <= {way_update_oh[NUM_WAYS - 2 : 0], way_update_oh[NUM_WAYS - 1]};
	end

endmodule
