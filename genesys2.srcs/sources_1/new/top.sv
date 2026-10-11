module top (
    input  logic sysclk_p,
    input  logic sysclk_n,
    output logic led_o,
    output logic uart_rx_o
);
  logic clk;

  IBUFDS u_clk_buf (
      .I (sysclk_p),
      .IB(sysclk_n),
      .O (clk)
  );

  // Flashing LED for debugging
  Blinky blinky (
      .clk_i(clk),
      .led_o(led_o)
  );

  // FPGA -> PC link
  //   UART_tx #(
  //       .SYSCLK_F(200e6),
  //       .BAUDRATE(115200)
  //   ) get_tx (
  //       .clk_i(clk),
  //       .tx_o (uart_rx_o)
  //   );
endmodule
