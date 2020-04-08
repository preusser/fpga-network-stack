module axis_reg #(
	int unsigned DATA_WIDTH
)(
	input	logic	clk,
	input	logic	rst,

	input	logic					i_valid,
	output	logic					i_ready,
	input	logic [DATA_WIDTH-1:0]	i_data,

	output	logic					o_valid,
	input	logic					o_ready,
	output	logic [DATA_WIDTH-1:0]	o_data
);

	typedef struct {
		logic					vld;
		logic [DATA_WIDTH-1:0]	dat;
	} stage_t;
	stage_t Stage[2] = '{ default: stage_t'{ vld: 0, dat: 'x } };

	always_ff @(posedge clk) begin
		if(rst) begin
			Stage <= '{ default: stage_t'{ vld: 0, dat: 'x } };
		end
		else begin
			if(!Stage[0].vld)	Stage[0].dat <= i_data;
			Stage[0].vld <= (i_valid || Stage[0].vld) && Stage[1].vld && !o_ready;

			if(o_ready || !Stage[1].vld)	Stage[1].dat <= Stage[0].vld? Stage[0].dat : i_data;
			Stage[1].vld <= (Stage[1].vld && !o_ready) || Stage[0].vld || i_valid;
		end
	end
	assign	i_ready	= !Stage[0].vld;
	assign	o_valid	= Stage[1].vld;
	assign	o_data	= Stage[1].dat;

endmodule : axis_reg