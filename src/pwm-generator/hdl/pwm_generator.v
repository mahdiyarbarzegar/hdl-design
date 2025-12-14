module pwm_generator #(
  parameter TIMER_RESOLUTION = 32
) (
  input                         clk,
  input                         rst_n,
  input                         start,
  input                         stop,
  input  [                 1:0] mode,
  input  [TIMER_RESOLUTION-1:0] clk_div,  // pwm_clk = clk / [clk_div+1]
  input  [TIMER_RESOLUTION-1:0] cnt_top,
  input  [TIMER_RESOLUTION-1:0] cmp_0,
  output                        pwm_out
);

  localparam RIGHT_ALIGNED = 2'd0;
  localparam LEFT_ALIGNED = 2'd1;
  localparam CENTER_ALIGNED = 2'd2;

  localparam IDLE = 2'd0;
  localparam LOADING = 2'd1;
  localparam WORKING = 2'd2;
  localparam STOPPED = 2'd3;

  reg [1:0] state, next_state;

  reg [TIMER_RESOLUTION-1:0] cmp_0_shadow, cmp_1_shadow;
  reg [TIMER_RESOLUTION-1:0] clk_cnt;
  reg [TIMER_RESOLUTION-1:0] pwm_cnt;
  reg                        pwm_cnt_inc_dec_b;
  reg                        pwm_ch;

  assign pwm_out = pwm_ch;

  always @(*) begin
    case (state)
      IDLE: pwm_ch = 0;
      WORKING: begin
        case (mode)
          RIGHT_ALIGNED: begin
            pwm_ch = pwm_cnt >= cmp_0_shadow;
          end
          LEFT_ALIGNED: begin
            pwm_ch = pwm_cnt < cmp_0_shadow;
          end
          CENTER_ALIGNED: begin
            pwm_ch = pwm_cnt < cmp_0_shadow;
            if (pwm_cnt == cnt_top - 1) pwm_cnt_inc_dec_b = 0;
            if (pwm_cnt == 0) pwm_cnt_inc_dec_b = 1;
          end
        endcase
      end
    endcase
  end

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        clk_cnt           <= 0;
        pwm_cnt           <= 0;
        pwm_cnt_inc_dec_b <= 1;
        pwm_ch            <= 0;
        cmp_0_shadow      <= 0;
      end
      LOADING: begin
        cmp_0_shadow <= cmp_0;
      end
      WORKING: begin
        if (pwm_cnt == 0) begin
          cmp_0_shadow <= cmp_0;
        end

        clk_cnt <= clk_cnt + 1;
        if (clk_cnt >= clk_div) begin
          clk_cnt <= 0;

          if (pwm_cnt_inc_dec_b) begin
            pwm_cnt <= pwm_cnt + 1;
            if (pwm_cnt >= cnt_top - 1) pwm_cnt <= 0;
          end else begin
            pwm_cnt <= pwm_cnt - 1;
          end
        end
      end
    endcase
  end

  always @(posedge clk) begin
    state <= next_state;
  end

  always @(*) begin
    case (state)
      IDLE:    if (start) next_state = LOADING;
      LOADING: if (start == 0) next_state = WORKING;
      WORKING: next_state = WORKING;
      STOPPED: next_state = STOPPED;
    endcase

    if (rst_n == 0) next_state = IDLE;
    if (stop) next_state = STOPPED;
  end

endmodule
