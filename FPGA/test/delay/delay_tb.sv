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


localparam Tclk = 10;

logic clk = 0;
always #(Tclk/2) clk <= !clk;


logic reset_n=1;
initial begin
	reset_n <= 1;
	#(10*Tclk);
	reset_n <= 0;
	#(10*Tclk);
	reset_n <= 1;
end


parameter SIG_BITS	= 16;
parameter BLEND_B	= 10;	
parameter DLY_B		= 14;
parameter FDB_B		= 10;

wire [SIG_BITS-1:0]	in;
//------------ Output -------------------
wire [SIG_BITS-1:0]	out;;
//------------ Control ------------------
wire [BLEND_B-1:0]	blend;
wire [DLY_B-1:0]	delay;
wire [FDB_B-1:0]	feedbk;

delay delay_inst ( .* );

endmodule
