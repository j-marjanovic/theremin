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


module tone_gen # (
	parameter F_BITS	= 12,
	parameter A_BITS	= 3,
	parameter SIG_BITS	= 16
)(
	//------------ Clk and reset ------------
	input 						clk,
	input						reset_n,
	//------------ Input --------------------
	input		[F_BITS-1:0]	freq,
	//------------ Tone Control -------------
	input		[A_BITS-1:0]	a16,
	input		[A_BITS-1:0]	a8,
	input		[A_BITS-1:0]	a5,
	input		[A_BITS-1:0]	a4,
	//------------ Output control -----------
	output logic[SIG_BITS+1:0]	out
);

//=============================================================================
// LUT
reg [15:0]	LUT_sin	[0:511];

`include "LUT_sin.sv"


//=============================================================================
// Phase
wire  [F_BITS-1:0]  freq_x_4 = {freq[F_BITS-3:0],2'b00};
logic [F_BITS-1:0]	freq_x_3;
wire  [F_BITS-1:0]  freq_x_2 = {freq[F_BITS-2:0],1'b0};

logic [31:0] phase_acc [0:3];

//wire [8:0] out_selector = phase_acc[22:14];

always @ ( posedge clk or negedge reset_n ) begin
	if ( ~ reset_n ) begin
		phase_acc	<= '{0,0,0,0};
	end else begin
		freq_x_3		<= freq_x_2  + freq;
		phase_acc[0]	<= phase_acc[0] + freq + 1;
		phase_acc[1]	<= phase_acc[1] + freq_x_2 + 1;	
		phase_acc[2]	<= phase_acc[2] + freq_x_3 + 1;
		phase_acc[3]	<= phase_acc[3] + freq_x_4 + 1;	
	end
end


//=============================================================================
// Output sel

logic [SIG_BITS-1:0] sin_signal [0:3];

logic [1:0] selector;
always @ (posedge clk) begin
	selector	<= selector + 2'b01;
	
	sin_signal[selector] <= LUT_sin[ phase_acc[selector][22:14]  ];
end	
	
	
//=============================================================================
// Output mixer

wire [SIG_BITS-1:0] sin_w_amp [0:3];
	
mixer #(
	.D_WIDTH 	( SIG_BITS ),
	.M_WIDTH 	( A_BITS  )
) mixer_out_0 (
	.a		( sin_signal[0] ),
	.b		( '0 			),
	.mix	( a16 			) ,
	.out	( sin_w_amp[0]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS ),
	.M_WIDTH 	( A_BITS  )
) mixer_out_1 (
	.a		( sin_signal[1] ),
	.b		( '0 			),
	.mix	( a8			) ,
	.out	( sin_w_amp[1]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS ),
	.M_WIDTH 	( A_BITS  )
) mixer_out_2 (
	.a		( sin_signal[2] ),
	.b		( '0 			),
	.mix	( a5 			) ,
	.out	( sin_w_amp[2]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS ),
	.M_WIDTH 	( A_BITS  )
) mixer_out_3 (
	.a		( sin_signal[3] ),
	.b		( '0 			),
	.mix	( a4 			) ,
	.out	( sin_w_amp[3]  )
);


//=============================================================================
// Output mixer

always_ff @ (posedge clk) begin
	out	<= sin_w_amp[0] + sin_w_amp[1] + sin_w_amp[2] + sin_w_amp[3];
end


endmodule
