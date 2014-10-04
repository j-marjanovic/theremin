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

//`define uart_tx_debug

module uart_tx_nonsynth #(
	parameter BAUD_RATE	= 9600
)(
	output logic TX
);

initial TX = 1'b1;

localparam tBD = 1000ms / BAUD_RATE;

//=========================================================
task send( input bit [7:0] data);
`ifdef uart_tx_debug
	$display("%t TX data:", $time(), data);
`endif
	// Start bit
	TX	<= 0;
	#tBD;

	// Data
	for(int i = 0; i < 8; i++) begin
		TX		<= data[0];
		data 	<= {1'bX, data[7:1]};
		#tBD;
	end	

	// Stop bit
	TX	<= 1;
	#tBD;
endtask

//=========================================================
bit [7:0] q[$];

initial begin
	forever begin
		wait(q.size() > 0) begin
			bit [7:0] data;
			data = q.pop_front();
			send(data);
			#10ns;
		end
	end
end


//=========================================================
function void send_data(input bit [7:0] data);
	q.push_back(data);
endfunction


//=========================================================
function void send_string(string str);
	for (int i = 0; i < str.len(); i++) begin
		send_data(str[i]);
	end
endfunction



endmodule
