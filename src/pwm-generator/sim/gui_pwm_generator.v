`timescale 1ns / 10ps

module gui_pwm_generator;

  localparam TIMER_RESOLUTION = 32;

  localparam RIGHT_ALIGNED = 2'd0;
  localparam LEFT_ALIGNED = 2'd1;
  localparam CENTER_ALIGNED = 2'd2;
  localparam VARIABLE_ALIGNED = 2'd3;

  reg clk, rst_n, start, stop;
  reg [1:0] mode;
  reg [TIMER_RESOLUTION-1:0] clk_div, cnt_top, cmp_0, cmp_1;
  wire pwm;

  pwm_generator #(
    .TIMER_RESOLUTION(TIMER_RESOLUTION)
  ) pwm_gen (
    .clk    (clk),
    .rst_n  (rst_n),
    .start  (start),
    .stop   (stop),
    .mode   (mode),
    .clk_div(clk_div),
    .cnt_top(cnt_top),
    .cmp_0  (cmp_0),
    .cmp_1  (cmp_1),
    .pwm_out(pwm)
  );

  initial begin
    clk = 'b1;
    while (1) begin
      #5 clk = ~clk;
    end
  end

  integer i;
  initial begin
    rst_n = 0;
    start = 0;
    stop  = 0;

    #10 rst_n = 1;
    #5 start = 1;
    mode    = CENTER_ALIGNED;
    clk_div = 1;
    cnt_top = 10;
    cmp_0   = 2;
    cmp_1   = 8;
    #20;
    start = 0;
    #100;

    for (i = 0; i < 10; i = i + 1) begin
      cmp_0 = i;
      #400;
    end
    for (i = 10; i > 0; i = i - 1) begin
      cmp_0 = i;
      #400;
    end

    $stop;
  end
endmodule
