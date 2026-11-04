// Instruction Memory (IMEM)
// SIM = 0: the board program (prints "HELLO FROM RISC-V!" over UART)
// SIM = 1: the self-checking test program used by cpu_tb
module imem #(
    parameter SIM = 0
) (
    input      [31:0] pc_address,
    output     [31:0] instruction
);

    reg [31:0] memory [0:63];

    initial begin
        if (SIM) begin
            memory[0] = 32'h00A00093;   // addi x1, x0, 10       -> x1 = 10
            memory[1] = 32'h01400113;   // addi x2, x0, 20       -> x2 = 20
            memory[2] = 32'h002081B3;   // add  x3, x1, x2       -> x3 = 30
            memory[3] = 32'h40110233;   // sub  x4, x2, x1       -> x4 = 10
            memory[4] = 32'h0020F2B3;   // and  x5, x1, x2       -> x5 = 0
            memory[5] = 32'h0020E333;   // or   x6, x1, x2       -> x6 = 30
            memory[6] = 32'h0020A3B3;   // slt  x7, x1, x2       -> x7 = 1
            memory[7] = 32'h00302023;   // sw   x3, 0(x0)        -> save 30 into dmem[0]
            memory[8] = 32'h00002403;   // lw   x8, 0(x0)        -> x8 = 30
            memory[9] = 32'h00408463;   // beq  x1, x4, 8        -> 10 == 10, skip the next instruction
            memory[10] = 32'h06300493;   // addi x9, x0, 99       -> must be SKIPPED (x9 stays 0)
            memory[11] = 32'h00100513;   // addi x10, x0, 1       -> branch target (x10 = 1)
            memory[12] = 32'h00000063;   // beq  x0, x0, 0        -> infinite loop (stop)
        end else begin
            memory[0] = 32'h04000113;   // addi x2, x0, 64        -> UART MMIO address = 0x40
            memory[1] = 32'h00000093;   // addi x1, x0, 0         -> reset string pointer (x1 = 0)
            memory[2] = 32'h0000A183;   // lw   x3, 0(x1)         -> load char from dmem   (loop start)
            memory[3] = 32'h00018863;   // beq  x3, x0, 16        -> if char == 0, jump to 0x1C
            memory[4] = 32'h00312023;   // sw   x3, 0(x2)         -> transmit char via UART
            memory[5] = 32'h00408093;   // addi x1, x1, 4         -> advance pointer (+4 bytes)
            memory[6] = 32'hFE0008E3;   // beq  x0, x0, -16       -> jump back to 0x08
            memory[7] = 32'hFE0004E3;   // beq  x0, x0, -24       -> jump back to 0x04 (restart string)
        end
    end

    assign instruction = memory[pc_address[31:2]];

endmodule