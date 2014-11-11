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
//
// Output of this module is 0     for input < IN_OFFSET.
//                          all 1 for input > IN_OFFSET + 2**LUT_B
//
// Between this two a natural log is calculated
//
// 3101 -> 0
// 3102 -> 455
// 3103 -> 721
//
///////////////////////////////////////////////////////////////////////////////

module antilog #(
	parameter IN_B		= 16,
	parameter OUT_B		= 12,
	parameter LUT_B		= 9,
	//parameter IN_OFFSET = 3100,
	parameter OUT_OFFS	= 2900
) (
	//---------- Clock and reset-----------
	input				clk,
	input 				reset_n,
	//---------- Control ------------------
	input	[IN_B-1:0]	in_offset,
	//---------- Input --------------------
	input	[IN_B-1:0]	in_data,
	input				in_valid,
	//---------- Output -------------------
	output logic	[OUT_B-1:0]	out_data,
	output logic		 		out_valid
);

//parameter IN_MAX = IN_OFFSET + 2**LUT_B - 1;
logic	[IN_B-1:0]	in_max;
always_ff @ (posedge clk) begin
	in_max	<= in_offset + (2**LUT_B - 1);
end

///////////////////////////////////////////////////////////////////////////////
// LUT
logic 	[LUT_B-1:0]		addr;
wire	[OUT_B-1:0]	q;

antilog_lut # (.DATA_WIDTH(OUT_B), .ADDR_WIDTH(LUT_B)) antilog_lut_inst ( .* );


///////////////////////////////////////////////////////////////////////////////
// State machine
logic [IN_B-1:0] acc;

logic in_lss_offset;
logic in_grt_max;

logic out_less_offset;
logic	[OUT_B-1:0]	out_subtr;

enum { IDLE, CHECK, SUBTR, LOOKUP, OUT_CHECK} state;

always_ff @ (posedge clk or negedge reset_n) begin
	if( !reset_n ) begin
		state	<= IDLE;
	end else begin
		
		out_valid	<= 0;
	
		case(state)
		//-------------------------------------------------
		IDLE: begin
			if(in_valid) begin
				in_lss_offset	<= in_data < in_offset;
				in_grt_max		<= in_data > in_max;
				state			<= CHECK;
			end
		end
		//-------------------------------------------------
		CHECK: begin
			if( in_lss_offset ) begin
				state		<= IDLE;
				out_valid	<= 1;
				out_data	<= 0;			
			end
			else if ( in_grt_max ) begin
				state		<= IDLE;
				out_valid	<= 1;
				out_data	<= '1;			
			end
			else begin
				state	<= SUBTR;
				acc		<= in_data - in_offset;
			end
		end
		//-------------------------------------------------
		SUBTR: begin
			state		<= OUT_CHECK;
			addr		<= acc[LUT_B-1:0];
		end
		//-------------------------------------------------
		OUT_CHECK: begin
			out_less_offset	<= q < OUT_OFFS;
			out_subtr		<= q - OUT_OFFS;
			state			<= LOOKUP;
		end
		//-------------------------------------------------
		LOOKUP: begin
			state		<= IDLE;
			out_valid	<= 1;
			out_data	<= out_less_offset ? 0 : out_subtr;
		end
		//-------------------------------------------------
		endcase
	end
end

endmodule



///////////////////////////////////////////////////////////////////////////////
module antilog_lut
#(parameter DATA_WIDTH=12, parameter ADDR_WIDTH=9)
(
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

	initial
	begin
		$readmemh("antilog_lut_init.txt", rom);
	end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule

