module UART_tx #(
    parameter int SYSCLK_F = 200_000_000,
    parameter int BAUDRATE = 115200
) (
    input logic clk_i,
    input logic start_i,
    input logic [7:0] tx_buf_i,
    output logic tx_o,
    output logic done_o
);

  localparam int CycPerBit = SYSCLK_F / BAUDRATE;

  typedef enum {
    IDLE,
    START,
    DATA,
    STOP,
    CLEANUP
  } state_t;

  state_t state = IDLE;
  logic [$clog2(CycPerBit+1)-1:0] cyc_cnt = '0;  // number of cycles spend in state
  logic [7:0] buf_idx = '0;  // idx of bit in tx_buf to put on the line

  always_ff @(posedge clk_i) begin
    case (state)
      IDLE: begin
        tx_o <= '1;
        done_o <= '0;
        cyc_cnt <= '0;
        buf_idx <= '0;

        if (start_i) begin
          cyc_cnt <= '0;
          state   <= START;
        end
      end

      START: begin
        if (cyc_cnt < CycPerBit) begin
          tx_o <= '0;
          cyc_cnt <= cyc_cnt + 1;
        end else begin
          cyc_cnt <= 0;
          state   <= DATA;
        end
      end

      DATA: begin
        if (buf_idx < 8) begin
          if (cyc_cnt < CycPerBit) begin
            tx_o <= tx_buf_i[buf_idx];
            cyc_cnt <= cyc_cnt + 1;
          end else begin
            cyc_cnt <= '0;
            buf_idx <= buf_idx + 1;
          end
        end else begin
          cyc_cnt <= 0;
          state   <= STOP;
        end
      end

      STOP: begin
        if (cyc_cnt < CycPerBit) begin
          tx_o <= '1;
          cyc_cnt <= cyc_cnt + 1;
        end else begin
          state <= CLEANUP;
        end
      end

      CLEANUP: begin
        done_o <= '1;
        state  <= IDLE;
      end

      default: begin
        state <= IDLE;
      end
    endcase
  end
endmodule
