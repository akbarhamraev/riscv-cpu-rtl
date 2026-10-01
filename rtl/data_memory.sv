module data_memory (
    input  logic        clk,
    input  logic        reset,

    input  logic        mem_read,
    input  logic        mem_write,

    input  logic [31:0] address,
    input  logic [31:0] write_data,

    output logic [31:0] read_data
);

    logic [31:0] mem [0:255];

    integer i;

    always_ff @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 32'b0;

        end
        else if (mem_write) begin

            mem[address[9:2]] <= write_data;

        end

    end

    always_comb begin

        if (mem_read)
            read_data = mem[address[9:2]];
        else
            read_data = 32'b0;

    end

endmodule
