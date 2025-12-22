`timescale 1ns / 1ns

module tb_isort_cpu_mips;

  reg clk = 1;
  always @(clk) clk <= #5 ~clk;

  reg reset;
  initial begin
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    #1;
    reset = 0;
  end

  reg [ 8:0] err_exp = 0;
  reg [ 8:0] err_unsorted = 0;
  reg [31:0] exp_sorted_num   [0:95];

  initial begin
    $readmemh("../../src/cpu-mips-single-cycle/sim/tb_isort_data/isort32.hex", cpu.imem.mem_data);
  end

  initial begin
    $readmemh("../../src/cpu-mips-single-cycle/sim/tb_isort_data/exp_sorted_numbers.hex",
              exp_sorted_num);
  end

  parameter end_pc = 32'h78;  // you might need to change end_pc

  integer i;
  always @(cpu.PC)
    if (cpu.PC == end_pc) begin
      for (i = 0; i < 96; i = i + 1) begin
        $write("%x ", cpu.dmem.mem_data[32+i]);
        if (((i + 1) % 16) == 0) $write("\n");
      end
      for (i = 0; i < 96; i = i + 1) begin
        if (cpu.dmem.mem_data[32+i] < cpu.dmem.mem_data[32+i+1] ||
					|cpu.dmem.mem_data[32+i] === 1'bx )
          err_unsorted = err_unsorted + 1;
        if (cpu.dmem.mem_data[32+i] !== exp_sorted_num[i]) err_exp = err_exp + 1;
      end

      if (err_unsorted) $write("\n\n\n %d Numbers are Not Sorted!!!!!!\n", err_unsorted);
      else $write("\n\n\n PASS1, All Sorted!\n");

      if (err_exp) $write("\n Bad!!!!! %d unexpected Numbers found:\n\n\n", err_exp);
      else $write("\n Pass2, Output Matches the expected Numbers!\n\n\n");

      $stop;
    end

  single_cycle_mips cpu (
    .clk  (clk),
    .reset(reset)
  );

endmodule
