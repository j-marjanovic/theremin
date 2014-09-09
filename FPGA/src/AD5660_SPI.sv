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


module AD5660_SPI # (
	parameter BITS	= 16,
	parameter fCLK	= 50_000_000,
	parameter fSCLK	= 10_000_000
)(
	//------------ Clk and reset ------------
	input 					clk,
	input					reset_n,
	//------------ Input --------------------
	input		[BITS-1:0]	in,
	input					go,
	//------------ Output -------------------
	output logic			SS_n,
	output logic			SCLK,	
	output logic			SDO
);


typedef enum {	IDLE,
				WAIT,
				TX,
				DONE } state_t;

state_t state;

localparam CNTR_MAX  = fCLK / fSCLK - 1;
localparam CNTR_BITS = $clog2(CNTR_MAX-1)+1;

logic [CNTR_BITS-1:0] 		cntr;
logic [$clog2(BITS-1)-1:0] 	bits_cntr;
logic [BITS-1:0]			data_tmp;

function put_bit;
	data_tmp	<= {data_tmp[BITS-2:0],1'b0};
	SDO			<= data_tmp[BITS-1];
endfunction

always_ff @ (posedge clk, negedge reset_n) begin
	if( !reset_n ) begin
		state	<= IDLE;	
		SS_n	<= 1;
		SCLK	<= 1;
		SDO		<= 0;
		cntr	<= 0;
		data_tmp<= 0;
	end else begin
		case( state )
			//=================================================================
			IDLE: begin
				if( go ) begin
					state		<= WAIT;
					SS_n		<= 0;
					bits_cntr	<= 0;
					data_tmp	<= in;
				end 
			end
			//=================================================================
			WAIT: begin
				state	<= TX;
				put_bit();
			end
			//=================================================================
			TX: begin
				cntr <= cntr + 1;
				if(cntr == '1) begin
					if(bits_cntr == BITS)
						state	<= DONE;
					else
						bits_cntr <= bits_cntr + 1;

					SCLK	<= 1;
					put_bit();
				end else if ( cntr[CNTR_BITS-2:0] == '1 ) begin
					SCLK	<= 0;
					
				end
			end
			//=================================================================
			DONE: begin
				SS_n	<= 1;
				state	<= IDLE;
			end
		endcase
	end
end


endmodule

