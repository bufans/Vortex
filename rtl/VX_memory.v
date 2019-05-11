
`include "VX_define.v"


module VX_memory (
	/* verilator lint_off UNUSED */
		input wire        clk,
		/* verilator lint_on UNUSED */
		input wire[(`NT*32)-1:0]      in_alu_result,
		input wire[2:0]       in_mem_read, 
		input wire[2:0]       in_mem_write,
		input wire[4:0]       in_rd,
		input wire[1:0]       in_wb,
		input wire[4:0]       in_rs1,
		input wire[4:0]       in_rs2,
		input wire[(`NT*32)-1:0] in_rd2,
		input wire[31:0]      in_PC_next,
		input wire[31:0]      in_curr_PC,
		input wire[31:0]      in_branch_offset,
		input wire[2:0]       in_branch_type, 
		input wire[`NT_M1:0]  in_valid,
		input wire[(`NT*32)-1:0]      in_cache_driver_out_data,
		input wire[`NW_M1:0]  in_warp_num,

		output wire[(`NT*32)-1:0]      out_alu_result,
		output wire[(`NT*32)-1:0]      out_mem_result,
		output wire[4:0]       out_rd,
		output wire[1:0]       out_wb,
		output wire[4:0]       out_rs1,
		output wire[4:0]       out_rs2,
		output reg             out_branch_dir,
		output wire[31:0]      out_branch_dest,
		output wire            out_delay,
		output wire[31:0]      out_PC_next,
		output wire[`NT_M1:0]  out_valid,
		output wire[(`NT*32)-1:0]      out_cache_driver_in_address,
		output wire[2:0]       out_cache_driver_in_mem_read,
		output wire[2:0]       out_cache_driver_in_mem_write,
		output wire[`NT_M1:0]  out_cache_driver_in_valid,
		output wire[(`NT*32)-1:0]      out_cache_driver_in_data,
		output wire[`NW_M1:0]  out_warp_num
	);	

		// always @(in_mem_read, in_cache_driver_out_data) begin
		// 	if (in_mem_read == `LW_MEM_READ) begin
		// 		$display("PC: %h ----> Received: %h for addr: ", in_curr_PC, in_cache_driver_out_data[0], in_alu_result[0]);
		// 	end
		// end

		// wire[15:0] addr_0 = in_alu_result[0][31:16];

		// wire sm_valid[`NT_M1:0];

		// assign sm_valid = (addr_0 != 16'hFFFF) ? in_valid : in_valid;


		 // wire z_valid[`NT_M1:0];
		 // assign z_valid = 0;

		assign out_delay = 1'b0;

		assign out_cache_driver_in_address   = in_alu_result;
		assign out_cache_driver_in_mem_read  = in_mem_read;
		assign out_cache_driver_in_mem_write = in_mem_write;
		assign out_cache_driver_in_data      = in_rd2;

		assign out_cache_driver_in_valid = in_valid;
		// assign out_cache_driver_in_valid[0]  = in_valid[0];
		// assign out_cache_driver_in_valid[1]  = in_valid[1];

		// always @(*) begin
		// 	if (in_valid[0] && (in_mem_write == `SW_MEM_WRITE) && (in_alu_result[0] >= 32'h810049a0)) begin
		// 		$display("SW$ PC: %h - Warp: %h -> [%h]%h = %h || [%h]%h = %h",in_curr_PC, in_warp_num, in_valid[0], in_alu_result[0], in_rd2[0], in_valid[1], in_alu_result[1], in_rd2[1]);
		// 	end
		// end



		// wire[31:0] sm_out_data[`NT_M1:0];


		// VX_shared_memory vx_shared_memory(
		// 	.clk         (clk),
		// 	.in_address  (in_alu_result),
		// 	.in_mem_read (in_mem_read),
		// 	.in_mem_write(in_mem_write),
		// 	.in_valid    (sm_valid),
		// 	.in_data     (in_rd2),
		// 	.out_data    (sm_out_data)
		// 	);


		// assign out_mem_result = sm_valid ? sm_out_data : in_cache_driver_out_data;
		assign out_mem_result = in_cache_driver_out_data;
		assign out_alu_result = in_alu_result;
		assign out_rd         = in_rd;
		assign out_wb         = in_wb;
		assign out_rs1        = in_rs1;
		assign out_rs2        = in_rs2;
		assign out_PC_next    = in_PC_next;
		assign out_valid      = in_valid;
		assign out_warp_num   = in_warp_num;

		// always @(*) begin 

		// 	if (in_cache_driver_out_data[0] != 32'hbabebabe)
		// 	begin
		// 		$display("MEM: data read from cache_driver: %h", in_cache_driver_out_data[0]);
		// 	end
		
		// end


		assign out_branch_dest = $signed(in_curr_PC) + ($signed(in_branch_offset) << 1);
		
		always @(*) begin
			case(in_branch_type)
				`BEQ:  out_branch_dir = (in_alu_result[31:0] == 0)     ? `TAKEN     : `NOT_TAKEN;
				`BNE:  
					begin
						out_branch_dir = (in_alu_result[31:0] == 0)     ? `NOT_TAKEN : `TAKEN;
					end
				`BLT:  out_branch_dir = (in_alu_result[31] == 0) ? `NOT_TAKEN : `TAKEN;
				`BGT:  out_branch_dir = (in_alu_result[31] == 0) ? `TAKEN     : `NOT_TAKEN;
				`BLTU: 
					begin 
						out_branch_dir = (in_alu_result[31] == 0) ? `NOT_TAKEN : `TAKEN; 
						if (in_warp_num == 1) begin
							// $display("BLTU PC:%h : %d < %d = %d", in_curr_PC, in_rs1, in_rs2, (in_alu_result[0][31] == 0)); 
						end
					end
				`BGTU: out_branch_dir = (in_alu_result[31] == 0) ? `TAKEN     : `NOT_TAKEN;
				`NO_BRANCH: out_branch_dir = `NOT_TAKEN;
				default:    out_branch_dir = `NOT_TAKEN;
			endcase // in_branch_type
		end



endmodule // Memory


