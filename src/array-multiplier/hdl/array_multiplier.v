module array_multiplier #(
  parameter MUL_WIDTH = 4
) (
  input  [  MUL_WIDTH-1:0] a_in,
  input  [  MUL_WIDTH-1:0] b_in,
  output [2*MUL_WIDTH-1:0] m_out
);

  wire [  MUL_WIDTH-1:0] a[MUL_WIDTH:0];
  wire [  MUL_WIDTH-1:0] b[MUL_WIDTH:0];
  wire [  MUL_WIDTH-1:0] c[MUL_WIDTH:0];
  wire [2*MUL_WIDTH-1:0] p[MUL_WIDTH:0];

  assign a[0] = a_in;
  assign b[0] = b_in;
  assign c[0] = {MUL_WIDTH{1'b0}};
  assign p[0] = {(2 * MUL_WIDTH - 1) {1'b0}};

  genvar i, j;
  generate
    for (i = 0; i < MUL_WIDTH; i = i + 1) begin : mul_row
      for (j = 0; j < MUL_WIDTH; j = j + 1) begin : mul_col
        mul_slice mul (
          .ai(a[j][i]),
          .bi(b[i][j]),
          .pi(p[i][i+j]),
          .ci(c[j][i]),
          .ao(a[j+1][i]),
          .bo(b[i+1][j]),
          .po(p[i+1][i+j]),
          .co(c[j+1][i])
        );
      end

      assign p[i+1][MUL_WIDTH+i] = c[MUL_WIDTH][i];
      assign m_out[i]            = p[i+1][i];

    end

    assign m_out[2*MUL_WIDTH-1:MUL_WIDTH] = p[MUL_WIDTH][2*MUL_WIDTH-1:MUL_WIDTH];

  endgenerate

endmodule
