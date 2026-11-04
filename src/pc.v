// 3. Program Counter (PC) Module
module pc (
    input             clk,         // Clock signal (on the board: the slow clock)
    input             reset,       // Reset signal, active high. ASYNCHRONOUS (see note below)
    input      [31:0] next_pc,     // The next address to jump to
    output reg [31:0] current_pc   // The current execution address
);

    // Asynchronous reset: "or posedge reset" lets the reset act immediately.
    // On the board the divided clock is held low while the reset button is pressed,
    // so a synchronous reset would never see a clock edge and would never reset the PC.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_pc <= 32'b0;   // If reset is high, go to address 0
        end else begin
            current_pc <= next_pc; // Otherwise, move to the next address
        end
    end

endmodule