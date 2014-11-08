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


module a_ctrls_decode (
	//------------ Clk and reset ----------------
	input 				clk,
	input 				reset_n,
	//------------ Data from UART ---------------
	input [7:0] 		data_in,
	input				data_valid,
	//------------ Decoded values ---------------
	output logic [7:0] 	values [0:6]
);

//===================================================================
// ASCII to hex
wire [7:0] ascii = data_in;
logic [3:0] hex;

reg [3:0] ascii_lut [0:255];
initial begin
	ascii_lut[48]  = 4'h0;
	ascii_lut[49]  = 4'h1;
	ascii_lut[50]  = 4'h2;
	ascii_lut[51]  = 4'h3;
	ascii_lut[52]  = 4'h4;
	ascii_lut[53]  = 4'h5;
	ascii_lut[54]  = 4'h6;
	ascii_lut[55]  = 4'h7;
	ascii_lut[56]  = 4'h8;
	ascii_lut[57]  = 4'h9;
	ascii_lut[65]  = 4'hA;
	ascii_lut[66]  = 4'hB;
	ascii_lut[67]  = 4'hC;
	ascii_lut[68]  = 4'hD;
	ascii_lut[69]  = 4'hE;
	ascii_lut[70]  = 4'hF;
	ascii_lut[97]  = 4'ha;
	ascii_lut[98]  = 4'hb;
	ascii_lut[99]  = 4'hc;
	ascii_lut[100] = 4'hd;
	ascii_lut[101] = 4'he;
	ascii_lut[102] = 4'hf;
end
 
always_ff @ (posedge clk) begin
	hex	<= ascii_lut[ascii]; 
end

//===================================================================
// State machine

typedef enum {
	idle,
	M, E, A, S,
	dots, valHi, valSave
	} state_t;

state_t state;

logic [2:0] byte_cntr;

logic [3:0] value_tmp;

always_ff @ (posedge clk) begin
	if( data_valid ) begin
		case( state )
		//=================================================
		idle: begin
			if ( data_in == "M" )
				state	<= M;
		end		
		//=================================================
		M: begin
			if ( data_in == "E" )
				state	<= E;
		end		
		//=================================================
		E: begin
			if ( data_in == "A" )
				state	<= A;
		end		
		//=================================================
		A: begin
			if ( data_in == "S" )
				state	<= S;
		end				
		//=================================================
		S: begin
			//if ( data_in == "S" )
			state		<= dots;
			byte_cntr	<= 0;
		end		
		//=================================================
		dots: begin
			if(byte_cntr == 7) 	state	<= idle;
			else				state	<= valHi;
			$display("valHi: %c", data_in);
			//ascii		<= data_in;
		end
		//=================================================
		valHi: begin
			$display("valLo: %c", data_in);
			state		<= valSave;
			//ascii		<= data_in;
			value_tmp	<= hex;
		end
		//=================================================
		valSave: begin
			state		<= dots;
			byte_cntr	<= byte_cntr + 1;
			values[byte_cntr]	<= {value_tmp, hex};
		end
		//=================================================
		default:
			state	<= idle;
		endcase
	end
end



endmodule
