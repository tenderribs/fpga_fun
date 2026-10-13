module UART_rx #(
    parameter int SYSCLK_F,
    parameter int BAUDRATE
) (
    input logic clk_i,
    input logic rx_raw_i,
    output logic [7:0] rx_buf_o,
    output logic done_o
);


  typedef enum {
    IDLE,
    START,
    SAMPLING,
    OUTPUT
  } state_t;

  state_t state = IDLE;

  localparam int ClkPerBaud = SYSCLK_F / BAUDRATE;
  localparam int ClkPerHalfBaud = ClkPerBaud / 2;

  logic [$clog2(2*ClkPerBaud+1)-1:0] cyc_cnt = '0;  // space to count cycles through two bauds

  // 2-FF synchronizer
  logic [1:0] rx_sync_buf = '1;
  logic rx_sync;
  assign rx_sync = rx_sync_buf[1];

  logic [$clog2(8+1)-1:0] buf_idx = '0;

  always_ff @(posedge clk_i) begin
    rx_sync_buf <= {rx_sync_buf[0], rx_raw_i};

    case (state)
      IDLE: begin
        cyc_cnt <= '0;
        done_o  <= '0;
        if (~rx_sync) begin  // TX started
          state <= START;
        end
      end
      START: begin
        cyc_cnt <= cyc_cnt + 1;

        if (cyc_cnt >= ClkPerHalfBaud) begin
          if (~rx_sync) begin  // confirm is real TX start
            state   <= SAMPLING;
            cyc_cnt <= '0;
            buf_idx <= '0;
          end else begin
            state <= IDLE;
          end
        end
      end
      SAMPLING: begin
        cyc_cnt <= cyc_cnt + 1;

        if (buf_idx < 8) begin
          if (cyc_cnt >= ClkPerBaud) begin  // sample the line in the middle
            rx_buf_o[buf_idx] <= rx_sync;

            cyc_cnt <= '0;
            buf_idx <= buf_idx + 1;
          end
        end else begin
          state   <= OUTPUT;
          cyc_cnt <= '0;
        end
      end
      OUTPUT: begin
        cyc_cnt <= cyc_cnt + 1;

        if (cyc_cnt >= ClkPerBaud) begin
          done_o <= rx_sync;
          state  <= IDLE;
        end
      end
      default: state <= IDLE;
    endcase

  end
endmodule
