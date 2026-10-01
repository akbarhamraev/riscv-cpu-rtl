module riscv_cpu (
    input logic clk,
    input logic reset
);

    // ============================================================
    // Program Counter
    // ============================================================

    logic [31:0] pc;
    logic [31:0] next_pc;

    // ============================================================
    // Instruction
    // ============================================================

    logic [31:0] instruction;

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic       funct7_bit5;

    assign opcode       = instruction[6:0];
    assign rd           = instruction[11:7];
    assign funct3       = instruction[14:12];
    assign rs1          = instruction[19:15];
    assign rs2          = instruction[24:20];
    assign funct7_bit5  = instruction[30];

    // ============================================================
    // Control
    // ============================================================

    logic       reg_write;
    logic       mem_write;
    logic       mem_read;
    logic       alu_src;
    logic       mem_to_reg;
    logic       branch;
    logic       jump;

    logic [1:0] alu_op;
    logic [2:0] alu_control_signal;

    // ============================================================
    // Register File
    // ============================================================

    logic [31:0] register_data1;
    logic [31:0] register_data2;

    logic [31:0] write_back_data;

    // ============================================================
    // Immediate
    // ============================================================

    logic [31:0] immediate;

    // ============================================================
    // ALU
    // ============================================================

    logic [31:0] alu_input_b;
    logic [31:0] alu_result;
    logic        alu_zero;

    // ============================================================
    // Data Memory
    // ============================================================

    logic [31:0] memory_read_data;

    // ============================================================
    // Branch / Jump
    // ============================================================

    logic [31:0] branch_target;
    logic [31:0] jump_target;

    logic branch_taken;

    // ============================================================
    // Instruction Memory
    // ============================================================

    instruction_memory instruction_memory (
        .address      (pc),
        .instruction  (instruction)
    );

    // ============================================================
    // Control Unit
    // ============================================================

    control_unit control_unit (
        .opcode      (opcode),

        .reg_write   (reg_write),
        .mem_write   (mem_write),
        .mem_read    (mem_read),
        .alu_src     (alu_src),
        .mem_to_reg  (mem_to_reg),
        .branch      (branch),
        .jump        (jump),
        .alu_op      (alu_op)
    );

    // ============================================================
    // Register File
    // ============================================================

    register_file register_file (
        .clk        (clk),
        .reset      (reset),

        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),

        .write_data (write_back_data),
        .reg_write  (reg_write),

        .read_data1 (register_data1),
        .read_data2 (register_data2)
    );

    // ============================================================
    // Immediate Generator
    // ============================================================

    imm_gen imm_gen (
        .instruction (instruction),
        .immediate   (immediate)
    );

    // ============================================================
    // ALU Control
    // ============================================================

alu_control u_alu_control (
    .alu_op             (alu_op),
    .funct3             (funct3),
    .funct7_bit5        (funct7_bit5),

    .alu_control_signal (alu_control_signal)
);

    // ============================================================
    // ALU input selection
    // ============================================================

    assign alu_input_b =
        alu_src ? immediate : register_data2;

    // ============================================================
    // ALU
    // ============================================================

    alu alu (
        .a       (register_data1),
        .b       (alu_input_b),
        .alu_op  (alu_control_signal),

        .result  (alu_result),
        .zero    (alu_zero)
    );

    // ============================================================
    // Data Memory
    // ============================================================

    data_memory data_memory (
        .clk        (clk),
        .reset      (reset),

        .mem_read   (mem_read),
        .mem_write  (mem_write),

        .address    (alu_result),
        .write_data (register_data2),

        .read_data  (memory_read_data)
    );

    // ============================================================
    // Writeback
    // ============================================================

    always_comb begin

        if (mem_to_reg)
            write_back_data = memory_read_data;
        else if (jump)
            write_back_data = pc + 32'd4;
        else
            write_back_data = alu_result;

    end

    // ============================================================
    // Branch logic
    // ============================================================

    assign branch_taken = branch && alu_zero;

    assign branch_target = pc + immediate;

    // ============================================================
    // JAL target
    // ============================================================

    assign jump_target = pc + immediate;

    // ============================================================
    // Next PC
    // ============================================================

    always_comb begin

        next_pc = pc + 32'd4;

        if (branch_taken)
            next_pc = branch_target;

        if (jump)
            next_pc = jump_target;

    end

    // ============================================================
    // Program Counter register
    // ============================================================

    always_ff @(posedge clk) begin

        if (reset)
            pc <= 32'b0;
        else
            pc <= next_pc;

    end

endmodule
