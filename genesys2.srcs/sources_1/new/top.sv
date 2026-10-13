module top (
    input logic sysclk_p,
    input logic sysclk_n,
    input logic btnc,
    input logic uart_tx_i,
    output logic [1:0] led_o,
    output logic uart_rx_o
);
  localparam int SysClkF  = 200e6;   // 10 ms at 200 MHz
  localparam int BaudRate = 115200;

  logic clk;
  logic btnc_pulse;
  logic data_ready;
  logic [7:0] data_buf = '0;

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

  // PC -> FPGA
  UART_rx #(
      .SYSCLK_F(SysClkF),
      .BAUDRATE(BaudRate)
  ) uart_rx (
      .clk_i(clk),
      .rx_raw_i(uart_tx_i),
      .rx_buf_o(data_buf),
      .done_o(data_ready)
  );

  // FPGA -> PC
  UART_tx #(
      .SYSCLK_F(SysClkF),
      .BAUDRATE(BaudRate)
  ) uart_tx (
      .clk_i(clk),
      .start_i(data_ready),
      .tx_buf_i(data_buf),
      .tx_o(uart_rx_o)
  );

  assign led_o[1] = btnc;
endmodule
