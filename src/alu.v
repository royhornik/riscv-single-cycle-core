// 1. ALU 
module alu (
    input      [31:0] a,           // First input (32-bit vector)
    input      [31:0] b,           // Second input (32-bit vector)
    input      [2:0]  alu_control, // Control signal to decide the operation (3 bits)
    output reg [31:0] result,      // Output result
    output            zero         // NEW: Zero flag for branch instructions
);

    // Calculate the result immediately whenever an input changes
    always @(*) begin
        case (alu_control)
            3'b000: result = a + b; // Addition
            3'b001: result = a - b; // Subtraction
            3'b010: result = a & b; // Bitwise AND
            3'b011: result = a | b; // Bitwise OR
            3'b100: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            default: result = 32'b0; // Default case (zero)
        endcase
    end

    // NEW: The zero flag is 1 if the result is exactly 0
    assign zero = (result == 32'b0);

endmodule