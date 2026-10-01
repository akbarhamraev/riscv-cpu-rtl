module alu_control (
    input  logic [1:0] alu_op,
    input  logic [2:0] funct3,
    input  logic       funct7_bit5,

    output logic [2:0] alu_control_signal
);

    always_comb begin

        case (alu_op)

            // Load/store/address calculation
            2'b00:
                alu_control_signal = 3'b000; // ADD

            // Branch comparison
            2'b01:
                alu_control_signal = 3'b001; // SUB

            // R-type / I-type arithmetic
            2'b10: begin

                case (funct3)

                    3'b000: begin
                        if (funct7_bit5)
                            alu_control_signal = 3'b001; // SUB
                        else
                            alu_control_signal = 3'b000; // ADD
                    end

                    3'b111:
                        alu_control_signal = 3'b010; // AND

                    3'b110:
                        alu_control_signal = 3'b011; // OR

                    3'b100:
                        alu_control_signal = 3'b100; // XOR

                    default:
                        alu_control_signal = 3'b000;

                endcase

            end

            default:
                alu_control_signal = 3'b000;

        endcase

    end

endmodule
