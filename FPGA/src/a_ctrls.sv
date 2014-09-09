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


module a_ctrls # (
	BITS	= 8
)(
	//------------ Clk and reset ------------
	input 					clk,
	input					reset_n,
	//------------ Input --------------------
	input					CTRL_SCLK,
	input					CTRL_MOSI,
	input					CTRL_SS_n,
	//------------ Tone Control -------------
	output logic [BITS-1:0]	a16,
	output logic [BITS-1:0]	a8,
	output logic [BITS-1:0]	a5,
	output logic [BITS-1:0]	a4,
	//------------ Delay Control ------------
	output logic [BITS-1:0]	blend,
	output logic [BITS-1:0]	delay,
	output logic [BITS-1:0]	feedbk,
	//------------ Gain Control -------------
	output logic [BITS-1:0]	gain	
);


endmodule
