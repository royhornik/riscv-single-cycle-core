// 5. Data Memory (DMEM) Module
module dmem (
    input          clk,
    input          we,          // Write Enable - 1 for Store, 0 for Load
    input  [31:0] address,     // The memory address to read/write
    input  [31:0] wd,          // Write Data (comes from register rs2)
    output [31:0] rd           // Read Data (goes to register rd)
);

    // Create a memory array of 64 words (each 32 bits)
    reg [31:0] memory [0:63];

    // Pre-load string: "HELLO FROM RISC-V!\r\n"
    initial begin
        memory[0]  = 32'h00000048; // 'H'
        memory[1]  = 32'h00000045; // 'E'
        memory[2]  = 32'h0000004C; // 'L'
        memory[3]  = 32'h0000004C; // 'L'
        memory[4]  = 32'h0000004F; // 'O'
        memory[5]  = 32'h00000020; // ' '
        memory[6]  = 32'h00000046; // 'F'
        memory[7]  = 32'h00000052; // 'R'
        memory[8]  = 32'h0000004F; // 'O'
        memory[9]  = 32'h0000004D; // 'M'
        memory[10] = 32'h00000020; // ' '
        memory[11] = 32'h00000052; // 'R'
        memory[12] = 32'h00000049; // 'I'
        memory[13] = 32'h00000053; // 'S'
        memory[14] = 32'h00000043; // 'C'
        memory[15] = 32'h0000002D; // '-'
        memory[16] = 32'h00000056; // 'V'
        memory[17] = 32'h00000021; // '!'
        memory[18] = 32'h0000000D; // '\r' (Carriage Return)
        memory[19] = 32'h0000000A; // '\n' (Line Feed)
        memory[20] = 32'h00000000; // 0 (End of String marker)
    end

    // Asynchronous read: Immediately output data from the given address
    // We ignore the bottom 2 bits [31:2] because addresses are byte-aligned (multiples of 4)
    assign rd = memory[address[31:2]];

    // Synchronous write: On clock edge, if write enable is high, save data
    always @(posedge clk) begin
        if (we) begin
            memory[address[31:2]] <= wd;
        end
    end

endmodule