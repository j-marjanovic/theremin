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


module simple_2_avalon  #(
	parameter ADDR_W = 19
) (
	//---------- Clk and reset ----------------
	input					clk,
	input					reset_n,
	//---------- Avalon MM master -------------
	output [ADDR_W-1:0] 	avm_master_address,
	output	logic			avm_master_read,
	input			[31:0]	avm_master_readdata,
	output	logic			avm_master_write,
	output	logic	[31:0]	avm_master_writedata,
	input					avm_master_readdatavalid,
	input					avm_master_waitrequest,
	//----------- Conduit ---------------------
	input					coe_simple_write,
	input	[31:0]			coe_simple_writedata,
	input	[ADDR_W-3:0] 	coe_simple_writeaddr,
	input					coe_simple_read,
	output logic	[31:0]	coe_simple_readdata,
	input	[ADDR_W-3:0]	coe_simple_readaddr,
	output logic			coe_simple_readdone
);

logic [31:0] 	wr_buffer;
logic			wr_do, rd_do;
always_ff @ (posedge clk or negedge reset_n) begin
	if ( !reset_n ) begin	
		wr_buffer	<= 0;
		wr_do		<= 0;
		rd_do		<= 0;
	end else begin
	
		if (coe_simple_read)	
			rd_do	<= 1;
			
		if( coe_simple_write) begin	
			wr_do		<= 1;
			wr_buffer	<= coe_simple_writedata;
		end
		
	end
end

//=============================================================================
// Read
enum {
	read_idle,
	read_read
} state_read;

always_ff @ (posedge clk or negedge reset_n) begin
	if ( !reset_n ) begin
		state_read	<= read_idle;
	end else begin
		case (state_read)
		///
		read_idle: begin
			if ( coe_simple_read || rd_do ) begin
				state_read			<= read_read;
				avm_master_read	<= 1;
			end 
		end
		///
		read_read: begin
			if( avm_master_waitrequest == 0 )
				state_read			<= read_idle;
				avm_master_read	<= 0;
		end
		endcase
	end
end

//=============================================================================
// Read Done
always_ff @ (posedge clk or negedge reset_n) 
	if ( !reset_n ) begin
		coe_simple_readdone	<= 0;
		
	end else begin
		coe_simple_readdone	<= 0;
		
		if ( avm_master_readdatavalid ) begin
			coe_simple_readdata	<= avm_master_readdata;
			coe_simple_readdone	<= 1;
		end
end

//=============================================================================
// Write

enum {
	write_idle,
	write_wait_read,
	write_write
} state_write;

always_ff @ (posedge clk or negedge reset_n) begin
	if ( !reset_n ) begin
		state_write		<= write_idle;
	end else begin
		case( state_write ) 
		///
		write_idle: begin
			if (coe_simple_write || wr_do) begin
				if (state_read == read_idle) begin
					state_write			<= write_write;
					avm_master_write	<= 1;
					avm_master_writedata<= coe_simple_writedata;
				end
				else
					state_write	<= write_wait_read;
			end
		end
		/// 
		write_wait_read: begin
			if (state_read == read_idle) begin
				state_write			<= write_write;
				avm_master_write	<= 1;
				avm_master_writedata<= coe_simple_writedata;
			end
		end
		///
		write_write: begin
			if(!avm_master_waitrequest) begin
				avm_master_write	<= 0;
				state_write			<= write_idle;
			end
		end
		endcase
	end
end

//=============================================================================
// Address latch

logic [31:0] rd_addr_latch, wr_addr_latch;

always @ (posedge clk) begin
	if ( coe_simple_read )
		rd_addr_latch	<= coe_simple_readaddr;
		
	if ( coe_simple_write )
		wr_addr_latch	<= coe_simple_writeaddr;
	
end


//=============================================================================
// Address

assign avm_master_address = avm_master_read ? rd_addr_latch : wr_addr_latch;


endmodule

