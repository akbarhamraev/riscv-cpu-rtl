module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [2:0]  alu_op;

    logic [31:0] result;
    logic        zero;

    alu dut (
        .a      (a),
        .b      (b),
        .alu_op (alu_op),
        .result (result),
        .zero   (zero)
    );

    initial begin

        // ADD: 10 + 5 = 15
        a = 10;
        b = 5;
        alu_op = 3'b000;
        #10;

        if (result != 15)
            $error("ADD failed: expected 15, got %0d", result);

        // SUB: 10 - 5 = 5
        a = 10;
        b = 5;
        alu_op = 3'b001;
        #10;

        if (result != 5)
            $error("SUB failed: expected 5, got %0d", result);

        // AND
        a = 32'h0000_FF00;
        b = 32'h0000_0F0F;
        alu_op = 3'b010;
        #10;

        if (result != 32'h0000_0F00)
            $error("AND failed: expected 0x0F00, got 0x%08h", result);

        // OR
        a = 32'h0000_FF00;
        b = 32'h0000_0F0F;
        alu_op = 3'b011;
        #10;

        if (result != 32'h0000_FF0F)
            $error("OR failed: expected 0xFF0F, got 0x%08h", result);

        // XOR
        a = 32'h0000_FF00;
        b = 32'h0000_0F0F;
        alu_op = 3'b100;
        #10;

        if (result != 32'h0000_F00F)
            $error("XOR failed: expected 0xF00F, got 0x%08h", result);

        // Test ZERO flag
        a = 10;
        b = 10;
        alu_op = 3'b001;
        #10;

        if (result != 0)
            $error("ZERO test failed: expected result 0");

        if (zero != 1)
            $error("ZERO flag failed: expected zero=1");

        $display("All ALU tests passed!");

        $finish;
    end

endmodule
