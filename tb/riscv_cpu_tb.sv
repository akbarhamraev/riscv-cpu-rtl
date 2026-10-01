module riscv_cpu_tb;

    logic clk;
    logic reset;

    riscv_cpu dut (
        .clk   (clk),
        .reset (reset)
    );

    riscv_cpu_assertions assertions (
        .clk        (clk),
        .reset      (reset),
        .pc         (dut.pc),
        .register_x0(dut.register_file.registers[0])
    );

    // Clock: 10 time-unit period
    always #5 clk <= ~clk;

    integer i;

    initial begin

        // ------------------------------------------------
        // Enable waveform dumping
        // ------------------------------------------------

        $dumpfile("riscv_cpu.vcd");
        $dumpvars(0, riscv_cpu_tb);

        // ------------------------------------------------
        // Initial state
        // ------------------------------------------------

        clk = 1'b0;
        reset = 1'b1;

        // ------------------------------------------------
        // Fill instruction memory with NOPs
        // ------------------------------------------------

        for (i = 0; i < 256; i = i + 1)
            dut.instruction_memory.mem[i] = 32'h00000013;

        // ------------------------------------------------
        // Program
        // ------------------------------------------------

        // x1 = 10
        // ADDI x1, x0, 10
        dut.instruction_memory.mem[0] = 32'h00A00093;

        // x2 = 20
        // ADDI x2, x0, 20
        dut.instruction_memory.mem[1] = 32'h01400113;

        // x3 = x1 + x2 = 30
        // ADD x3, x1, x2
        dut.instruction_memory.mem[2] = 32'h002081B3;

        // x4 = x2 - x1 = 10
        // SUB x4, x2, x1
        dut.instruction_memory.mem[3] = 32'h40110233;

        // x5 = x1 & x2 = 0
        // AND x5, x1, x2
        dut.instruction_memory.mem[4] = 32'h0020F2B3;

        // x6 = x1 | x2 = 30
        // OR x6, x1, x2
        dut.instruction_memory.mem[5] = 32'h0020E333;

        // x7 = x1 ^ x2 = 30
        // XOR x7, x1, x2
        dut.instruction_memory.mem[6] = 32'h0020C3B3;

        // ------------------------------------------------
        // Memory test
        // ------------------------------------------------

        // memory[0] = x3
        // SW x3, 0(x0)
        dut.instruction_memory.mem[7] = 32'h00302023;

        // x8 = memory[0]
        // LW x8, 0(x0)
        dut.instruction_memory.mem[8] = 32'h00002403;

        // ------------------------------------------------
        // BEQ test
        // ------------------------------------------------

        // x9 = 30
        // ADDI x9, x0, 30
        dut.instruction_memory.mem[9] = 32'h01E00493;

        // x10 = 30
        // ADDI x10, x0, 30
        dut.instruction_memory.mem[10] = 32'h01E00513;

        // BEQ x9, x10, +8
        // Skip instruction at address 48
        dut.instruction_memory.mem[11] = 32'h00A48463;

        // This instruction should be skipped
        // ADDI x11, x0, 111
        dut.instruction_memory.mem[12] = 32'h06F00593;

        // Branch target
        // ADDI x11, x0, 222
        dut.instruction_memory.mem[13] = 32'h0DE00593;

        // ------------------------------------------------
        // JAL test
        // ------------------------------------------------

        // Jump forward by 8 bytes
        // JAL x12, +8
        dut.instruction_memory.mem[14] = 32'h0080066F;

        // This instruction should be skipped
        // ADDI x13, x0, 123
        dut.instruction_memory.mem[15] = 32'h07B00693;

        // JAL target
        // ADDI x13, x0, 456
        dut.instruction_memory.mem[16] = 32'h1C800693;

        // NOP
        dut.instruction_memory.mem[17] = 32'h00000013;

        // ------------------------------------------------
        // Release reset
        // ------------------------------------------------

        #12;
        reset = 1'b0;

        // ------------------------------------------------
        // Run CPU
        // ------------------------------------------------

        #220;

        // ------------------------------------------------
        // Verification
        // ------------------------------------------------

        if (dut.register_file.registers[1] !== 32'd10)
            $error("x1 incorrect: %0d",
                   dut.register_file.registers[1]);

        if (dut.register_file.registers[2] !== 32'd20)
            $error("x2 incorrect: %0d",
                   dut.register_file.registers[2]);

        if (dut.register_file.registers[3] !== 32'd30)
            $error("x3 incorrect: %0d",
                   dut.register_file.registers[3]);

        if (dut.register_file.registers[4] !== 32'd10)
            $error("x4 SUB incorrect: %0d",
                   dut.register_file.registers[4]);

        if (dut.register_file.registers[5] !== 32'd0)
            $error("x5 AND incorrect: %0d",
                   dut.register_file.registers[5]);

        if (dut.register_file.registers[6] !== 32'd30)
            $error("x6 OR incorrect: %0d",
                   dut.register_file.registers[6]);

        if (dut.register_file.registers[7] !== 32'd30)
            $error("x7 XOR incorrect: %0d",
                   dut.register_file.registers[7]);

        if (dut.data_memory.mem[0] !== 32'd30)
            $error("memory[0] incorrect: %0d",
                   dut.data_memory.mem[0]);

        if (dut.register_file.registers[8] !== 32'd30)
            $error("x8 LW incorrect: %0d",
                   dut.register_file.registers[8]);

        // BEQ must skip x11 = 111
        if (dut.register_file.registers[11] !== 32'd222)
            $error("BEQ failed: x11 = %0d",
                   dut.register_file.registers[11]);

        // JAL must skip x13 = 123
        if (dut.register_file.registers[13] !== 32'd456)
            $error("JAL failed: x13 = %0d",
                   dut.register_file.registers[13]);

        // JAL writes return address into x12
        if (dut.register_file.registers[12] !== 32'd60)
            $error("JAL link failed: x12 = %0d",
                   dut.register_file.registers[12]);

        // ------------------------------------------------
        // Test result
        // ------------------------------------------------

        $display("");
        $display("========================================");
        $display("       RISC-V CPU TEST PASSED");
        $display("========================================");

        $display("x1  = %0d", dut.register_file.registers[1]);
        $display("x2  = %0d", dut.register_file.registers[2]);
        $display("x3  = %0d", dut.register_file.registers[3]);
        $display("x4  = %0d", dut.register_file.registers[4]);
        $display("x5  = %0d", dut.register_file.registers[5]);
        $display("x6  = %0d", dut.register_file.registers[6]);
        $display("x7  = %0d", dut.register_file.registers[7]);
        $display("x8  = %0d", dut.register_file.registers[8]);
        $display("x11 = %0d", dut.register_file.registers[11]);
        $display("x12 = %0d", dut.register_file.registers[12]);
        $display("x13 = %0d", dut.register_file.registers[13]);

        $display("mem[0] = %0d", dut.data_memory.mem[0]);

        $display("========================================");

        $finish;

    end

endmodule
