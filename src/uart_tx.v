module uart_tx (
    input            clk,       // Fast system clock (27MHz)
    input            reset,     // Active-high synchronous reset
    input            tx_start,  // Trigger pulse to initiate transmission
    input      [7:0] tx_data,   // 8-bit data payload to transmit
    output reg       tx,        // Physical serial output line
    output           tx_busy    // 1 while transmitting, 0 when idle/ready
);

    // Baud rate timing parameter (27MHz / 115200 baud ≈ 234 clock cycles)
    localparam CLKS_PER_BIT = 234;

    // State machine encodings
    localparam STATE_IDLE  = 2'b00;
    localparam STATE_START = 2'b01;
    localparam STATE_DATA  = 2'b10;
    localparam STATE_STOP  = 2'b11;

    reg [1:0] state;
    reg [7:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    // Module is busy whenever it is not in the IDLE state
    assign tx_busy = (state != STATE_IDLE);

    always @(posedge clk) begin
        if (reset) begin
            state     <= STATE_IDLE;
            tx        <= 1'b1; // UART idle state is logic high
            clk_count <= 8'd0;
            bit_index <= 3'd0;
            data_reg  <= 8'd0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    tx        <= 1'b1;
                    clk_count <= 8'd0;
                    bit_index <= 3'd0;
                    if (tx_start) begin
                        data_reg <= tx_data; // Latch incoming data
                        state    <= STATE_START;
                    end
                end

                STATE_START: begin
                    tx <= 1'b0; // Drive line low for the Start bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 8'd0;
                        state     <= STATE_DATA;
                    end
                end

                STATE_DATA: begin
                    tx <= data_reg[bit_index]; // Transmit current data bit (LSB first)
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 8'd0;
                        if (bit_index < 3'd7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= 3'd0;
                            state     <= STATE_STOP;
                        end
                    end
                end

                STATE_STOP: begin
                    tx <= 1'b1; // Drive line high for the Stop bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 8'd0;
                        state     <= STATE_IDLE; // Packet complete, return to idle
                    end
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule