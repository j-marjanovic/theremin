
`timescale 1ns/100ps 

module mem_qsys_program;


`define CLK_BFM	mem_qsys_top.mem_controller_tb_inst.mem_controller_inst_clk_bfm
`define COE_BFM mem_qsys_top.mem_controller_tb_inst.mem_controller_inst_simple_2_avalon_conduit_end_0_bfm

initial begin
	$display("========================================");
	$display("         MEM QSYS TEST PROGRAM          ");
	$display("========================================");

	#(2us);
	write(19'd123, 31'hABCD_EF01);
end


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




endmodule
