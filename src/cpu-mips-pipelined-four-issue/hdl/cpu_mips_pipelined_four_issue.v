//
//	Mahdiyar Barzegar & 99205231
//
//	Implemented Instructions are:
//	R format:  add(u), sub(u), and, or, xor, nor, slt, sltu;
//	I format:  beq, bne, lw, sw, addiu, slti, sltiu, andi, ori, xori, lui.
//
//===========================================================

`timescale 1ns / 1ns

module fourIssue_mips (
  input clk,
  input reset
);

  initial begin
    $display("Four Issue ACA-MIPS Implemention");
    $display("Mahdiyar Barzegar & 99205231");
  end



  // =========================================== Stage 1 =========================================== //
  reg [31:0] PC, PC_F, PC_D;
  wire [31:0] PCPlus16, PCBranch, nxt_PC;
  wire PCSrc, PCEnable;
  wire [2:0] imem_fifo_WD;

  // Instruction Memory
  async_imem imem (
    .address  (PC),
    .read_data()
  );

  wire [31:0] D0, D1, D2, D3;
  wire [2:0] writeFiFo;

  assign D0 = (~(PC[3]|PC[2]))? imem.read_data[31:0] :
	    ((~PC[3])&PC[2])? imem.read_data[63:32]:
	    (PC[3]&(~PC[2]))? imem.read_data[95:64]: imem.read_data[127:96];

  assign D1 = (~(PC[3]|PC[2]))? imem.read_data[63:32]:
	    ((~PC[3])&PC[2])? imem.read_data[95:64]:
	    (PC[3]&(~PC[2]))? imem.read_data[127:96]: 31'd0;

  assign D2 = (~(PC[3]|PC[2]))? imem.read_data[95:64] :
	    ((~PC[3])&PC[2])? imem.read_data[127:96]: 31'd0;

  assign D3 = (~(PC[3] | PC[2])) ? imem.read_data[127:96] : 31'd0;

  assign writeFiFo = (~(PC[3]|PC[2]))? 3'd4 :
	           ((~PC[3])&PC[2])? 3'd3 :
	           (PC[3]&(~PC[2]))? 3'd2 : 3'd1;



  // FIFO Imem Buffer
  fifo_buffer imem_fifo (
    .clk     (clk),
    .reset   (reset | PCSrc),
    .In0     (D0),
    .In1     (D1),
    .In2     (D2),
    .In3     (D3),
    .RD      (Issue_Ctrl.fifo_ReadLine),
    .WR      (imem_fifo_WD),
    .Out0    (),
    .Out1    (),
    .Out2    (),
    .Out3    (),
    .capacity(),
    .empty   (),
    .full    ()
  );

  // Four Issue Data Selector
  FourIssueDataSelector FIDS (
    .D0           (imem_fifo.Out0),
    .D1           (imem_fifo.Out1),
    .D2           (imem_fifo.Out2),
    .D3           (imem_fifo.Out3),
    .D1_Brnach_Mem(Issue_Ctrl.I2_Branch_Mem),
    .D2_Brnach_Mem(Issue_Ctrl.I3_Branch_Mem),
    .D3_Brnach_Mem(Issue_Ctrl.I4_Branch_Mem),
    .I0_SEL       (Issue_Ctrl.DataSel_1),
    .I1_SEL       (Issue_Ctrl.DataSel_2),
    .I2_SEL       (Issue_Ctrl.DataSel_3),
    .I3_SEL       (Issue_Ctrl.DataSel_4),
    .I0           (),
    .I1           (),
    .I2           (),
    .I3           (),
    .I1_Branch_Act(),
    .I2_Branch_Act(),
    .I3_Branch_Act()
  );

  Issue_Controller Issue_Ctrl (
    .I1           (imem_fifo.Out0),
    .I2           (imem_fifo.Out1),
    .I3           (imem_fifo.Out2),
    .I4           (imem_fifo.Out3),
    .fifo_empty   (imem_fifo.empty),
    .fifo_ReadLine(),
    .DataSel_1    (),
    .DataSel_2    (),
    .DataSel_3    (),
    .DataSel_4    (),
    .I2_Branch_Mem(),
    .I3_Branch_Mem(),
    .I4_Branch_Mem(),
    .BranchPlusX  ()
  );

  // PC Register =============================================
  assign PCPlus16     = {PC[31:4], 4'b0000} + 16;
  assign nxt_PC       = (PCSrc) ? PCBranch : PCPlus16;
  assign PCEnable     = imem_fifo_WD || PCSrc;
  assign imem_fifo_WD = ((Issue_Ctrl.fifo_ReadLine + imem_fifo.capacity) >= 4) ? writeFiFo : 3'd0;


  always @(posedge clk) begin
    if (reset) PC <= 32'h00000000;
    else if (PCEnable) PC <= nxt_PC;
    else;
  end

  always @(posedge clk) begin
    if (reset) PC_F <= 32'h00000000;
    else if (PCSrc) PC_F <= 32'h00000000;
    else if (imem_fifo_WD) PC_F <= PC;
    else;
  end

  // =========================================== Stage 2 =========================================== //
  reg [31:0] I0_D, I1_D, I2_D, I3_D;
  reg I1_Branch_Act_D, I2_Branch_Act_D, I3_Branch_Act_D;
  reg  [3:0] BranchPlusX_D;
  wire       flush_D;
  wire [31:0] SrcA_0, SrcB_0, SignImm_0, WriteRegData_0;
  wire [4:0] WriteReg_0;
  wire       RegFile_Write_0;

  wire [31:0] SrcA_1, SrcB_1, SignImm_1, WriteRegData_1;
  wire [4:0] WriteReg_1;
  wire       RegFile_Write_1;

  wire [31:0] SignImm_2, MemReadAddress, WriteRegData_2;
  wire [4:0] WriteReg_2;
  wire       RegFile_Write_2;

  wire [31:0] SignImm_3, MemWriteAddress, MemWriteData;
  wire       Mem_Write_3;

  reg  [3:0] BranchCounter;

  always @(posedge clk) begin
    if (reset) begin
      I0_D            <= 0;
      I1_D            <= 0;
      I2_D            <= 0;
      I3_D            <= 0;
      I1_Branch_Act_D <= 0;
      I2_Branch_Act_D <= 0;
      I3_Branch_Act_D <= 0;
      PC_D            <= 32'h00000000;
      BranchPlusX_D   <= 0;
    end else if (~flush_D) begin
      I0_D            <= FIDS.I0;
      I1_D            <= FIDS.I1;
      I2_D            <= FIDS.I2;
      I3_D            <= FIDS.I3;
      I1_Branch_Act_D <= FIDS.I1_Branch_Act;
      I2_Branch_Act_D <= FIDS.I2_Branch_Act;
      I3_Branch_Act_D <= FIDS.I3_Branch_Act;
      PC_D            <= PC_F;
      BranchPlusX_D   <= (Issue_Ctrl.BranchPlusX + BranchCounter);
    end else begin
      I0_D            <= 0;
      I1_D            <= 0;
      I2_D            <= 0;
      I3_D            <= 0;
      I1_Branch_Act_D <= 0;
      I2_Branch_Act_D <= 0;
      I3_Branch_Act_D <= 0;
      PC_D            <= 32'h00000000;
      BranchPlusX_D   <= 0;
    end
  end

  always @(posedge clk) begin
    if (reset || imem_fifo_WD) BranchCounter <= 0;
    else begin
      BranchCounter <= BranchCounter + (Issue_Ctrl.fifo_ReadLine * 4);
    end
  end

  reg_file regFile (
    .clk(clk),

    .write1(RegFile_Write_0),
    .write2(RegFile_Write_1),
    .write3(RegFile_Write_2),

    .WR1(WriteReg_0),
    .WR2(WriteReg_1),
    .WR3(WriteReg_2),

    .WD1(WriteRegData_0),
    .WD2(WriteRegData_1),
    .WD3(WriteRegData_2),

    .RR1(I0_D[25:21]),
    .RR2(I0_D[20:16]),
    .RR3(I1_D[25:21]),
    .RR4(I1_D[20:16]),
    .RR5(I2_D[25:21]),
    .RR6(I3_D[25:21]),
    .RR7(I3_D[20:16]),

    .RD1(),
    .RD2(),
    .RD3(),
    .RD4(),
    .RD5(),
    .RD6(),
    .RD7()
  );

  MIPS_FourIssue_Controller CU (
    .I0(I0_D),
    .I1(I1_D),
    .I2(I2_D),
    .I3(I3_D),

    .ALUCTRL_0   (),
    .ALUSrc_0    (),
    .RegDst_0    (),
    .RegWrite_0  (),
    .SignExtend_0(),
    .Branch_e_0  (),
    .Branch_n_0  (),

    .ALUCTRL_1   (),
    .ALUSrc_1    (),
    .RegDst_1    (),
    .RegWrite_1  (),
    .SignExtend_1(),

    .MemToReg_2(),
    .RegWrite_2(),

    .MemWrite_3()
  );

  ALU alu0 (
    .A        (SrcA_0),
    .B        (SrcB_0),
    .Op       (CU.ALUCTRL_0),
    .ALUResult(),
    .Zero     ()
  );

  ALU alu1 (
    .A        (SrcA_1),
    .B        (SrcB_1),
    .Op       (CU.ALUCTRL_1),
    .ALUResult(),
    .Zero     ()
  );

  async_dmem dmem (
    .clk         (clk),
    .write       (Mem_Write_3),
    .addressRead (MemReadAddress),
    .addressWrite(MemWriteAddress),
    .write_data  (MemWriteData),
    .read_data   ()
  );

  assign SignImm_0 = (CU.SignExtend_0) ? {{16{I0_D[15]}}, I0_D[15:0]} : {16'h0000, I0_D[15:0]};
  assign SrcA_0 = regFile.RD1;
  assign SrcB_0 = (CU.ALUSrc_0) ? SignImm_0 : regFile.RD2;
  assign WriteReg_0 = (CU.RegDst_0) ? I0_D[15:11] : I0_D[20:16];
  assign WriteRegData_0 = alu0.ALUResult;
  assign PCBranch = PC_D + BranchPlusX_D + 4 + (SignImm_0 << 2);
  assign PCSrc = (CU.Branch_e_0 & alu0.Zero) | (CU.Branch_n_0 & (~alu0.Zero));
  assign flush_D = PCSrc;
  assign RegFile_Write_0 = CU.RegWrite_0;


  assign SignImm_1 = (CU.SignExtend_1) ? {{16{I1_D[15]}}, I1_D[15:0]} : {16'h0000, I1_D[15:0]};
  assign SrcA_1 = regFile.RD3;
  assign SrcB_1 = (CU.ALUSrc_1) ? SignImm_1 : regFile.RD4;
  assign WriteReg_1 = (CU.RegDst_1) ? I1_D[15:11] : I1_D[20:16];
  assign WriteRegData_1 = alu1.ALUResult;
  assign RegFile_Write_1 = CU.RegWrite_1 & (~(PCSrc & I1_Branch_Act_D));


  assign SignImm_2 = {{16{I2_D[15]}}, I2_D[15:0]};
  assign MemReadAddress = SignImm_2 + regFile.RD5;
  assign WriteReg_2 = I2_D[20:16];
  assign WriteRegData_2 = dmem.read_data;
  assign RegFile_Write_2 = CU.RegWrite_2 & (~(PCSrc & I2_Branch_Act_D));


  assign SignImm_3 = {{16{I3_D[15]}}, I3_D[15:0]};
  assign MemWriteAddress = SignImm_3 + regFile.RD6;
  assign MemWriteData = regFile.RD7;
  assign Mem_Write_3 = CU.MemWrite_3 & (~(PCSrc & I3_Branch_Act_D));



endmodule
























