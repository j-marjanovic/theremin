
`define DEBUG

module filter #(
	parameter IN_B	= 16,
	parameter OUT_B	= 32
) (
	input	clk,
	input 	reset_n,

	input	[IN_B-1:0]	in_data,
	input				in_valid,

	output logic [OUT_B-1:0]	out_data,
	output logic 			out_valid

);

//localparam [23:0] A [4] = { 24'h010000, 24'hfd0489, 24'h02f6fd, 24'hff047b };
// multiplied by -1
localparam signed [31:0] A [3] = { 32'h02fb779f, 32'hfd09029f, 32'h00fb85a7 }; // a starta z a1
localparam signed [31:0] B [4] = { 32'h00009341, 32'hffff6ccc, 32'hffff6ccc, 32'h00009341 }; // starta z b0

localparam _nr_params = $size(A) + $size (B);


logic [31+32:0] acc;
logic [31+32:0] mult;

logic signed [OUT_B-1:0] y [$size(A)];
logic signed [31-1:0] x [$size(B)];



always_ff @ (posedge clk or negedge reset_n) begin
	if ( !reset_n ) begin
		for(int i = 0; i < $size(x); i++)
			x[i]	<= 0;
		for(int i = 0; i < $size(y); i++)
			y[i]	<= 0;
	end else begin
		if( out_valid ) begin
			for(int i = $size(A); i > 0; i--) begin
				y[i] = y[i-1];
			end
			y[0] = out_data;
		end

		if( in_valid ) begin
			for(int i = $size(B); i > 0; i--) begin
				x[i] = x[i-1];
			end
			x[0] = {8'd0, in_data, 8'd0};
		end
	end
end



logic [$clog2(_nr_params)-1:0] cntr;

enum { 	IDLE,
		CALC_A,
		CALC_B,
		LAST_ACC,
		DONE } state;

always_ff @ (posedge clk or negedge reset_n) begin
	if ( !reset_n ) begin
		state	<= IDLE;
	end else begin

		out_valid	<= 0;

		case(state)
			//========================================================
			IDLE: begin
				if(in_valid) begin
					state	<= CALC_A;
					cntr	<= 0;
					acc		<= 0;
					mult	<= 0;
`ifdef DEBUG
					$display("------------------------------");
`endif
				end
			end
			//========================================================
			CALC_A: begin
				cntr <= cntr + 1;


				if( cntr == $size(A) - 1 ) begin
					state	<= CALC_B;
					cntr	<= 0;
				end

				mult	<= A[cntr] * y[cntr];
				acc		<= acc + mult;//[23+16:16];
`ifdef DEBUG
				/*$display("");
				$display("%t cntr = %d", $time(), cntr);
				$display("%t A mult = %x * %x",$time(), A[cntr], y[cntr]);
				$display("%t A mult res = %x",$time(), mult);
				$display("%t A acc += %x",$time(), mult[23+16:16]);*/
				$display("%t acc = %d",$time(), acc/2**24);
`endif
			end
			//========================================================
			CALC_B: begin
				cntr <= cntr + 1;


				if( cntr == $size(B) - 1 ) begin
					state	<= LAST_ACC;
					cntr	<= 0;
				end 

				mult	<= B[cntr] * x[cntr];
				acc		<= acc + mult;//[23+16:16];
`ifdef DEBUG
/*				$display("");
				$display("%t cntr = %d", $time(), cntr);
				$display("%t B mult = %x * %x",$time(), B[cntr], x[cntr]);
				$display("%t B mult res = %x",$time(), mult);
				//$display("%t B acc += %x",$time(), mult[23+16:16]);*/
				$display("%t acc = %d",$time(), acc/2**24);
`endif
			end
			LAST_ACC: begin
				acc		<= acc + mult;//[23+16:16];
`ifdef DEBUG
				$display("%t acc = %d",$time(), acc/2**24);
`endif
				state	<= DONE;
			end
			//========================================================
			DONE: begin
				out_valid	<= 1;
				//out_data	<= {8'd0, acc[23:16]};
				//out_data	<= {2'd0, acc[23:10]};
				out_data	<= acc[24+31:24];
				state		<= IDLE;

`ifdef DEBUG
				$display("%t acc = %d",$time(), acc/2**24);
`endif
			end
			//========================================================
		endcase
	end
end


endmodule
