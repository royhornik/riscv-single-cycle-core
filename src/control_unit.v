// 7. Control Unit 
module control_unit (
    input      [31:0] instruction, // The 32-bit instruction from memory
    output reg        reg_write,   // Tells Register File if it should save data
    output reg [2:0]  alu_control, // Tells ALU which math operation to do
    output reg        alu_src,     // 0 = register b, 1 = immediate value
    output reg        mem_write,   // 1 = write to data memory
    output reg        mem_to_reg,  // 0 = ALU result to reg, 1 = Memory result to reg
    output reg        branch       // NEW: 1 if instruction is a branch
);

    // Slice the instruction into its specific fields
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    // Combinational logic: react immediately to a new instruction
    always @(*) begin
        // Default values to prevent hardware latches
        reg_write   = 0;
        alu_control = 3'b000;
        alu_src     = 0;
        mem_write   = 0;
        mem_to_reg  = 0;
        branch      = 0; // NEW default

        // Decode based on the opcode
        case (opcode)
            7'b0110011: begin // R-type family (Math operations)
                reg_write = 1; 
                if (funct3 == 3'b000 && funct7 == 7'b0000000)      alu_control = 3'b000; // ADD
                else if (funct3 == 3'b000 && funct7 == 7'b0100000) alu_control = 3'b001; // SUB
                else if (funct3 == 3'b111 && funct7 == 7'b0000000) alu_control = 3'b010; // AND
                else if (funct3 == 3'b110 && funct7 == 7'b0000000) alu_control = 3'b011; // OR
                else if (funct3 == 3'b010 && funct7 == 7'b0000000) alu_control = 3'b100; // SLT
            end
            7'b0000011: begin // I-type: lw (Load Word)
                reg_write   = 1;
                alu_src     = 1;      // Tell ALU to use the immediate offset
                mem_to_reg  = 1;      // Route memory output back to register file
                alu_control = 3'b000; // ALU needs to ADD base address + offset
            end
            7'b0100011: begin // S-type: sw (Store Word)
                alu_src     = 1;      // Tell ALU to use the immediate offset
                mem_write   = 1;      // Enable writing to data memory
                alu_control = 3'b000; // ALU needs to ADD base address + offset
            end
            7'b1100011: begin // NEW: Branch (beq)
                branch      = 1;
                alu_src     = 0;      // Compare registers
                alu_control = 3'b001; // Subtract to check if they are equal
            end
            7'b0010011: begin  // I-type: addi
                reg_write   = 1'b1;
                alu_src     = 1'b1;      // Use immediate
                mem_to_reg  = 1'b0;      // Take result from ALU
                alu_control = 3'b000;    // Operation ADD
            end
        endcase
    end

endmodule