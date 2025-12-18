module pwm_generator #(
  parameter TIMER_RESOLUTION = 32
) (
  input                             clk,
  input                             rst_n,
  input                             start,
  input                             stop,
  input      [                 1:0] mode,
  input      [TIMER_RESOLUTION-1:0] psc,    // clk_cnt = clk / [pcs+1]
  input      [TIMER_RESOLUTION-1:0] arr,
  input      [TIMER_RESOLUTION-1:0] ccr0,
  output reg                        oc0
);

  localparam RIGHT_ALIGNED = 2'd0;
  localparam LEFT_ALIGNED = 2'd1;
  localparam CENTER_ALIGNED = 2'd2;

  localparam IDLE = 2'd0;
  localparam LOADING = 2'd1;
  localparam WORKING = 2'd2;
  localparam STOPPED = 2'd3;

  reg [1:0] state, next_state;

  reg [TIMER_RESOLUTION-1:0] arr_shadow;
  reg [TIMER_RESOLUTION-1:0] ccr0_shadow;
  reg [TIMER_RESOLUTION-1:0] clk_cnt;
  reg [TIMER_RESOLUTION-1:0] cnt;
  reg                        cnt_inc_dec_b;

  always @(*) begin
    case (state)
      IDLE: oc0 = 0;
      WORKING: begin
        case (mode)
          RIGHT_ALIGNED: begin
            oc0 = cnt >= ccr0_shadow;
          end
          LEFT_ALIGNED: begin
            oc0 = cnt < ccr0_shadow;
          end
          CENTER_ALIGNED: begin
            oc0 = cnt < ccr0_shadow;
            if (cnt == arr_shadow - 1) cnt_inc_dec_b = 0;
            if (cnt == 0) cnt_inc_dec_b = 1;
          end
        endcase
      end
    endcase
  end

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        clk_cnt       <= 0;
        cnt           <= 0;
        cnt_inc_dec_b <= 1;
        oc0           <= 0;
        arr_shadow    <= 0;
        ccr0_shadow   <= 0;
      end
      LOADING: begin
        arr_shadow  <= arr;
        ccr0_shadow <= ccr0;
      end
      WORKING: begin
        if (cnt == 0) begin
          arr_shadow  <= arr;
          ccr0_shadow <= ccr0;
        end

        clk_cnt <= clk_cnt + 1;
        if (clk_cnt >= psc) begin
          clk_cnt <= 0;

          if (cnt_inc_dec_b) begin
            cnt <= cnt + 1;
            if (cnt >= arr_shadow - 1) cnt <= 0;
          end else begin
            cnt <= cnt - 1;
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
