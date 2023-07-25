module sram1w1r
#(
	parameter SETS_NUM = -1,	
	parameter DATA_WIDTH = -1

)
(
	input clk,

	input read_en,
	input read_addr,
	output logic[DATA_WIDTH -1 : 0]  read_data,

	input write_en,
	input write_addr,
	input [DATA_WIDTH -1 : 0] write_data
);


logic[DATA_WIDTH - 1 : 0] data [SETS_NUM];

always_ff @(posedge clk)
begin
	if (read_en && write_en && read_addr == write_addr)
		read_data <= write_data;
	else if (read_en)
		read_data <= data[read_addr];

	if (write_en)
		data[write_addr] <= write_data;
end



endmodule
