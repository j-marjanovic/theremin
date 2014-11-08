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
	input		[A_BITS-1:0]	a2_23,
	input		[A_BITS-1:0]	a2,
	//------------ Output control -----------
	output logic[SIG_BITS+2:0]	out
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
logic [F_BITS-1:0]	freq_x_5;
logic [F_BITS-1:0]	freq_x_6;

logic [31:0] phase_acc [0:5];

//wire [8:0] out_selector = phase_acc[22:14];

always @ ( posedge clk or negedge reset_n ) begin
	if ( ~ reset_n ) begin
		phase_acc	<= '{0,0,0,0,0,0};
	end else begin
		freq_x_3		<= freq_x_2  + freq;
		freq_x_5		<= freq_x_3  + freq_x_2;
		freq_x_6		<= freq_x_4  + freq_x_2;
		phase_acc[0]	<= phase_acc[0] + freq;
		phase_acc[1]	<= phase_acc[1] + freq_x_2;
		phase_acc[2]	<= phase_acc[2] + freq_x_3;
		phase_acc[3]	<= phase_acc[3] + freq_x_4;
		phase_acc[4]	<= phase_acc[4] + freq_x_5;
		phase_acc[5]	<= phase_acc[5] + freq_x_6;
	end
end


//=============================================================================
// Output sel

logic [SIG_BITS-1:0] sin_signal [0:5];
logic [SIG_BITS-1:0] q;
logic [2:0] selector, selector_p;

always @ (posedge clk) begin
	
	if(selector == 5) 	selector <= 0;
	else				selector <= selector + 1;
	
	selector_p	<= selector;
	q			<= LUT_sin[ phase_acc[selector][22:14]  ];
	sin_signal[selector_p]	<= q;	
end	
	
	
//=============================================================================
// Output mixer

wire [SIG_BITS-1:0] sin_w_amp [0:5];
	
mixer #(
	.D_WIDTH 	( SIG_BITS 	),
	.M_WIDTH 	( A_BITS  	)
) mixer_out_0 (
	.a		( sin_signal[0] ),
	.b		( '0 			),
	.mix	( a16 			) ,
	.out	( sin_w_amp[0]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS 	),
	.M_WIDTH 	( A_BITS  	)
) mixer_out_1 (
	.a		( sin_signal[1] ),
	.b		( '0 			),
	.mix	( a8			) ,
	.out	( sin_w_amp[1]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS 	),
	.M_WIDTH 	( A_BITS  	)
) mixer_out_2 (
	.a		( sin_signal[2] ),
	.b		( '0 			),
	.mix	( a5 			) ,
	.out	( sin_w_amp[2]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS 	),
	.M_WIDTH 	( A_BITS  	)
) mixer_out_3 (
	.a		( sin_signal[3] ),
	.b		( '0 			),
	.mix	( a4 			) ,
	.out	( sin_w_amp[3]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS 	),
	.M_WIDTH 	( A_BITS  	)
) mixer_out_4 (
	.a		( sin_signal[4] ),
	.b		( '0 			),
	.mix	( a2_23			) ,
	.out	( sin_w_amp[4]  )
);

mixer #(
	.D_WIDTH 	( SIG_BITS 	),
	.M_WIDTH 	( A_BITS  	)
) mixer_out_5 (
	.a		( sin_signal[5] ),
	.b		( '0 			),
	.mix	( a2 			) ,
	.out	( sin_w_amp[5]  )
);



//=============================================================================
// Output mixer
logic[SIG_BITS+1:0]	out1, out2;

always_ff @ (posedge clk) begin
	out1	<= sin_w_amp[0] + sin_w_amp[1] + sin_w_amp[2];
	out2	<= sin_w_amp[3] + sin_w_amp[4] + sin_w_amp[5];
	out		<= out1 + out2;
end


endmodule
