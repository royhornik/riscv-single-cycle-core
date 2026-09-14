// NEW: Clock Divider (Accelerated ~10x)
module clock_divider (
    input clk_in,
    input reset,
    output reg clk_out
);
    reg [24:0] counter;
    
    always @(posedge clk_in) begin
        if (reset) begin
            counter <= 25'b0;
            clk_out <= 1'b0;
        end else if (counter == 25'd1_350_000) begin // 10x faster (10 Hz)
            counter <= 25'b0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule