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

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//       +--------------------------------------------------------+          //
//       |                                                        |          //
//       |                                                        |          //
//       |                                                        |          //
//       +--------------------------------------------------------+          //
//                    A                 A                                    //
//                    |<---- delay ---->|                                    //
//                    |                 |                                    //
//                  rd_addr            wr_addr                               //
//                                                                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

module delay # (
	parameter SIG_BITS	= 16,
	parameter BLEND_B	= 4,	
	parameter DLY_B		= 14,
	parameter FDB_B		= 10,
	parameter fCLK		= 50_000_000,
	parameter fSAMP		= 48_000
)(
	//------------ Clk and reset ------------
	input 						clk,
	input						reset_n,
	//------------ Input --------------------
	input		[SIG_BITS-1:0]	in,
	//------------ Output -------------------
	output logic [SIG_BITS-1:0]	out,
	//------------ Control ------------------
	input		[BLEND_B-1:0]	blend,
	input		[DLY_B-1:0]		delay,
	input		[FDB_B-1:0]		feedbk	
);


//=============================================================================
// Sampling clock generator

logic smp_en;
localparam SAMPLE_CNTR_MAX = fCLK/fSAMP - 1;
logic [$clog2(SAMPLE_CNTR_MAX):0] sample_cntr;

always_ff @ (posedge clk, negedge reset_n) begin
	if( !reset_n ) begin
		sample_cntr	<= 0;
		smp_en		<= 0;	
	end else begin
		smp_en		<= 0;
		if(sample_cntr == SAMPLE_CNTR_MAX) begin
			sample_cntr	<= 0;
			smp_en		<= 1;
		end else begin 
			sample_cntr	<= sample_cntr + 1;
		end
	end
end

//=============================================================================
// Read and write address

logic [DLY_B-1:0]	rd_addr;
logic [DLY_B-1:0]	wr_addr;
logic [DLY_B-1:0]	rd_addr_plus_delay;

always_ff @ (posedge clk, negedge reset_n) begin
	if( !reset_n ) begin
		rd_addr	<= 0;
		wr_addr	<= 0;
	end else begin
		rd_addr_plus_delay	<= rd_addr + delay;

		if( smp_en ) begin
			if(	rd_addr_plus_delay == wr_addr ) begin
				rd_addr	<= rd_addr + 1;
				wr_addr <= wr_addr + 1;
			end else if ( rd_addr_plus_delay > wr_addr ) begin
				wr_addr <= wr_addr + 1;
			end else begin
				rd_addr	<= rd_addr + 1;
			end
		end
	end
end


//=============================================================================
// Feedback mixer

wire [SIG_BITS-1:0] wr_data;

mixer #(
	.D_WIDTH 	( SIG_BITS ),
	.M_WIDTH 	( FDB_B  )
) mixer_feedbk (
	.a		( out	 	),
	.b		( in 		),
	.mix	( feedbk 	) ,
	.out	( wr_data	)
);


//=============================================================================
// 
wire [SIG_BITS-1:0] rd_data;

delay_mem	delay_mem_inst (
	.clock		( clk ),
	.data 		( wr_data ),
	.rdaddress 	( rd_addr ),
	.wraddress 	( wr_addr ),
	.wren 		( smp_en ),
	.q 			( rd_data )
);



//=============================================================================
// Blend mixer

mixer #(
	.D_WIDTH 	( SIG_BITS ),
	.M_WIDTH 	( BLEND_B  )
) mixer_blend (
	.a		( rd_data 	),
	.b		( in 		),
	.mix	( blend 	) ,
	.out	( out 		)
);


endmodule



