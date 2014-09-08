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
`timescale 1ns/100ps

module delay_tb;


localparam Tclk = 20;

//=============================================================================
// Clock
logic clk = 0;
always #(Tclk/2) clk <= !clk;

//=============================================================================
// Reset
logic reset_n=1;
initial begin
	reset_n <= 1;
	#(10*Tclk);
	reset_n <= 0;
	#(10*Tclk);
	reset_n <= 1;
end

//=============================================================================
// Module
parameter SIG_BITS	= 16;
parameter BLEND_B	= 4;	
parameter DLY_B		= 14;
parameter FDB_B		= 10;

logic [SIG_BITS-1:0]	in;
//------------ Output -------------------
wire [SIG_BITS-1:0]	out;
//------------ Control ------------------
logic [BLEND_B-1:0]	blend;
logic [DLY_B-1:0]	delay;
logic [FDB_B-1:0]	feedbk;

delay #( 
	.BLEND_B(BLEND_B)
) delay_inst ( .* );

//=============================================================================
// Test procedure
initial begin
	$display("=======================================");
	$display("=     delay module test procedure     =");
	$display("=======================================");

	wait(reset_n == 0);
	$display("%t: Going into reset", $time());

	wait(reset_n == 1);
	$display("%t: Going out of reset", $time());

	delay = 1000;
	#(25ms);
	
	delay = 500;
	#(10ms);


end

endmodule
