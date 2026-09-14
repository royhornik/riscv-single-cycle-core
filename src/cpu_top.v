// 8. Top Level CPU with UART TX (MMIO)
module cpu (
    input        clk,       // 27MHz system clock
    input        reset,     // Active-low push button
    output       uart_tx,   // Physical UART TX pin to PC
    output [5:0] led        // Visual PC progress
);

    // Internal interconnect wires
    wire [31:0] current_pc, next_pc, instruction, imm_ext;
    wire        reg_write, alu_src, mem_write, mem_to_reg, branch;
    wire [2:0]  alu_control;
    wire [31:0] rd1, rd2, alu_result, dmem_rd;
    wire        alu_zero;

    // Decode register addresses from instruction
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];

    // Datapath Multiplexers
    wire [31:0] alu_b           = alu_src ? imm_ext : rd2;
    wire [31:0] write_back_data = mem_to_reg ? dmem_rd : alu_result;

    // Branch Logic
    wire        pc_src        = branch & alu_zero;
    wire [31:0] pc_plus_4     = current_pc + 32'd4;
    wire [31:0] branch_target = current_pc + imm_ext;

    assign next_pc = pc_src ? branch_target : pc_plus_4;

    // Reset & Clock division
    wire slow_clk;
    wire rst = ~reset;

    clock_divider uut_clkdiv (
        .clk_in(clk),
        .reset(rst),
        .clk_out(slow_clk)
    );

    // --- Memory-Mapped I/O Logic for UART ---
    // Address 0x00000040 is reserved for UART TX
    wire is_uart_addr = (alu_result == 32'h00000040);
    
    // Only write to DMEM if it's NOT a UART access
    wire dmem_we = mem_write & (~is_uart_addr);

    // Edge detector: detects the exact rising edge of slow_clk
    reg slow_clk_d;
    always @(posedge clk) begin
        slow_clk_d <= slow_clk;
    end
    wire slow_clk_pulse = (slow_clk & ~slow_clk_d);

    // Trigger UART only once when executing sw to 0x40
    wire uart_start = mem_write & is_uart_addr & slow_clk_pulse;
    wire uart_busy;

    // 1. Program Counter
    pc uut_pc (
        .clk(slow_clk),
        .reset(rst),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    // 2. Instruction Memory
    imem uut_imem (
        .pc_address(current_pc),
        .instruction(instruction)
    );

    // 3. Immediate Generator
    imm_gen uut_imm (
        .instruction(instruction),
        .imm_ext(imm_ext)
    );

    // 4. Control Unit
    control_unit uut_control (
        .instruction(instruction),
        .reg_write(reg_write),
        .alu_control(alu_control),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch)
    );

    // 5. Register File
    regfile uut_regfile (
        .clk(slow_clk),
        .we(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(write_back_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    // 6. ALU
    alu uut_alu (
        .a(rd1),
        .b(alu_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

    // 7. Data Memory (Write Enable gated by MMIO)
    dmem uut_dmem (
        .clk(slow_clk),
        .we(dmem_we),
        .address(alu_result),
        .wd(rd2),
        .rd(dmem_rd)
    );

    // 8. UART Transmitter (Runs on fast 27MHz clock)
    uart_tx uut_uart (
        .clk(clk),
        .reset(rst),
        .tx_start(uart_start),
        .tx_data(rd2[7:0]), // Transmit lower byte of rs2
        .tx(uart_tx),
        .tx_busy(uart_busy)
    );

    // Show current instruction word on LEDs
    assign led = ~current_pc[7:2];

endmodule