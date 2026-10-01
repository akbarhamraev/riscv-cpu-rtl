module register_file_tb;

    logic        clk;
    logic        reset;

    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;

    logic [31:0] write_data;
    logic        reg_write;

    logic [31:0] read_data1;
    logic [31:0] read_data2;

    register_file dut (
        .clk        (clk),
        .reset      (reset),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (write_data),
        .reg_write  (reg_write),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );

    initial clk = 1'b0;

    // verilator lint_off BLKSEQ
    always #5 clk = ~clk;
    // verilator lint_on BLKSEQ
    
    initial begin

        reset = 1'b1;

        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = 5'b0;
        write_data = 32'b0;
        reg_write = 1'b0;

        // Reset
        #12;

        reset = 1'b0;

        // ------------------------------------------------
        // Test 1: x0 must always be zero
        // ------------------------------------------------

        rd = 5'd0;
        write_data = 32'hDEADBEEF;
        reg_write = 1'b1;

        @(posedge clk);
        #1;

        rs1 = 5'd0;
        #1;

        if (read_data1 !== 32'b0)
            $error("x0 is not zero");

        // ------------------------------------------------
        // Test 2: Write 123 to x5
        // ------------------------------------------------

        rd = 5'd5;
        write_data = 32'd123;
        reg_write = 1'b1;

        @(posedge clk);
        #1;

        reg_write = 1'b0;

        rs1 = 5'd5;
        #1;

        if (read_data1 !== 32'd123)
            $error("x5 read failed: expected 123, got %0d",
                   read_data1);

        // ------------------------------------------------
        // Test 3: Write another register
        // ------------------------------------------------

        rd = 5'd10;
        write_data = 32'hABCDEF01;
        reg_write = 1'b1;

        @(posedge clk);
        #1;

        reg_write = 1'b0;

        rs2 = 5'd10;
        #1;

        if (read_data2 !== 32'hABCDEF01)
            $error("x10 read failed");

        // ------------------------------------------------
        // Test 4: Simultaneous reads
        // ------------------------------------------------

        rs1 = 5'd5;
        rs2 = 5'd10;
        #1;

        if (read_data1 !== 32'd123)
            $error("rs1 read failed");

        if (read_data2 !== 32'hABCDEF01)
            $error("rs2 read failed");

        $display("Register file tests passed!");

        $finish;
    end

endmodule
