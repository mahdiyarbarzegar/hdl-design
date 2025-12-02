module restoring_divider #(
  parameter DIV_WIDTH = 32
) (
  input                      clk,
  input                      rst_n,
  input                      start,
  input                      sign,
  input      [DIV_WIDTH-1:0] in1,
  input      [DIV_WIDTH-1:0] in2,
  output     [DIV_WIDTH-1:0] q,
  output     [DIV_WIDTH-1:0] r,
  output reg                 ready
);

  localparam IDLE = 'd0, STARTING = 'd1, LOADING = 'd2, RUNNING = 'd3;

  wire [  DIV_WIDTH:0] in1_data;
  wire [  DIV_WIDTH:0] in2_data;
  reg  [  DIV_WIDTH:0] a_reg;
  reg  [  DIV_WIDTH:0] b_reg;
  reg  [DIV_WIDTH-1:0] q_cnt;
  wire [  DIV_WIDTH:0] a_mux;
  wire [  DIV_WIDTH:0] sub;
  wire in1_sign, in2_sign;
  wire sub_sign;

  reg [1:0] state, next_state;
  reg a_sel;
  reg a_reg_en, b_reg_en;
  wire add_sub;
  reg q_cnt_en, q_cnt_rst;
  wire q_neg;
  reg  stop;

  assign in1_data = (sign) ? {in1[DIV_WIDTH-1], in1} : {1'b0, in1};
  assign in2_data = (sign) ? {in2[DIV_WIDTH-1], in2} : {1'b0, in2};
  assign a_mux    = a_sel ? in1_data : sub;
  assign sub      = add_sub ? (a_reg + b_reg) : (a_reg - b_reg);
  assign in1_sign = in1_data[DIV_WIDTH];
  assign in2_sign = in2_data[DIV_WIDTH];
  assign sub_sign = sub[DIV_WIDTH];
  assign q        = q_neg ? ~(q_cnt) + 1 : q_cnt;
  assign r        = a_reg[DIV_WIDTH-1:0];

  always @(posedge clk) begin
    if (a_reg_en) a_reg <= a_mux;
    if (b_reg_en) b_reg <= in2_data;
    if (q_cnt_en) q_cnt <= q_cnt + 1;
    if (q_cnt_rst) q_cnt <= 'd0;

    if (rst_n == 'b0) begin
      a_reg <= 0;
      b_reg <= 0;
      q_cnt <= 0;
    end
  end

  assign add_sub = (sign) ? (in1_sign ^ in2_sign) : 'b0;
  assign q_neg   = (sign) ? (in1_sign ^ in2_sign) : 'b0;

  always @(*) begin
    case (state)
      IDLE: begin
        stop      = 1;
        ready     = 1;
        a_sel     = 0;
        a_reg_en  = 0;
        b_reg_en  = 0;
        q_cnt_rst = 0;
        q_cnt_en  = 0;
      end
      STARTING: begin
        q_cnt_rst = 1;
        ready     = 0;
      end
      LOADING: begin
        a_sel     = 1;
        a_reg_en  = 1;
        b_reg_en  = 1;
        q_cnt_rst = 0;
      end
      RUNNING: begin
        b_reg_en = 0;
        a_sel    = 0;
        stop     = (sign) ? (in1_sign ^ sub_sign) : sub_sign;
        ready    = stop;
        q_cnt_en = ~stop;
        a_reg_en = ~stop;
      end
    endcase
  end

  always @(posedge clk) begin
    state <= next_state;

    if (rst_n == 'b0) begin
      state <= IDLE;
    end
  end

  always @(*) begin
    next_state = state;
    case (state)
      IDLE: begin
        if (start) next_state = STARTING;
      end
      STARTING: begin
        if (start == 'b0) next_state = LOADING;
      end
      LOADING: begin
        next_state = RUNNING;
      end
      RUNNING: begin
        if (ready) next_state = IDLE;
      end
    endcase
  end

endmodule
