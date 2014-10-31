///////////////////////////////////////////////////////////////////////////////
//   __  __          _____      _         _   _  ______      _______ _____   //
//  |  \/  |   /\   |  __ \    | |  /\   | \ | |/ __ \ \    / /_   _/ ____|  //
//  | \  / |  /  \  | |__) |   | | /  \  |  \| | |  | \ \  / /  | || |       //
//  | |\/| | / /\ \ |  _  /_   | |/ /\ \ | . ` | |  | |\ \/ /   | || |       //
//  | |  | |/ ____ \| | \ \ |__| / ____ \| |\  | |__| | \  /   _| || |____   //
//  |_|  |_/_/    \_\_|  \_\____/_/    \_\_| \_|\____/   \/   |_____\_____|  //
//                                                                           //
//                          JAN MARJANOVIC, 2014                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


//`define DEBUG

module filter_50 #(
	parameter IO_B		= 16,	// input and output data width
	parameter INT_B		= 7,	// integer part of internal quotient
	parameter FRAC_B	= 24	// integer part of internal quotient
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

localparam Q_BITS = INT_B + FRAC_B + 1;

/*
localparam signed [Q_BITS-1:0] A [3] = 
	{  32'h02fb779f, 32'hfd09029f, 32'h00fb85a7 };
localparam signed [Q_BITS-1:0] B [4] = 
	{  32'h00009341, 32'hffff6ccc, 32'hffff6ccc, 32'h00009341 };
*/
localparam bit signed [Q_BITS-1:0] A [3] = 
	'{  32'h02fb779f, 32'hfd09029f, 32'h00fb85a7 };
localparam bit signed [Q_BITS-1:0] B [4] = 
	'{  32'h00009341, 32'hffff6ccc, 32'hffff6ccc, 32'h00009341 };

localparam _nr_params = $size(A) + $size (B);

logic [2*Q_BITS-1:0] acc;
logic [2*Q_BITS-1:0] mult;

logic signed [Q_BITS-1:0] y [$size(A)];
logic signed [Q_BITS-1:0] x [$size(B)];

logic [Q_BITS-1:0] out_reg;
assign out_data = out_reg[FRAC_B-3:(FRAC_B-IO_B-2)];

//=============================================================================
// save old values

always_ff @ (posedge clk or negedge reset_n) begin
	if ( !reset_n ) begin
		for(int i = 0; i < $size(x); i++)
			x[i]	<= 0;
		for(int i = 0; i < $size(y); i++)
			y[i]	<= 0;
	end else begin
		if( out_valid ) begin
			for(int i = $size(A)-1; i > 0; i--) begin
				y[i] = y[i-1];
			end
			y[0] = out_reg;
		end

		if( in_valid ) begin
			for(int i = $size(B)-1; i > 0; i--) begin
				x[i] = x[i-1];
			end
			//x[0] = {8'd0, in_data, 8'd0};
			x[0] = {{(Q_BITS-(FRAC_B)){1'b0}}, in_data, {(FRAC_B-IO_B){1'b0}}};
		end
	end
end


//=============================================================================
// state machine for calculation
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
				acc		<= acc + mult;
`ifdef DEBUG
				$display("%t acc = %d",$time(), acc/2**FRAC_B);
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
				acc		<= acc + mult;
`ifdef DEBUG
				$display("%t acc = %d",$time(), acc/2**FRAC_B);
`endif
			end
			LAST_ACC: begin
				acc		<= acc + mult;
`ifdef DEBUG
				$display("%t acc = %d",$time(), acc/2**FRAC_B);
`endif
				state	<= DONE;
			end
			//========================================================
			DONE: begin
				out_valid	<= 1;
				out_reg		<= acc[FRAC_B+Q_BITS-1:FRAC_B];
				state		<= IDLE;
`ifdef DEBUG
				$display("%t out = %d",$time(), acc/2**FRAC_B);
`endif
			end
			//========================================================
		endcase
	end
end


endmodule
