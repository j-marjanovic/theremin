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

//`define DAC_debug
`define delay_disable
`define tone_gen_debug

module theremin (
	input 		CLK_50,
	input 		EXT_RESET_n,
	
	//---------- Antenna -----------
	output		ANT_OUT,
	input		ANT_IN,
	
	//---------- Controls ----------
	input		CTRL_RX,	// HDR2_2 on proto1 board
	
	//---------- DAC ---------------
	output		DAC_SYNC_n,
	output		DAC_DATAI,
	output		DAC_SCLK
);

wire clk_100;
wire clk_50 = CLK_50;
wire reset_n = EXT_RESET_n;

localparam TC_BITS = 16; 		// output from time constant
(* keep = 1 *) wire [TC_BITS-1:0] 	tc_data;
wire				tc_valid;

localparam	A_BITS 	= 3; 		// Hammond registers
localparam	TONE_BITS = 16;
wire [TC_BITS-1:0] freq;
(* keep = 1 *) wire [A_BITS-1:0]	a16;
(* keep = 1 *) wire [A_BITS-1:0]	a8;
(* keep = 1 *) wire [A_BITS-1:0]	a5;
(* keep = 1 *) wire [A_BITS-1:0]	a4;
(* keep = 1 *) wire [TONE_BITS+1:0] tone_out;

parameter SIG_BITS	= 16;
parameter BLEND_B	= 4;	
parameter DLY_B		= 14;
parameter FDB_B		= 10;
`ifndef delay_disable
wire [SIG_BITS-1:0]	delay_out;
wire delay_valid;
`endif
(* keep = 1 *) logic [BLEND_B-1:0]	blend;		// Delay controls
(* keep = 1 *) logic [DLY_B-1:0]	delay;
(* keep = 1 *) logic [FDB_B-1:0]	feedbk;

wire [7:0] actrls_a16;
wire [7:0] actrls_a8;
wire [7:0] actrls_a5;
wire [7:0] actrls_a4;
wire [7:0] actrls_blend;
wire [7:0] actrls_delay;
wire [7:0] actrls_feedbk;
wire [7:0] actrls_gain;

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
// Tc to Freq converter
f_compressor  #   (
	.F_IN_1			( 1200 			),
	.F_OUT_1		( 10 			),
	
	.F_IN_2			( 2000 			),
	.F_OUT_2 		( 100  			),
	
	.F_IN_3			( 2500 			),
	.F_OUT_3		( 1250 			)
)f_compressor_inst (
	//------------ Clock and reset -----------------
	.clk			( clk_50 		),
	.reset_n		( reset_n 		),
	//------------ Input data ----------------------
	.in				( tc_data[15:2] ),
	.go				( 1 			),
	//------------ Output data ---------------------
	.out			( freq 			),
	.done			(  				)
);

//=========================================================
// Tone generator
tone_gen # (
	.F_BITS		( TC_BITS 	),
	.A_BITS		( A_BITS 	),
	.SIG_BITS	( TONE_BITS	)
) tone_gen_inst (
	//------------ Clk and reset ------------
	.clk		( clk_50 	),
	.reset_n,
	//------------ Input --------------------
`ifdef tone_gen_debug
	.freq		( 100 		),
`else
	.freq		( freq 		),
`endif
	//------------ Tone Control -------------
`ifdef tone_gen_debug
	.a16			( 13 		),
	.a5				( 5		),
`else
	.a16,
	.a5,
`endif
	.a8,
	//------------ Output control ------------------
	.out		( tone_out 	)
);

//=========================================================
// Delay
`ifdef delay_disable

logic [SIG_BITS-1:0]	delay_out;
logic 					delay_valid;
logic [16:0] 			sampling_prescaler;

always_ff @ (posedge clk_50) begin
	delay_valid		<= 0;
	
	sampling_prescaler	<= sampling_prescaler + 1;
	
	if(sampling_prescaler	== 50_000_000/48_000) begin
		delay_out			<= tone_out[SIG_BITS+1:2];
		sampling_prescaler	<= 0;
		delay_valid			<= 1;
	end
end
`else

delay #( 
	.SIG_BITS	( SIG_BITS 	),
	.BLEND_B	( BLEND_B	),
	.DLY_B		( DLY_B		),
	.FDB_B		( FDB_B		)
) delay_inst ( 	
	.clk	( clk_50		),
	.reset_n,
	.in		( tone_out		),
	.valid	( delay_valid	),
	.out	( delay_out		),
	.blend,
	.delay,
	.feedbk,
);

`endif

//=========================================================
// Output
`ifdef DAC_debug
logic [15:0]	DAC_dbg_out;
logic	 		DAC_dbg_valid;

logic [31:0] prescaler = 0;

always @(posedge clk_50) begin
	DAC_dbg_valid <= 0;
	if(prescaler < 32'd5_000) begin
		prescaler		<= prescaler + 1;
	end
	else begin
		prescaler		<= 0;
		DAC_dbg_out		<= DAC_dbg_out + 1;
		DAC_dbg_valid	<= 1;
	end
end

`endif

AD5660_SPI # (
	.BITS	( 24			),
	.fCLK	( 50_000_000	),
	.fSCLK	( 10_000_000	)
) AD5660_SPI_inst(
	.clk	( clk_50 ),
	.reset_n,
	//------------ Input --------------------
`ifdef DAC_debug
	.in		( {2'd0, DAC_dbg_out, 6'd0} ),
	.go		( DAC_dbg_valid	),
`else
	.in		( {2'd0, delay_out, 6'd0} 	),
	.go		( delay_valid				),
`endif
	//------------ Output -------------------
	.SS_n	( DAC_SYNC_n				),
	.SCLK	( DAC_SCLK					),	
	.SDO	( DAC_DATAI					)
);

	
//=========================================================
// Analog controls
a_ctrls # (
	.BITS(8)
) a_ctrls_inst(
	//------------ Clk and reset ------------
	.clk		( clk_50	),
	.reset_n,
	//------------ Input --------------------
	.CTRL_RX,
	//------------ Tone Control -------------
	.a8			( actrls_a8 	),
	.a5			( actrls_a5 	),
	.a4			( actrls_a4 	),
	//------------ Delay Control ------------
	.blend		( actrls_blend 	),
	.delay		( actrls_delay 	),
	.feedbk		( actrls_feedbk ),
	//------------ Gain Control -------------
	.gain		( actrls_gain 	)
);


endmodule