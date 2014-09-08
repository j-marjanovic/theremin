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



module theremin (
	input 		CLK_50,
	input 		EXT_RESET_n,
	
	//---------- Antenna -----------
	output		ANT_OUT,
	input		ANT_IN,
	
	//---------- Controls ----------
	input		CTRL_SCLK,
	input		CTRL_MOSI,
	input		CTRL_SS_n,
	
	//---------- DAC ---------------
	output		DAC_SYNC,
	output		DAC_DATAI,
	output		DAC_SCLK
);

wire clk_100;
wire clk_50 = CLK_50;
wire reset_n = EXT_RESET_n;

localparam TC_BITS = 12; 		// output from time constant
wire [TC_BITS-1:0] 	tc_data;
wire				tc_valid;

localparam	A_BITS 	= 3; 		// Hammond registers
localparam	TONE_BITS = 16;
wire [A_BITS-1:0]	a16;
wire [A_BITS-1:0]	a8;
wire [A_BITS-1:0]	a5;
wire [A_BITS-1:0]	a4;
wire [TONE_BITS-1:0] tone_out;

parameter SIG_BITS	= 16;
parameter BLEND_B	= 4;	
parameter DLY_B		= 14;
parameter FDB_B		= 10;
wire [SIG_BITS-1:0]	delay_out;
logic [BLEND_B-1:0]	blend;		// Delay controls
logic [DLY_B-1:0]	delay;
logic [FDB_B-1:0]	feedbk;

//=========================================================
// PLL 100 MHz
pll_100	pll_100_inst (
	.inclk0 ( CLK_50 ),
	.c0 	( clk_100 )
);

//=========================================================
// Oscillator
osc # (
	.COUNT_MAX (32'd10_000)
)	osc_inst(
	.clk_100,
	.reset_n,
	.ant_out	( ANT_OUT )
);

//=========================================================
// Time Constant Measurement
tc_meas # (
	.D_BITS( TC_BITS )
)	tc_meas_inst(
	.clk_100,
	.reset_n,
	
	.ant_out	( ANT_OUT ),
	.ant_in		( ANT_IN ),
	
	.out_data	( tc_data ),
	.out_valid	( tc_valid )
);

//=========================================================
// Tone generator
tone_gen # (
	.F_BITS		( TC_BITS ),
	.A_BITS		( A_BITS ),
	.SIG_BITS	( TONE_BITS )
) tone_gen_inst (
	//------------ Clk and reset ------------
	.clk		( clk_50 ),
	.reset_n,
	//------------ Input --------------------
	.freq		( tc_data ),
	//------------ Tone Control -------------
	.a16,
	.a8,
	.a5,
	.a4,
	//------------ Output control ------------------
	.out		( tone_out )
);

//=========================================================
// Delay
delay #( 
	.SIG_BITS	( SIG_BITS 	),
	.BLEND_B	( BLEND_B	),
	.DLY_B		( DLY_B		),
	.FDB_B		( FDB_B		)
) delay_inst ( 	
	.in		( tone_out	),
	.out	( delay_out	),
	.blend,
	.delay,
	.feedbk,
);




endmodule