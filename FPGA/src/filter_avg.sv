module filter_avg #(
	parameter IO_B		= 16,	// input and output data width
	parameter NR_SAMP	= 200
) (
	//---------- Clock and reset-----------
	input				clk,
	input 				reset_n,
	//---------- Input --------------------
	input	[IO_B-1:0]	in_data,
	input				in_valid,
	//---------- Output -------------------
	output 	[IO_B-1:0]	out_data,
	output logic 		out_valid

);

logic [31:0] 				acc;
logic [$clog2(NR_SAMP)-1:0] cntr;

always_ff @ (posedge clk) begin

	if(in_valid) begin
		cntr	<= cntr + 1;
		acc		<= acc	+ in_data;
	end

	out_valid	<= 0;
	if(cntr == NR_SAMP) begin
		cntr		<= 0;
		acc			<= 0;
		out_data	<= acc[IO_B+$clog2(NR_SAMP)-1:$clog2(NR_SAMP)];
		out_valid	<= 1;
	end
end

endmodule
