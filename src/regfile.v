// 2. Register File
module regfile (
    input         clk,         // Clock signal
    input         we,          // Write Enable - allows writing when high
    input  [4:0]  rs1,         // Source register 1 address (5 bits = 32 options)
    input  [4:0]  rs2,         // Source register 2 address
    input  [4:0]  rd,          // Destination register address for writing
    input  [31:0] wd,          // Write Data to be stored
    output [31:0] rd1,         // Read Data from source register 1
    output [31:0] rd2          // Read Data from source register 2
);

    // Create an array of 32 registers, each 32 bits wide
    reg [31:0] registers [0:31];

    // Asynchronous read:
    // If address is 0, always output 0. Otherwise, output register value.
    assign rd1 = (rs1 != 0) ? registers[rs1] : 32'b0;
    assign rd2 = (rs2 != 0) ? registers[rs2] : 32'b0;

    // Synchronous write: occurs only on the positive edge of the clock
    always @(posedge clk) begin
        // Write only if Write Enable is high and destination is not x0
        if (we && rd != 0) begin
            registers[rd] <= wd; 
        end
    end

endmodule