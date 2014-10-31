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

module antilog_tb;


localparam Tclk = 10;

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

parameter IN_B		= 16;
parameter OUT_B		= 12;
parameter LUT_B		= 9;
parameter IN_OFFSET = 3100;

logic	[IN_B-1:0]	in_data  = 0;
logic				in_valid = 0;

wire 	[OUT_B-1:0]	out_data;
wire 		 		out_valid;

antilog  #(
	.IN_B		( IN_B		),
	.OUT_B		( OUT_B		),
	.LUT_B		( LUT_B		),
	.IN_OFFSET	( IN_OFFSET	)
) antilog_inst ( 
	.* 
);


//=============================================================================
// Test procedure
initial begin
	$display("=======================================");
	$display("=    antilog module test procedure    =");
	$display("=======================================");

	wait(reset_n == 0);
	$display("%t: Going into reset", $time());

	wait(reset_n == 1);
	$display("%t: Going out of reset", $time());

	for(int i = 0; i < 2**IN_B; i++) begin
		in_data	<= i;
		@(posedge clk)
			in_valid	<= 1;
		@(posedge clk)
			in_valid	<= 0;

		#(10*Tclk);
	end

	$stop();
end

endmodule
