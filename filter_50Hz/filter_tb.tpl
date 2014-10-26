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


localparam real Tclk = 10.0;

localparam SAMPL_CNTR = 100;

bit 			clk = 0;
bit 			reset_n = 1;

logic	[#IO_B#-1:0]	in_data = 0;
logic			in_valid;

wire 	[#IO_B#-1:0]	out_data;
wire 			out_valid;


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


logic [#IO_B#-1:0] signal [#SIG_LEN#];
initial begin
`include "signal.h"
end


always @ (posedge clk) begin	
	in_valid	<= 0;
	counter++;
	if(counter == SAMPL_CNTR) begin
		in_valid	<= 1;
		in_data		<= signal[idx++];
		counter = 0;
		if(idx == $size(signal))
			$stop();
	end
end


filter filter_inst ( .* );


endmodule
