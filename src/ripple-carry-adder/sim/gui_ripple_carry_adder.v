`timescale 1ns / 10ps

module gui_ripple_carry_adder;

  parameter BUS_WIDTH = 32;

  reg                  add_sub_b;
  reg  [BUS_WIDTH-1:0] a;
  reg  [BUS_WIDTH-1:0] b;
  wire [BUS_WIDTH-1:0] y;
  wire                 ovf;

  ripple_carry_adder #(
    .BUS_WIDTH(BUS_WIDTH)
  ) rca (
    .add_sub_b(add_sub_b),
    .in1      (a),
    .in2      (b),
    .out      (y),
    .ovf      (ovf)
  );

  initial begin
    add_sub_b = 'b1;
    a         = 'd110;
    b         = 'd24;
    #10;

    add_sub_b = 'b1;
    a         = 'd24;
    b         = 'd110;
    #10;

    $stop;
  end

endmodule
