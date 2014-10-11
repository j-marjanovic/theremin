
`timescale 1ns/100ps 

module mem_qsys_program;


`define CLK_BFM	mem_qsys_top.mem_controller_tb_inst.mem_controller_inst_clk_bfm
`define COE_BFM mem_qsys_top.mem_controller_tb_inst.mem_controller_inst_simple_2_avalon_conduit_end_0_bfm

logic [31:0] readdata;

initial begin
	$display("========================================");
	$display("         MEM QSYS TEST PROGRAM          ");
	$display("========================================");

	`COE_BFM.set_read( 1'b0 );
	`COE_BFM.set_write( 1'b0 );

	// Wait for init done
	#(250us);


	// Test first write then read
	write(19'd60, 31'hABCD_EF01);
	#(200ns);
	read(19'd60, readdata);

	// Test arbitration for concurent read and write
	#(1us);
	fork
	write(19'd60, 31'h01020304);
	read(19'd60, readdata);
	join
	// Read previous value
	#(1us);
	read(19'd60, readdata);

	#(1us);

	// Test read latch
	fork
	write(19'd60, 31'h1a1a7071);
	begin
	@(posedge `CLK_BFM.clk);
	read(19'd60, readdata);
	end
	join

	#(1us);

	// Test write latch
	fork
	read(19'd60, readdata);

	begin
	@(posedge `CLK_BFM.clk);
	write(19'd60, 31'h09909876);
	end
	join

	// Read previous value
	#(1us);
	read(19'd60, readdata);
	
end


///////////////////////////////////////////////////////////////////////////////
// write task
task write (
	input [18:0] addr,
	input [31:0] data 
);

	@(posedge `CLK_BFM.clk)
	`COE_BFM.set_write( 1'b1 );
	`COE_BFM.set_writeaddr( addr );
	`COE_BFM.set_writedata( data );

	@(posedge `CLK_BFM.clk)
	`COE_BFM.set_write( 1'b0 );
	`COE_BFM.set_writeaddr( 'X );
	`COE_BFM.set_writedata( 'X );


endtask


///////////////////////////////////////////////////////////////////////////////
// read task
task read (
	input [18:0] addr,
	output logic [31:0] data 
);
	fork 
	//--------------------------------------------
	begin
		@(posedge `CLK_BFM.clk)
		`COE_BFM.set_read( 1'b1 );
		`COE_BFM.set_readaddr( addr );

		@(posedge `CLK_BFM.clk)
		`COE_BFM.set_read( 1'b0 );
		`COE_BFM.set_readaddr( 'X );
	end
	//--------------------------------------------
	begin
		for(int i = 0; i < 100; i++) begin	
			@(posedge `CLK_BFM.clk) begin
				if( `COE_BFM.get_readdone() ) begin
					$display( "%t read done, data: %08x", $time(), `COE_BFM.get_readdata());
					data	<= `COE_BFM.get_readdata();
					break;
				end
			end			
		end
	end
	join



endtask




endmodule
