// 6. Immediate Generator
module imm_gen (
    input      [31:0] instruction,
    output reg [31:0] imm_ext
);
    wire [6:0] opcode = instruction[6:0];
    
    // Extract and sign-extend the immediate value based on the instruction type
    always @(*) begin
        case (opcode)
            // I-type (lw, addi)
            7'b0000011, 
            7'b0010011: imm_ext = {{20{instruction[31]}}, instruction[31:20]};

            // S-type (sw)
            7'b0100011: imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            // B-type (beq)
            7'b1100011: imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

            default:    imm_ext = 32'b0;
        endcase
    end
endmodule
