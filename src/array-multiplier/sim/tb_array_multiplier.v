`timescale 1ns / 10ps

module tb_array_multiplier;

  parameter MUL_SIZE = 8;

  reg  [  MUL_SIZE-1:0] a;
  reg  [  MUL_SIZE-1:0] b;
  wire [2*MUL_SIZE-1:0] y;

  array_multiplier #(
    .MUL_WIDTH(MUL_SIZE)
  ) mul (
    .a_in (a),
    .b_in (b),
    .m_out(y)
  );

  initial begin
    a = 'd40;
    b = 'd50;
    #1;
    $display("a: %d, b: %d -> a*b: %d", a, b, y);
    if (y != (a * b)) begin
      $display("wrong result!");
    end else begin
      $display("successfull result!");
    end

    $finish;
  end

endmodule
