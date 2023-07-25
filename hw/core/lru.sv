import defines::*;

// read
// 1. when
// 	  1.1  when response data return to L1, we need select a way to save
// 	  response. So we need read from LRU sram. 
// 2. where
// 	  2.1 fill set idx
// 3. what
// 		3.1 lru flags
// write
// 1. when
// 		1.1 when L1 cache hit, we need udpate LRU flags
// 		1.2 when fill response data into L1, we need update lru flags
// 2. where
// 		1.1 last cycle L1 access addr
// 		2.2 last cycle L1 fill addr
// 3. what
// 		3.1 according to cache hit way and lru flags and pseudo lru algorithm
// 		to calculate 
// 		3.2 according to fill way and lru flags and pseduo lru algorithm

/*
      b                                             
     / \
	a   c
   / \ / \
  1  2 3  4
*/

module lru#(
	parameter NUM_SETS = -1,
	parameter SET_WIDTH = $clog2(NUM_SETS)

)
(
   input fill_en,
   input [SET_WIDTH - 1 : 0] fill_set, 
   output logic [NUM_L1I_WAYS - 1 : 0] fill_way_oh,

   input access_en,
   input update_en,
   input [SET_WIDTH - 1 : 0] access_set, 
   input [NUM_L1I_WAYS - 1 : 0] access_way_oh,
);

	logic sram_read_en;
	logic [SET_WIDTH - 1 : 0]  sram_read_addr;
	logic [SET_WIDTH - 1 : 0]  fill_set_latched;
	logic [SET_WIDTH - 1 : 0]  access_set_latched;
	logic [2 : 0] lru_flag; 
	logic sram_write_en;
	logic sram_write_addr;
	logic sram_write_data;
	logic fill_en_latched;
    logic [NUM_L1I_WAYS - 1 : 0] upate_way_oh;
	assign sram_read_en = fill_en || access_en;
    assign sram_read_addr = fill_en ? fill_set : access_set;
	assign sram_write_en = fill_en_latched || update_en;
	assign sram_write_addr = fill_en_latched ? fill_set_latched : access_set_latched;
	assign udpate_way_oh = fill_en_latched ? lru_flag : access_way_oh;
	

	sram1w1r sram_lru#(
		.NUM_SETS(NUM_SETS),
		.DATA_WIDTH(SET_WIDTH)
	)(
		.read_en(sram_read_en),
		.read_addr(sram_read_addr),
		.read_data(lru_flag),
		.write_en(sram_write_addr),
		.write_addr(sram_write_addr),
		.write_data(sram_write_data)
	);

	always_ff @(posedge clk, posedge reset)
	begin
		if (reset)
			fill_en_latched <= 0;
			fill_set_latched <= 0;
			access_set_latched <= 0;
		else
			fill_en_latched <= fill_en;
			fill_set_latched <= fill_set;
			access_set_latched <= access_set;
	end

	always_comb @(*)
	begin
		case (update_way_oh)
			4'b0001: sram_write_data = {1,1,lru_flag[0]};
			4'b0010: sram_write_data = {0,1,lru_flag[0]};
			4'b0100: sram_write_data = {lru_flag[2],0,1};
			4'b1000: sram_write_data = {lru_flag[2],0,0};
			default: sram_write_data = 0;
		endcase
	end

	always_comb @(*)
	begin
		casez (lru_flag)
			3'b00?: fill_way_oh = 4'b0001; 
			3'b10?: fill_way_oh = 4'b0010; 
			3'b?10: fill_way_oh = 4'b0100; 
			3'b?11: fill_way_oh = 4'b1000; 
			default: fill_way_oh = 4'b0000;
		endcase
	end

endmodule
