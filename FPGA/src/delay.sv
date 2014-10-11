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
	parameter SIG_BITS	= 24,
	parameter BLEND_B	= 8,	
	parameter DLY_B		= 19,
	parameter FDB_B		= 8,
	parameter fCLK		= 50_000_000,
	parameter fSAMP		= 48_000,
	parameter ADDR_W	= 19
)(
	//------------ Clk and reset ------------
	input 						clk,
	input						reset_n,
	//------------ Input --------------------
	input		[SIG_BITS-1:0]	in,
	//------------ Output -------------------
	output  	[SIG_BITS-1:0]	out,
	output 	reg					valid,
	//------------ Control ------------------
	input		[BLEND_B-1:0]	blend,
	input		[DLY_B-1:0]		delay,
	input		[FDB_B-1:0]		feedbk,
	//------------ Memory -------------------
	output						mem_write,
	output	[31:0]				mem_writedata,
	output	[ADDR_W-1:0]		mem_writeaddr,
	output 						mem_read,
	input 	[31:0] 				mem_readdata,
	output	[ADDR_W-1:0]		mem_readaddr,
	input 						mem_readdone
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

logic	[FDB_B-1:0]	fbk_p1;

always_ff @ (posedge clk) begin
	if( feedbk == '1)
		fbk_p1	<= '1;
	else
		fbk_p1	<= feedbk; // + 1;
end


mixer #(
	.D_WIDTH 	( SIG_BITS ),
	.M_WIDTH 	( FDB_B  )
) mixer_feedbk (
	.a		( out	 	),
	.b		( in 		),
	.mix	( fbk_p1 	) ,
	.out	( wr_data	)
);


//=============================================================================
// 
wire [SIG_BITS-1:0] rd_data;

assign	mem_write		= smp_en;
assign	mem_read		= smp_en;
assign	mem_writedata	= { {(SIG_BITS-8){1'b0}}, wr_data};
assign	mem_writeaddr	= wr_addr;
assign	mem_readaddr	= rd_addr;
assign	rd_data			= mem_readdata[SIG_BITS-1:0];

always_ff @ (posedge clk)
	valid <= mem_readdone;


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



