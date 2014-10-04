//////////////////////////////////////////////////////////////////////////////////////
///                                                                                ///
///                      WW     WW     WW   WW       WW      WW                    ///
///                      WW    WWWW    WWW  WW       WWWW   WWW                    ///
///                      WW   WW  WW   WWWW WW       WW  WWW WW                    ///
///                      WW   WWWWWW   WW WWWW       WW      WW                    ///
///                 WW   WW  WW   WW   WW  WWW       WW      WW                    ///
///                   WWW    WW   WW   WW   WW       WW      WW                    ///
///                                                                                ///
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////
///                                                                                ///
///                             FREQUENCY COMPRESSOR                               ///
///                           Jan Marjanovic, June 2014                            ///
///                                                                                ///
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Frequency compressor compresses input range to output range, so that bigger     //
//  frequency span is available                                                     //
//                                                                                  //
//   A F_OUT_3                                                                      //
//   |--------------------------------------------------------------o               //
//   |                                                  o           |               //
//   | F_OUT_2                               o                      |               //
//   |----------------------------o                                 |               //
//   |                       o    |                                 |               //
//   |                  o         |                                 |               //
//   | F_OUT_1     o              |                                 |               //
//   |---------o                  |                                 |               //
//   |       o |                  |                                 |               //
//   |     o   |                  |                                 |               //
//   |   o     |                  |                                 |               //
//   | o       |                  |                                 |               //
//   +----------------------------------------------------------------->            //
//             |                  |                                 |               //
//           F_IN_1            F_IN_2                             F_IN_3            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

module f_compressor # (
	parameter		F_IN_1	= 2000,		// dy/dx = 0.5
	parameter		F_OUT_1	= 1000,
	
	parameter		F_IN_2	= 6000,		// dy/dx = 0.25
	parameter		F_OUT_2 = 2000,
	
	parameter		F_IN_3	= 16000,	// dy/dx = 0.2
	parameter		F_OUT_3	= 4000

) (
	//------------ Clock and reset -----------------
	input 				clk,
	input				reset_n,
	//------------ Input data ----------------------
	input		[13:0]	in,
	input				go,
	//------------ Output data ---------------------
	output reg	[11:0]	out,
	output reg			done
);


localparam DIFF_ATTEN_0 =  F_IN_1 / F_OUT_1;
localparam DIFF_ATTEN_1 =  (F_IN_2 - F_IN_1) / (F_OUT_2 - F_OUT_1);
localparam DIFF_ATTEN_2 =  (F_IN_3 - F_IN_2) / (F_OUT_3 - F_OUT_2);


//////////////////////////////////////////////////////////////////////////////////////
//                              CALCULATION FSM                                     //
//////////////////////////////////////////////////////////////////////////////////////


reg [13:0] in_sub;
reg [12:0] after_div;

localparam 	S_IDLE	= 0,
			S_SUB_0 = 1,
			S_SUB_1	= 2,
			S_SUB_2	= 3,
			S_DIV	= 4,
			S_ADD	= 5;
			
reg [3:0] state;

reg [1:0] sub_from;		// Saves what we must add after division

always @ (posedge clk or negedge reset_n) begin
	if( ~reset_n ) begin
		state	<= S_IDLE;
		done	<= 0;
	end else begin
	
		done	<= 0;
		
		case ( state ) 
		//=====================================================================
		S_IDLE: begin
			if ( go ) begin			
				//------------------------------------
				if ( in > F_IN_2 ) begin
					state 		<= S_SUB_2;
					sub_from	<= 2;
				end else if ( in > F_IN_1 ) begin
					state 		<= S_SUB_1;
					sub_from	<= 1;
				end else begin
					state 		<= S_SUB_0;
					sub_from	<= 0;
				end
				//------------------------------------
			end
		end
		S_SUB_0: begin
			in_sub	<= in;
			state	<= S_DIV;
		end
		//=====================================================================
		S_SUB_1: begin
			in_sub	<= in - F_IN_1;
			state	<= S_DIV;
		end
		//=====================================================================
		S_SUB_2: begin
			in_sub	<= in - F_IN_2;
			state	<= S_DIV;
		end		
		//=====================================================================
		S_DIV: begin
			case(sub_from)
			0:	after_div <= in_sub / DIFF_ATTEN_0;
			1:	after_div <= in_sub / DIFF_ATTEN_1;
			2:	after_div <= in_sub / DIFF_ATTEN_2;
			endcase
			
			state	<= S_ADD;
		end
		//=====================================================================
		S_ADD: begin
			case(sub_from)
			0:	out <= after_div;
			1:	out <= after_div + F_OUT_1;
			2:	out <= after_div + F_OUT_2;
			endcase
			
			state	<= S_IDLE;		
			done	<= 1;			
		end
		
		endcase
	end
end


endmodule
