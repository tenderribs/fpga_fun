module top (
    input logic sysclk_p,
    input logic sysclk_n,
    input logic btnc,
    output logic [1:0] led_o,
    output logic uart_rx_o
);
  logic clk;

  IBUFDS u_clk_buf (
      .I (sysclk_p),
      .IB(sysclk_n),
      .O (clk)
  );

  // LED for debugging
  Blinky blinky (
      .clk_i(clk),
      .led_o(led_o[0])
  );

  // debounced one-shot push button circuit
  localparam int DbncCycles = 2_000_000;  // 10 ms at 200 MHz
  logic [1:0] btnc_sync = '0;
  logic [$clog2(DbncCycles+1)-1:0] debounce_cnt = '0;
  logic btnc_pulse = '0;

  always_ff @(posedge clk) begin
    btnc_sync  <= {btnc_sync[0], btnc};  // 2-FF synchronizer
    btnc_pulse <= '0;

    if (!btnc_sync[1]) begin
      debounce_cnt <= '0;
    end else if (debounce_cnt < DbncCycles) begin
      debounce_cnt <= debounce_cnt + 1;
      btnc_pulse   <= (debounce_cnt == DbncCycles - 1);
    end
  end


  // FPGA -> PC link
  UART_tx get_tx (
      .clk_i(clk),
      .start_i(btnc_pulse),
      .tx_o(uart_rx_o)
  );

  assign led_o[1] = btnc;
endmodule
