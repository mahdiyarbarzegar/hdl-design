`timescale 1ns / 1ns

module tb_cpu_mips_pipelined;

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
    $readmemh("../../src/cpu-mips-pipelined/sim/data/isort32.hex", cpu.imem.mem_data);
  end

  initial begin
    $readmemh("../../src/cpu-mips-pipelined/sim/data/exp_sorted_numbers.hex", exp_sorted_num);
  end

  parameter end_pc = 32'h80;  // you might need to change end_pc

  integer        i;
  reg     [31:0] adr;
  real NumberOfHit, NumberOfLW;
  real HitRate;
  always @(cpu.PC) begin
    if (cpu.PC == end_pc) begin
      for (i = 0; i < 16; i = i + 1) begin
        if (cpu.Cache.cache_D[i] & cpu.Cache.cache_V[i]) begin
          adr                          = {i, 2'b00};
          adr                          = adr | (cpu.Cache.cache_tag[i] << 6);
          cpu.dmem.mem_data[adr[17:2]] = cpu.Cache.cache_data[i];
        end
      end
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

      $write("\n Number of LW: %d \n", NumberOfLW);
      $write("\n Number of Hit Cache: %d \n", NumberOfHit);
      HitRate = (NumberOfHit / NumberOfLW) * 100;
      $write("\n Cache Hit Rate: %3.2f%% \n\n", HitRate);

      $stop;
    end
  end

  always @(posedge cpu.clk) begin
    if (cpu.reset) begin
      NumberOfHit <= 0;
      NumberOfLW  <= 0;
    end else if (cpu.MemToRegM) begin
      if (~cpu.HU.lwDelaystall) NumberOfLW <= NumberOfLW + 1;
      if (cpu.Cache.Hit) begin
        NumberOfHit <= NumberOfHit + 1;
      end
    end else;
  end

  pipelined_mips cpu (
    .clk  (clk),
    .reset(reset)
  );

endmodule

