`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/28 15:11:21
// Design Name: 
// Module Name: SCPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SCPU(
    input         clk,
    input         rst,
    input  [31:0] inst,
    input  [31:0] data_in,  // data from data memory
    input  [63:0] Reg_IF_ID_i,
    input  [247:0] Reg_ID_EX_i,
    input  [333:0] Reg_EX_MEM_i,
    input  [104:0] Reg_MEM_WB_i,
    input          cache_resp_stall,
    output  [63:0] Reg_IF_ID_o,
    output  [247:0] Reg_ID_EX_o,
    output  [333:0] Reg_EX_MEM_o,
    output  [104:0] Reg_MEM_WB_o,
    input   [4:0] reg_addr,
    //output [31:0] addr_out, // data memory address
    //output [31:0] data_out, // data to data memory
    output [31:0] pc_out,   // connect to instruction memory
    //output        mem_write,
    //output [31:0] write_data,
    //output [31:0] csr_pc_next,
    output [31:0] gp,
    //output [31:0] mtvec,
    //output [31:0] mepc,
    //output [31:0] mstatus,
    output [31:0] register_data,
    output [31:0] Forward_1_data1,
    output reg_w
    );
    wire [3:0] alu_op;
    wire [1:0] pc_src, mem_to_reg;
    wire reg_write, alu_src_a, alu_src_b, branch, b_type, b_type_bge, csr_write,mem_write;
//    wire [63:0] Reg_IF_ID;
//    wire [179:0] Reg_ID_EX;
//    wire [174:0] Reg_EX_MEM;
//    wire [71:0] Reg_MEM_WB;
    assign reg_w=reg_write;
    Control control (
        .op_code(Reg_IF_ID_i[6:0]),
        .funct3(Reg_IF_ID_i[14:12]),
        .funct7_5(Reg_IF_ID_i[30]),
        .pc_src(pc_src),         // 2'b00 ��ʾpc����������pc+4, 2'b01 ��ʾ��������JALR��ת��ַ, 2'b10��ʾ��������JAL��ת��ַ(����branch). branch ��ת������������
        .reg_write(reg_write),   // 1'b1 ��ʾд�Ĵ���
        .alu_src_b(alu_src_b),   // 1'b1 ��ʾALU B�ڵ�����Դ����imm, 1'b0��ʾ��������Reg[rs2]
        .alu_op(alu_op),         // ��������ALU�����������뿴AluOp.vh�жԸ��������ı���
        .mem_to_reg(mem_to_reg), // 2'b00 ��ʾд��rd����������ALU, 2'b01��ʾ��������imm, 2'b10��ʾ��������pc+4, 2'b11 ��ʾ��������data memory
        .mem_write(mem_write),   // 1'b1 ��ʾдdata memory, 1'b0��ʾ��data memory
        .branch(branch),         // 1'b1 ��ʾ��branch���͵�ָ��
        .b_type(b_type)          // 1'b1 ��ʾbeq, 1'b0 ��ʾbne
    );

    Datapath datapath (
        .clk(clk),
        .rst(rst),
        .pc_src(pc_src),
        .reg_write(reg_write),
        .alu_src_b(alu_src_b),
        .branch(branch),
        .b_type(b_type),
        .alu_op(alu_op),
        .mem_to_reg(mem_to_reg),
        .inst(inst),
        .data_in(data_in),
        .mem_write(mem_write),
        .reg_addr(reg_addr),
        .Reg_IF_ID_i(Reg_IF_ID_i),
        .Reg_ID_EX_i(Reg_ID_EX_i),
        .Reg_EX_MEM_i(Reg_EX_MEM_i),
        .Reg_MEM_WB_i(Reg_MEM_WB_i),
        .cache_resp_stall(cache_resp_stall),
        .Reg_IF_ID_o(Reg_IF_ID_o),
        .Reg_ID_EX_o(Reg_ID_EX_o),
        .Reg_EX_MEM_o(Reg_EX_MEM_o),
        .Reg_MEM_WB_o(Reg_MEM_WB_o),
        //.addr_out(addr_out),
        //.data_out(data_out),
        .pc_out(pc_out),
        //.write_data(write_data),
        //.csr_pc_next(csr_pc_next),
        .gp(gp),
//        .mtvec(mtvec),
//        .mepc(mepc),
//        .mstatus(mstatus),
        .register_data(register_data),
        .Forward_1_data1(Forward_1_data1)
    );
//    IF();
//    IF_ID if_id(
//        .clk(clk),
//        .rst(rst),
//        .pc_i(pc_i),
//        .inst(inst),
//        .csr_pc_write_i(csr_pc_write_i),
//        .mux_src_i(mux_src_i),
//        .IF_ID_pc_o(IF_ID_pc_o),
//        .IF_ID_inst_o(IF_ID_pc_o)
//    );
//    ID();
//    ID_EX id_ex(
//    );
//    EX();
//    EX_MEM();
//    MEM();
//    MEM_WB();
//    WB();
    
endmodule
