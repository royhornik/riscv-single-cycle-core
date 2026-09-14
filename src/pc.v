// 3. Program Counter (PC) Module
module pc (
    input             clk,         // Clock signal
    input             reset,       // Reset signal to start from address 0
    input      [31:0] next_pc,     // The next address to jump to
    output reg [31:0] current_pc   // The current execution address
);

    // Update the PC on the positive edge of the clock
    always @(posedge clk) begin
        if (reset) begin
            current_pc <= 32'b0;   // If reset is high, go to address 0
        end else begin
            current_pc <= next_pc; // Otherwise, move to the next address
        end
    end

endmodule