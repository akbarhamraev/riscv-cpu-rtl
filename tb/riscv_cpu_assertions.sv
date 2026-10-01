module riscv_cpu_assertions (
    input logic        clk,
    input logic        reset,

    input logic [31:0] pc,

    input logic [31:0] register_x0
);

    // ------------------------------------------------
    // x0 must always remain zero
    // ------------------------------------------------

    property x0_always_zero;
        @(posedge clk)
        disable iff (reset)
        register_x0 == 32'b0;
    endproperty

    assert property (x0_always_zero)
        else $error("ASSERTION FAILED: x0 is not zero");

    // ------------------------------------------------
    // PC must remain word aligned
    // ------------------------------------------------

    property pc_word_aligned;
        @(posedge clk)
        disable iff (reset)
        pc[1:0] == 2'b00;
    endproperty

    assert property (pc_word_aligned)
        else $error("ASSERTION FAILED: PC is not word aligned");

endmodule
