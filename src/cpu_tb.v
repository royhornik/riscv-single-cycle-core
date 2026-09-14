`timescale 1ns / 1ps

module cpu_tb;

    reg clk;
    reg reset;
    wire uart_tx;
    wire [5:0] led;

    // Instantiate CPU top module
    cpu uut (
        .clk(clk),
        .reset(reset),
        .uart_tx(uart_tx),
        .led(led)
    );

    // Generate 27MHz clock (period ~37ns)
    always #18.5 clk = ~clk;

    integer errors = 0;

    // Verification task to check register value
    task check_reg;
        input [4:0] reg_num;
        input [31:0] expected_val;
        input [127:0] test_name;
        reg [31:0] actual_val;
        begin
            // FIXED PATH: uut_regfile instead of rf
            actual_val = uut.uut_regfile.registers[reg_num];
            if (actual_val === expected_val) begin
                $display("[PASS] %-12s | x%-2d = %0d", test_name, reg_num, actual_val);
            end else begin
                $display("[FAIL] %-12s | x%-2d = %0d (Expected: %0d)", test_name, reg_num, actual_val, expected_val);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 0; // Assert reset (because rst = ~reset in cpu.v)

        #100;
        reset = 1; // De-assert reset (rst becomes 0, CPU starts running)

        // Wait 2000ns for instructions to finish
        #2000;

        $display("\n==========================================");
        $display("   STARTING SELF-CHECKING VERIFICATION    ");
        $display("==========================================");

        check_reg(1,  32'd10, "ADDI (x1)");
        check_reg(2,  32'd20, "ADDI (x2)");
        check_reg(3,  32'd30, "ADD");
        check_reg(4,  32'd10, "SUB");
        check_reg(5,  32'd0,  "AND");
        check_reg(6,  32'd30, "OR");
        check_reg(7,  32'd1,  "SLT");
        check_reg(8,  32'd30, "SW and LW");
        check_reg(9,  32'd0,  "BEQ SKIP");
        check_reg(10, 32'd1,  "BEQ TARGET");

        $display("------------------------------------------");
        if (errors == 0) begin
            $display(">>> ALL TESTS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> FAILED WITH %0d ERROR(S) <<<", errors);
        end
        $display("==========================================\n");

        $finish;
    end

endmodule
