`timescale 1ns/10ps

module tb_carry_look_ahead_adder;

parameter ADDER_SIZE = 32;
parameter CLA_BLOCK_SIZE = 4;

reg [ADDER_SIZE-1:0] a;
reg [ADDER_SIZE-1:0] b;
wire [ADDER_SIZE-1:0] sum;

carry_look_ahead_adder #(
    .BUS_WIDTH          (ADDER_SIZE),
    .CLA_BLOCK_WIDTH    (CLA_BLOCK_SIZE)
) cla (
    .in1    (a),
    .in2    (b),
    .out    (sum)
);

initial begin
    a = 'd12; b = 'd16;
    #1;
    $display("in1: %d, in2: %d -> sum: %d", a, b, sum);
    if (sum != 'd28) begin
        $display("wrong result!");
    end else begin
        $display("successfull result!");
    end

    $finish;
end

endmodule