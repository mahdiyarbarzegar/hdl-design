`timescale 1ns/10ps

module tb_ripple_carry_adder;

parameter BUS_WIDTH = 32;

reg [BUS_WIDTH-1:0] a;
reg [BUS_WIDTH-1:0] b;
wire [BUS_WIDTH-1:0] y;

ripple_carry_adder #(
    .BUS_WIDTH  (BUS_WIDTH)
) rca (
    .in1    (a),
    .in2    (b),
    .out    (y)
);

initial begin
    a = 'd12; b = 'd24;
    #1;
    $display("in1: %d, in2: %d -> sum: %d", a, b, y);
    if (y != 'd36) begin
        $display("wrong result!");
    end else begin
        $display("successfull result!");
    end

    $finish;
end

endmodule
