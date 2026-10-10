module blinky (
    input logic sysclk_p,
    sysclk_n,
    output logic [0:0] led
);

  logic clk;

  IBUFDS u_clk_buf (
      .I (sysclk_p),
      .IB(sysclk_n),
      .O (clk)
  );

  logic [27:0] cnt = '0;

  always_ff @(posedge clk) begin
    cnt <= cnt + 1;
  end

  assign led = cnt[27];
endmodule
