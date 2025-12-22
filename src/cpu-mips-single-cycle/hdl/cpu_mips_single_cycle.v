//===========================================================
//
//	Mahdiyar Barzegar & 99205231
//
//	Implemented Instructions are:
//	R format:  add(u), sub(u), and, or, xor, nor, slt, sltu;
//	I format:  beq, bne, lw, sw, addiu, slti, sltiu, andi, ori, xori, lui.
//
//===========================================================

`timescale 1ns / 1ns

module single_cycle_mips (
  input clk,
  input reset
);

  initial begin
    $display("Single Cycle MIPS Implemention");
    $display("Mahdiyar Barzegar & 99205231");
  end

  reg  [31:0] PC;  // Keep PC as it is, its name is used in higher level test bench

  // YOUR DESIGN COMES HERE
  // Sign Extender ===========================================
  wire [31:0] SignImm;
  assign SignImm = (CU.SignExtend)? {{16{imem.read_data[15]}},imem.read_data[15:0]}
				  :{16'h0000,imem.read_data[15:0]};

  // PC Register =============================================
  wire PCSrc;
  wire [31:0] PCPlus4, PCBranch, nxt_PC;
  assign PCSrc    = (CU.Branch_e & alu.Zero) | (CU.Branch_n & (~alu.Zero));
  assign PCPlus4  = PC + 4;
  assign PCBranch = PCPlus4 + (SignImm << 2);
  assign nxt_PC   = (PCSrc) ? PCBranch : PCPlus4;

  always @(posedge clk) begin
    if (reset) PC <= 32'h00000000;
    else PC <= nxt_PC;
  end

  // Register File ===========================================
  wire [31:0] Result;
  wire [ 4:0] WriteReg;
  assign Result   = (CU.MemToReg) ? dmem.read_data : alu.ALUResult;
  assign WriteReg = (CU.RegDst) ? (imem.read_data[15:11]) : (imem.read_data[20:16]);

  // ALU =====================================================
  wire [31:0] SrcB;
  assign SrcB = (CU.ALUSrc) ? SignImm : regFile.RD2;

  //========================================================== 
  //	instantiated modules
  //========================================================== 
  // MIPS Controller
  MIPS_Controller CU (
    .Opcode    (imem.read_data[31:26]),
    .funct     (imem.read_data[5:0]),
    .MemToReg  (),
    .MemWrite  (),
    .Branch_e  (),
    .Branch_n  (),
    .ALUSrc    (),
    .RegDst    (),
    .RegWrite  (),
    .SignExtend(),
    .ALUCTRL   ()
  );

  // Instruction Memory
  async_mem imem  // keep the exact instance name
  (
    .clk       (1'b0),
    .write     (1'b0),          // no write for instruction memory
    .address   (PC),            // address instruction memory with pc
    .write_data(32'hxxxxxxxx),
    .read_data ()
  );

  // Data Memory
  async_mem dmem  // keep the exact instance name
  (
    .clk       (clk),
    .write     (CU.MemWrite),
    .address   (alu.ALUResult),
    .write_data(regFile.RD2),
    .read_data ()
  );

  reg_file regFile (
    .clk  (clk),
    .write(CU.RegWrite),
    .WR   (WriteReg),
    .WD   (Result),
    .RR1  (imem.read_data[25:21]),
    .RR2  (imem.read_data[20:16]),
    .RD1  (),
    .RD2  ()
  );

  ALU alu (
    .A        (regFile.RD1),
    .B        (SrcB),
    .Op       (CU.ALUCTRL),
    .ALUResult(),
    .Zero     ()
  );

endmodule

