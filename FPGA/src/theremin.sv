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
//`define tone_gen_debug

module theremin (
	input 		CLK_50,
	input 		EXT_RESET_n,
	
	//---------- Antenna -----------
	output		ANT_OUT,
	input		ANT_IN,
	input		ANT_IN2,
	
	//---------- Controls ----------
	input			CTRL_RX_1,	// HDR2_1 on proto1 board
	input			CTRL_RX_2,	// HDR2_2 on proto1 board

	//---------- SDRAM -------------
	output			DRAM_CLK,
	output			DRAM_CKE,
	output	[11:0]	DRAM_ADDR,
	output			DRAM_UDQM,
	output			DRAM_LDQM,
	output			DRAM_RASn,
	output			DRAM_CASn,
	output			DRAM_WEn,
	output			DRAM_CSn,
	inout 	[15:0]	DRAM_DATA,
	
	//---------- DAC ---------------
	output		DAC_SYNC_n,
	output		DAC_DATAI,
	output		DAC_SCLK
);

wire clk_100;
wire clk_50 = CLK_50;
wire reset_n = EXT_RESET_n;

localparam TC_BITS = 14; 		// output from time constant
(* keep = 1 *) wire [TC_BITS-1:0] 	tc_data;
wire				tc_valid;

wire [15:0] filt_data;
wire		filt_valid;

wire [11:0] log_data;
wire		log_valid;

localparam	A_BITS 	= 3; 		// Hammond registers
localparam	TONE_BITS = 16;
wire [TC_BITS-1:0] freq;
(* keep = 1 *) wire [TONE_BITS+2:0] tone_out;

parameter SIG_BITS	= 16;
parameter BLEND_B	= 8;	
parameter DLY_B		= 19;
parameter FDB_B		= 8;
`ifndef delay_disable
wire [SIG_BITS-1:0]	delay_out;
wire delay_valid;
`endif

(* keep = 1 *) wire [7:0] actrls_hamm1;	// 16
(* keep = 1 *) wire [7:0] actrls_hamm2;	// 5 1/3
(* keep = 1 *) wire [7:0] actrls_hamm3;	// 8
(* keep = 1 *) wire [7:0] actrls_hamm4;	// 4
(* keep = 1 *) wire [7:0] actrls_hamm5;	// 2 2/3
(* keep = 1 *) wire [7:0] actrls_hamm6;	// 2
(* keep = 1 *) wire [7:0] actrls_volume;	



wire 		mem_write;
wire [31:0]	mem_writedata;
wire [18:0] mem_writeaddr;
wire 		mem_read;
wire [31:0]	mem_readdata;
wire [18:0]	mem_readaddr;
wire 		mem_readdone;

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
	.clk		( clk_100 ),
	.reset_n,
	
	.ant_out	( ANT_OUT ),
	.ant_in		( ANT_IN  ),
	
	.out_data	( tc_data ),
	.out_valid	( tc_valid )
);

//=========================================================
// Filter
wire		fifo_empty;
wire 		fifo_valid;
wire [13:0] fifo_data;

assign fifo_valid = !fifo_empty;

clk_xing_fifo	clk_xing_fifo_inst (
	.data ( tc_data ),
	.rdclk ( clk_50 ),
	.rdreq ( 1'b1 ),
	.wrclk ( clk_100 ),
	.wrreq ( tc_valid ),
	.q ( fifo_data ),
	.rdempty ( fifo_empty )
);
filter_avg filter_avg_inst (
	//---------- Clock and reset-----------
	.clk		( clk_50			),
	.reset_n,
	//---------- Input --------------------
	.in_data	( {2'd0, fifo_data}	),
	.in_valid	( fifo_valid		),
	//---------- Output -------------------
	.out_data	( filt_data			),
	.out_valid	( filt_valid		)
);

//=========================================================
// Tc to Freq converter
// With current configuration, this is putting out 0 - ~1000
antilog  #(
	.IN_B		( 16		),
	.OUT_B		( 12		),
	.LUT_B		( 9			),
	.IN_OFFSET	( 2420		), // <- sensitivity (2400 -> wobl wobl, 2420 -> ok)
	.OUT_OFFS	( 2900		)
) antilog_inst ( 
	.clk		( clk_50		),
	.reset_n,
	.in_data	( filt_data 	),
	.in_valid	( filt_valid 	),
	.out_data	( log_data		),
	.out_valid	( log_valid		)
);

//=========================================================
// Tone generator
tone_gen # (
	.F_BITS		( TC_BITS 	),
	.A_BITS		( A_BITS 	),
	.SIG_BITS	( TONE_BITS	)
) tone_gen_inst (
	//------------ Clk and reset ------------
	.clk		( clk_50 			),
	.reset_n,
	//------------ Input --------------------
	.freq		( {2'd0, log_data[11:2]} ), //<- freq range ([11:2] = normal, [11:6] = bass)
	//------------ Tone Control -------------
	.a16		( actrls_hamm1[7:5]	),
	.a8			( actrls_hamm3[7:5]	),
	.a5			( actrls_hamm2[7:5]	),
	.a4			( actrls_hamm4[7:5]	),
	.a2_23		( actrls_hamm5[7:5]	),
	.a2			( actrls_hamm6[7:5]	),
	//------------ Output control ------------------
	.out		( tone_out 			)
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
		delay_out			<= tone_out[SIG_BITS+2:3];
		sampling_prescaler	<= 0;
		delay_valid			<= 1;
	end
end
`else

delay #( 
	.SIG_BITS		( SIG_BITS 		),
	.BLEND_B		( BLEND_B		),
	.DLY_B			( DLY_B			),
	.FDB_B			( FDB_B			),
	.fSAMP			( 192_000		),
	.ADDR_W			( 19			)
) delay_inst ( 	
	.clk			( clk_50		),
	.reset_n,
	.in				( tone_out[SIG_BITS+2:3]		),
	.valid			( delay_valid	),
	.out			( delay_out		),
	.blend			( actrls_a8 	),
	.delay			( {2'd0, actrls_a5, 8'd0, 1'd0} 	),
	.feedbk			( actrls_a4		),
/*
	.blend			( actrls_blend 	),
	.delay			( actrls_delay 	),
	.feedbk			( actrls_feedbk ),*/
	.mem_write      ( mem_write		),
	.mem_writedata  ( mem_writedata	),
	.mem_writeaddr  ( mem_writeaddr	),
	.mem_read       ( mem_read		),
	.mem_readdata   ( mem_readdata	),
	.mem_readaddr   ( mem_readaddr	),
	.mem_readdone   ( mem_readdone	)
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
a_ctrls a_ctrls_0(
	//------------ Clk and reset ------------
	.clk		( clk_50			),
	.reset_n,
	//------------ Input --------------------
	.CTRL_RX	( CTRL_RX_1			),
	//------------ Output Control -----------
	.out		(	)
);

a_ctrls a_ctrls_1(
	//------------ Clk and reset ------------
	.clk		( clk_50			),
	.reset_n,
	//------------ Input --------------------
	.CTRL_RX	( CTRL_RX_2			),
	//------------ Output Control -----------
	.out		('{	actrls_hamm1,
					actrls_hamm2,
					actrls_hamm3,
					actrls_hamm4,
					actrls_hamm5,
					actrls_hamm6,
					actrls_volume}	)
);


//=========================================================
// Memory controller
/*
mem_controller mem_controller_inst (
	.clk_clk        ( clk_50			),		//      clk.clk
	.clk_100_clk	( clk_100			),		//  clk_100.clk
	.reset_reset_n  ( reset_n			),		//    reset.reset_n
	.mem_wire_addr  ( DRAM_ADDR[10:0]	),		// mem_wire.addr
	.mem_wire_ba    ( DRAM_ADDR[11]		),		//         .ba
	.mem_wire_cas_n ( DRAM_CASn			),		//         .cas_n
	.mem_wire_cke   ( DRAM_CKE			),		//         .cke
	.mem_wire_cs_n  ( DRAM_CSn 			),		//         .cs_n
	.mem_wire_dq    ( DRAM_DATA 		),		//         .dq
	.mem_wire_dqm   ( {	DRAM_UDQM, 
						DRAM_LDQM }		),		//         .dqm
	.mem_wire_ras_n ( DRAM_RASn 		),		//         .ras_n
	.mem_wire_we_n  ( DRAM_WEn			),		//         .we_n
	.mem_clk_clk    ( DRAM_CLK 			),		//  mem_clk.clk
	.s2a_write      ( mem_write			),		//      s2a.write
	.s2a_writedata  ( mem_writedata		),		//         .writedata
	.s2a_writeaddr  ( mem_writeaddr		),		//         .writeaddr
	.s2a_read       ( mem_read			),		//         .read
	.s2a_readdata   ( mem_readdata		),		//         .readdata
	.s2a_readaddr   ( mem_readaddr		),		//         .readaddr
	.s2a_readdone   ( mem_readdone		)		//         .readdone
);
*/

endmodule