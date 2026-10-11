module top (
    input logic sysclk_p,
    input logic sysclk_n,
    input logic btnc,
    output logic [1:0] led_o,
    output logic uart_rx_o
);
  localparam int SysClkF = 200e6;  // 10 ms at 200 MHz

  logic clk;
  logic btnc_pulse;
  logic [7:0] tx_buf = 8'd65;  // char 'A'

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

  // Convert push button to pulse
  BtnPulse #(
      .SYSCLK_F(SysClkF)
  ) btn_pulse (
      .clk_i  (clk),
      .btn_i  (btnc),
      .pulse_o(btnc_pulse)
  );

  // FPGA -> PC link
  UART_tx #(
      .SYSCLK_F(SysClkF)
  ) get_tx (
      .clk_i(clk),
      .tx_buf_i(tx_buf),
      .start_i(btnc_pulse),
      .tx_o(uart_rx_o)
  );

  assign led_o[1] = btnc;
endmodule
