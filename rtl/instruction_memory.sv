module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    logic [31:0] mem [0:255];

    always_comb begin
        instruction = mem[address[9:2]];
    end

endmodule
