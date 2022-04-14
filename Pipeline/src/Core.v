`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/28 18:08:36
// Design Name: 
// Module Name: Core
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


module Core(
    input  wire        clk,
    input  wire        aresetn,
    input  wire        step,
    input  wire        debug_mode,
    input  wire [4:0]  debug_reg_addr, // register address
    input  wire [6:0]  debug_cache_index,

    output wire [31:0] address,
    output wire [31:0] data_out,
    input  wire [31:0] data_in,
    
    input  wire [31:0] chip_debug_in,
    output reg [31:0] chip_debug_out0,
    output reg [31:0] chip_debug_out1,
    output reg [31:0] chip_debug_out2,
    output reg [31:0] chip_debug_out3
);
    wire [63:0] Reg_IF_ID_i;
    wire [247:0] Reg_ID_EX_i;
    wire [333:0] Reg_EX_MEM_i;
    wire [104:0] Reg_MEM_WB_i;
    wire [63:0] Reg_IF_ID_o;
    wire [247:0] Reg_ID_EX_o;
    wire [333:0] Reg_EX_MEM_o;
    wire [104:0] Reg_MEM_WB_o;
    wire rst, mem_clk, cpu_clk;
    wire [31:0] inst, core_data_in, core_data_out, pc_out,gp,register_data,Forward_1_data1;
    wire reg_w;
    reg  [31:0] clk_div;
    wire rom_req_valid,cache_req_wen,cache_req_valid,mem_req_wen,mem_req_valid,mem_resp_valid,rom_resp_valid;
    wire [31:0] rom_req_addr,rom_resp_data,mem_req_addr,mem_req_data,cache_resp_data,rom_req_data;
    wire cache_resp_stall,i_cache_resp_stall,rom_req_wen;
    wire dcache_clk;
    wire [31:0] debug_cache_out0,debug_cache_out1,debug_cache_out2;
    assign rst = ~aresetn;
    assign dcache_clk=0;
    SCPU cpu(
        .clk(cpu_clk),
        .rst(rst),
        .inst(inst),
        .data_in(cache_resp_data),      // data from data memory
        .Reg_IF_ID_i(Reg_IF_ID_i),
        .Reg_ID_EX_i(Reg_ID_EX_i),
        .Reg_EX_MEM_i(Reg_EX_MEM_i),
        .Reg_MEM_WB_i(Reg_MEM_WB_i),
        .cache_resp_stall(cache_resp_stall),
        .Reg_IF_ID_o(Reg_IF_ID_o),
        .Reg_ID_EX_o(Reg_ID_EX_o),
        .Reg_EX_MEM_o(Reg_EX_MEM_o),
        .Reg_MEM_WB_o(Reg_MEM_WB_o),
        .reg_addr(debug_reg_addr),
        //.addr_out(addr_out),         // data memory address
        //.data_out(core_data_out),    // data to data memory
        .pc_out(pc_out),             // connect to instruction memory
        //.mem_write(mem_write),
        //.write_data(write_data),
        //.csr_pc_next(csr_pc_next),
        .gp(gp),
//        .mtvec(mtvec),
//        .mepc(mepc),
//        .mstatus(mstatus),
        .register_data(register_data),
        .Forward_1_data1(Forward_1_data1),
        .reg_w(reg_w)
    );
        Rom rom_unit (
        .a(pc_out/4),  // ��ַ����
        .spo(rom_resp_data) // ���������
    );
     //assign rom_resp_valid=1;
     ICache I_Cache(
        .cache_req_addr(pc_out),//��ˮ�߷����Ķ�/д��ַ
        .cache_resp_data(inst),//����ˮ���ύ����������
        .mem_req_addr(rom_req_addr),//����Memory�Ķ�/д��ַ
        .mem_resp_data(rom_resp_data)//�ڴ淵������
    );
    CMU cmu(
        .op_code(Reg_EX_MEM_i[333:327]),
        .cache_req_wen(cache_req_wen),//cacheдʹ��
        .cache_req_valid(cache_req_valid)//����cache�Ķ�д�������Ч��
//        .mem_req_addr(mem_req_addr),
//        .core_data_in(core_data_in),
//        .mem_req_valid(mem_req_valid),
//        .mem_resp_valid(mem_resp_valid)
        
    );
    DCache D_Cache(
        .clk(cpu_clk),
        .rst(rst),
        .debug_cache_index(debug_cache_index),
        .debug_cache_out0(debug_cache_out0),
        .debug_cache_out1(debug_cache_out1),
        .debug_cache_out2(debug_cache_out2),
        .cache_req_addr(Reg_EX_MEM_i[100:69]),//��ˮ�߷����Ķ�/д��ַ
        .cache_req_data(Reg_EX_MEM_i[207:176]),//д������
        .cache_req_wen(cache_req_wen),//cacheдʹ�ܣ�д1����0
        .cache_req_valid(cache_req_valid),//����cache�Ķ�д�������Ч�ԣ�����д1
        .cache_resp_data(cache_resp_data),//����ˮ���ύ����������
        .cache_resp_stall(cache_resp_stall),//��ˮ���Ƿ���Ҫ����stall
        .mem_req_addr(mem_req_addr),//����Memory�Ķ�/д��ַ
        .mem_req_data(mem_req_data),//����Memoryд�������
        .mem_req_wen(mem_req_wen),//Memoryдʹ��
        .mem_req_valid(mem_req_valid),//����Memory�Ķ�д�������Ч��,miss=1,hit=0
        .mem_resp_data(core_data_in),//�ڴ淵������
        .mem_resp_valid(mem_resp_valid)//Memory���ݲ�ѯ���1,δ���0
    );
        assign Reg_IF_ID_i=Reg_IF_ID_o;
        assign Reg_ID_EX_i=Reg_ID_EX_o;
        assign Reg_EX_MEM_i=Reg_EX_MEM_o;
        assign Reg_MEM_WB_i=Reg_MEM_WB_o;    
 


    always @(posedge clk) begin
        if(rst) begin clk_div <= 0;end
        else clk_div <= clk_div + 1;
    end
    assign mem_clk = ~clk_div[0]; // 50mhz
    assign cpu_clk = debug_mode ? clk_div[0] : step;
    
    // TODO: ����Instruction Memory
//    Inst_Mem IM(
//        .a(rom_req_addr/4),
//        .spo(rom_resp_data),
//        .rom_resp_valid(rom_resp_valid)
//    );


    // TODO: ����Data Memory
     LatencyMemory mem(
        .clk(mem_clk),
        .rst(rst),
        .en(mem_req_valid),
        .we(mem_req_wen),
        //.we(Reg_EX_MEM_i[175]),
        .addr(mem_req_addr),
        .data_in(mem_req_data),
        .data_out(core_data_in),
        .mem_resp_valid(mem_resp_valid)
     );
     //assign mem_req_valid=mem_req_valid>>1;
    /*
    
    Ram ram_unit (
        .clka(mem_clk),  // ʱ��
        .wea(Reg_EX_MEM_i[175]),
        //.wea(mem_write),   // �Ƿ�д����
        .addra(Reg_EX_MEM_i[100:69]),
        //.addra(addr_out), // ��ַ����
        //.dina(core_data_out),  // д��������
        .dina(Reg_EX_MEM_i[207:176]),
        .douta(core_data_in)  // ���������
    );
    */
    always@(*)begin
    // TODO: ���32���Ĵ���������
    chip_debug_out0 = pc_out;//pc
    chip_debug_out1 = register_data;//inst
    chip_debug_out2 = debug_cache_out0;
    //assign chip_debug_out2 = addr_out;//address
    chip_debug_out3 = debug_cache_out1;//data
    end

endmodule
