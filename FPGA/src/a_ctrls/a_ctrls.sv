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

`define debug_ON

module a_ctrls # (
	fCLK	= 50_000_000,
	fBAUD	= 9_600,
	BITS	= 8
)(
	//------------ Clk and reset ------------
	input 					clk,
	input					reset_n,
	//------------ Input --------------------
	input					CTRL_RX,
	//------------ Tone Control -------------
	output  [BITS-1:0]	a8,
	output  [BITS-1:0]	a5,
	output  [BITS-1:0]	a4,
	//------------ Delay Control ------------
	output  [BITS-1:0]	blend,
	output  [BITS-1:0]	delay,
	output  [BITS-1:0]	feedbk,
	//------------ Gain Control -------------
	output  [BITS-1:0]	gain	
);


wire 		ce_16;
wire [7:0]	rxd;
wire 		rxd_valid;

//=========================================================
//                  UART CLK GENERATOR
//=========================================================
baud_gen # (
	.fCLK		( fCLK		),
	.fBAUD		( fBAUD		)
) baud_gen_inst (
	.clock		( clk		), 
	.reset		( !reset_n	), 
	.ce_16		( ce_16		)
);

//=========================================================
//                       UART RX
//=========================================================
uart_rx uart_rx_inst
(
	.clock		( clk		), 
	.reset		( !reset_n	),
	.ce_16		( ce_16		), 
	.ser_in		( CTRL_RX	), 
	.rx_data	( rxd		), 
	.new_rx_data( rxd_valid	)
);

`ifdef debug_ON
always @ (posedge clk) begin
	if(rxd_valid)
		$display("%t recv data: %c", $time(), rxd);
end
`endif

//=========================================================
//                       DECODE
//=========================================================

wire [55:0] connect;
assign { blend, gain, a8, a5, a4, delay,feedbk } = connect;

a_ctrls_decode a_ctrls_decode_inst(
	// Clk and reset
	.clk		( clk 		),
	.reset_n	( reset_n	),
	// Data from UART
	.data_in	( rxd		),
	.data_valid	( rxd_valid	),
	// Decoded values
	.values 	( connect	)
);

endmodule
