`timescale 1ns / 10ps

module tb_ripple_carry_adder;

  parameter BUS_WIDTH = 32;

  reg                  add_sub_b;
  reg  [BUS_WIDTH-1:0] a;
  reg  [BUS_WIDTH-1:0] b;
  wire [BUS_WIDTH-1:0] y;

  ripple_carry_adder #(
    .BUS_WIDTH(BUS_WIDTH)
  ) rca (
    .add_sub_b(add_sub_b),
    .in1      (a),
    .in2      (b),
    .out      (y)
  );

  initial begin
    add_sub_b = 'b0;
    a         = 'd12;
    b         = 'd24;
    #1;
    $display("in1: %d, in2: %d -> in1 + in2: %d", a, b, y);
    if (y != 'd36) begin
      $display("wrong result!");
    end else begin
      $display("successfull result!");
    end

    add_sub_b = 'b1;
    a         = 'd110;
    b         = 'd24;
    #1;
    $display("in1: %d, in2: %d -> in1 - in2: %d", a, b, y);
    if (y != 'd86) begin
      $display("wrong result!");
    end else begin
      $display("successfull result!");
    end

    $finish;
  end

endmodule
