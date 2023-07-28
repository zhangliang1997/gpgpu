package defines;

parameter NUM_THREADS_PER_SM  			= 4;
parameter NUM_THREADS_PER_SM_WIDTH 		= $log2(NUM_THREADS_PER_SM);
parameter NUM_SMS						= 2;

typedef logic[NUM_THREADS_PER_SM - 1 : 0] 				thread_bitmap_t;
typedef logic[NUM_THREADS_PER_SM_WIDTH - 1 : 0] 		thread_idx_t;

parameter RESET_PC                      = 0;

typedef  logic[31:0]  scalar_t;

parameter NUM_VECTOR_LINES              = 16;

parameter CACHE_LINE_BYTES              = NUM_VECTOR_LINES * 4;
parameter CACHE_LINE_BYTE_OFFSET_WIDTH  = $log2(CACHE_LINE_BYTES);


parameter NUM_L1I_SETS                   = 32;
parameter NUM_L1I_WAYS                   = 4;
parameter L1I_SETS_WIDTH                 = $log2(NUM_L1I_SETS);
parameter L1I_TAG_WIDTH                  = 32 - (L1I_SETS_WIDTH + CACHE_LINE_BYTE_OFFSET_WIDTH);

parameter NUM_L1I_TLB_WAYS				 = 4;
parameter NUM_L1I_TLB_SETS				 = 16;


parameter ASID_WIDTH 					 = 8;

parameter PAGE_SIZE 					 = 4096;
parameter PAGE_INDEX_BITS 			 	 = 32 - $clog2(PAGE_SIZE);
typedef  logic[PAGE_INDEX_BITS - 1 : 0]   page_index_t;


typedef logic [L1I_TAG_WIDTH - 1 : 0] 		l1i_tag_t;
typedef logic [L1I_SETS_WIDTH - 1 : 0] 		l1i_set_t;

typedef logic [NUM_L1I_WAYS -1 : 0] 		l1i_way_bitmap_t;
typedef logic [L1I_WAYS_WIDTH -1 : 0] 		l1i_way_idx_t;


typedef struct packed {
	l1i_tag_t tag;
	l1i_set_t set_idx;
    logic [CACHE_LINE_BYTE_OFFSET_WIDTH - 1 : 0] offset;
} l1i_addr_t;

endpackage
