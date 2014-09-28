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

module a_ctrls_tb;

localparam Tclk = 20;

//=============================================================================
// Clock
logic clk = 0;
always #(Tclk/2) clk <= !clk;

//=============================================================================
// Reset
logic reset_n=1;
initial begin
	reset_n <= 1;
	#(10*Tclk);
	reset_n <= 0;
	#(10*Tclk);
	reset_n <= 1;
end

//=============================================================================
// Module
localparam BITS = 8;
wire CTRL_RX;
wire [7:0] a8, a5, a4, blend, delay, feedbk, gain;

a_ctrls #( 
	.fCLK	( 50_000_000	),
	.fBAUD	( 9_600		),
	.BITS	( BITS		) 
) a_ctrls_inst ( .* );


uart_tx_nonsynth uart_tx(
	.TX	( CTRL_RX )
);


//=============================================================================
// Test procedure

initial begin
	$display("========================================");
	$display("=    a_ctrls module test procedure     =");
	$display("========================================");

	wait(reset_n == 0);
	$display("%t: Going into reset", $time());

	wait(reset_n == 1);
	$display("%t: Going out of reset", $time());

	#(10*Tclk);
	
	uart_tx.send_string("MEAS:4a:36:32:45:81:d1:ea:\r\n");
	uart_tx.send_string("MEAS:6b:4c:37:35:4a:8f:d8:\r\n");
	uart_tx.send_string("lets test some error handling");
	uart_tx.send_string("MEAS:b4:91:5f:40:2c:26:3a:\r\n");
	uart_tx.send_string("MEAS:b1:b4:8a:58:31:19:17:\r\n");

end

endmodule
