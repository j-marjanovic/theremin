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

module tc_meas # (
	parameter D_BITS = 12)
	(
	input 					clk_100,
	input 					reset_n,
	
	input 					ant_out,
	input 					ant_in,
	
	output reg [D_BITS-1:0] out_data,
	output reg 				out_valid
);


reg [11:0] 	time_const_cntr;
reg 			time_const_count;
reg ant_out_reg_prev;
reg ant_in_prev1;
reg ant_in_prev2;
reg ant_in_prev3;

reg [8:0] bounce_counter;

always @ (posedge clk_100 or negedge reset_n) begin
	if( ~reset_n ) begin
		time_const_cntr	<= 0;
	end else begin
		ant_out_reg_prev	<=	ant_out;
		ant_in_prev1		<= ant_in;
		ant_in_prev2		<= ant_in_prev1;
		ant_in_prev3		<= ant_in_prev2;
		
		out_valid				<= 0;
		
		if( ant_out_reg_prev == 0 && ant_out ) 
			time_const_count	<= 1;
			
		if ( time_const_count )
			time_const_cntr	<= time_const_cntr + '1;
			
		if( bounce_counter > 0) 
			bounce_counter = bounce_counter - '1;
			
		if( ant_in_prev3 == 0 && ant_in_prev2 && time_const_count && bounce_counter == 0 ) begin
			time_const_count		<= 0;
			time_const_cntr		<= 0;
			out_valid					<= 1;
			out_data	<= time_const_cntr;
			bounce_counter			<= 300;
		end
				
	end
	
end	
endmodule
