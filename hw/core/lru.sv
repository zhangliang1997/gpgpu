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

)
(
);













endmodule
