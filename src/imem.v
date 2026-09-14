// 4. Instruction Memory (IMEM) Module
module imem (
    input      [31:0] pc_address,
    output     [31:0] instruction
);

    reg [31:0] memory [0:63];

    initial begin
        // 0x00: addi x2, x0, 64        -> UART MMIO address = 0x40
        memory[0] = 32'h04000113;

        // 0x04: addi x1, x0, 0         -> Reset string pointer (x1 = 0)
        memory[1] = 32'h00000093;

        // --- Loop Start ---
        // 0x08: lw   x3, 0(x1)         -> Load char from dmem
        memory[2] = 32'h0000A183;

        // 0x0C: beq  x3, x0, 16        -> If char == 0, jump to 0x1C (+16 bytes)
        memory[3] = 32'h00018863;

        // 0x10: sw   x3, 0(x2)         -> Transmit char via UART
        memory[4] = 32'h00312023;

        // 0x14: addi x1, x1, 4         -> Advance pointer (+4 bytes)
        memory[5] = 32'h00408093;

        // 0x18: beq  x0, x0, -16       -> Jump back to 0x08 (-16 bytes)
        memory[6] = 32'hFE0008E3;

        // --- Reset String ---
        // 0x1C: beq  x0, x0, -24       -> Jump back to 0x04 (-24 bytes)
        memory[7] = 32'hFE0004E3;
    end

    assign instruction = memory[pc_address[31:2]];

endmodule