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

module osc # (
	parameter COUNT_MAX = 32'd10_000)
	(
	input 					clk_100,
	input 					reset_n,
	
	output 					ant_out
);
/*
reg [31:0] counter;
reg	[3:0] leds_reg;
assign led = ~leds_reg;

reg ant_out_reg;
assign ant_out = ant_out_reg; 

always @ (posedge clk_100 or negedge reset_n) begin
	if( ~reset_n ) begin
		counter		<= 0;
		leds_reg		<= 0;
		ant_out_reg	<= 0;
	end else begin
		counter		<=	counter + 1;
		
		if( counter == 32'd10_000 ) begin
			counter		<= 0;
			ant_out_reg	<= ~ ant_out_reg;
			leds_reg		<= leds_reg + 1;
		end
	end
end	
*/
endmodule
