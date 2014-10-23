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

module filter_tb;


localparam 			IN_B = 16;
localparam 			OUT_B = 32;

localparam real 	Tclk = 10.0;

bit 				clk = 0;
bit 				reset_n = 1;

logic	[15:0]	in_data = 0;
logic				in_valid;

logic [15:0]	out_data;
logic 				out_valid;


//=============================================================================

always #(Tclk/2) clk <= !clk;

initial begin
	#(10*Tclk);
	reset_n	= 0;
	#(5*Tclk);
	reset_n = 1;
end

//=============================================================================

int counter = 0, idx = 0;


logic [16:0] signal [10000];
initial begin
`include "signal.h"
end


always @ (posedge clk) begin	
	in_valid	<= 0;
	counter++;
	if(counter == 49) begin
		in_valid	<= 1;
		in_data		<= signal[idx++];
		counter = 0;

	end
end

/*
always @ (posedge clk) begin	
	in_valid	<= 0;
	counter++;
	if(counter == 49) begin
		in_valid	<= 1;
		counter = 0;
	end
end

initial begin
	forever begin
		#(100us);

		@(posedge clk);
		in_valid	<= 1;

		@(posedge clk);
		in_valid	<= 0;

	end
end

initial begin
	in_data	= 16'h0000;
	#(1us);
	in_data	= 16'h4000;
	#(100ms);
	in_data	= 16'h0005;
	#(100ms);
	in_data	= 16'h4000;
	#(100ms);
	in_data	= 16'h2000;
	#(100ms);

end
*/

//=============================================================================
filter filter_inst ( .* );


endmodule
