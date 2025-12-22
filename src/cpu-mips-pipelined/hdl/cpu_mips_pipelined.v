//
//	Mahdiyar Barzegar & 99205231
//
//	Implemented Instructions are:
//	R format:  add(u), sub(u), and, or, xor, nor, slt, sltu;
//	I format:  beq, bne, lw, sw, addiu, slti, sltiu, andi, ori, xori, lui.
//
//===========================================================

`timescale 1ns / 1ns

module pipelined_mips (
  input clk,
  input reset
);

  initial begin
    $display("Pipelined ACA-MIPS Implemention");
    $display("Mahdiyar Barzegar & 99205231");
  end



  // =========================================== Stage 1 =========================================== //
  reg [31:0] InstrD, PCPlus4D;
  reg  [31:0] PC;  // Keep PC as it is, its name is used in higher level test bench
  wire        PCSrcE;
  wire [31:0] PCPlus4F, PCBranchE, nxt_PC;
  // Instruction Memory
  async_imem imem  // keep the exact instance name
  (
    .clk       (1'b0),
    .write     (1'b0),          // no write for instruction memory
    .address   (PC),            // address instruction memory with pc
    .write_data(32'hxxxxxxxx),
    .read_data ()
  );

  // PC Register =============================================
  assign PCPlus4F = PC + 4;
  assign nxt_PC   = (PCSrcE) ? PCBranchE : PCPlus4F;

  always @(posedge clk) begin
    if (reset) PC <= 32'h00000000;
    else if (~HU.StallF) PC <= nxt_PC;
    else;
  end

  always @(posedge clk) begin
    if (reset) begin
      InstrD   <= 32'h00000000;
      PCPlus4D <= 32'h00000000;
    end else if ((~HU.StallD) && (~HU.FlushD)) begin
      InstrD   <= imem.read_data;
      PCPlus4D <= PCPlus4F;
    end else if (HU.StallD) begin
      InstrD   <= InstrD;
      PCPlus4D <= PCPlus4D;
    end else if (HU.FlushD) begin
      InstrD   <= 32'h00000000;
      PCPlus4D <= 32'h00000000;
    end else;
  end

  // =========================================== Stage 2 =========================================== //
  reg RegWriteE, MemToRegE, MemWriteE, ALUSrcE, RegDstE, Branch_eE, Branch_nE, RegWriteW;
  reg [3:0] ALUCTRLE;
  reg [31:0] RD1E, RD2E, SignImmE, PCPlus4E;
  reg [4:0] WriteRegW;
  reg [4:0] RsE, RtE, RdE;

  wire [31:0] ResultW;
  wire [31:0] SignImmD;
  wire [4:0] RsD, RtD, RdD;

  assign RsD = InstrD[25:21];
  assign RtD = InstrD[20:16];
  assign RdD = InstrD[15:11];
  // MIPS Controller
  MIPS_Controller CU (
    .Opcode    (InstrD[31:26]),
    .funct     (InstrD[5:0]),
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
  // MIPS Regiser File
  reg_file regFile (
    .clk  (clk),
    .write(RegWriteW),
    .WR   (WriteRegW),
    .WD   (ResultW),
    .RR1  (InstrD[25:21]),
    .RR2  (InstrD[20:16]),
    .RD1  (),
    .RD2  ()
  );

  // Sign Extender ===========================================
  assign SignImmD = (CU.SignExtend) ? {{16{InstrD[15]}}, InstrD[15:0]} : {16'h0000, InstrD[15:0]};

  always @(posedge clk) begin
    if (reset) begin
      RegWriteE <= 0;
      MemToRegE <= 0;
      MemWriteE <= 0;
      ALUSrcE   <= 0;
      RegDstE   <= 0;
      Branch_eE <= 0;
      Branch_nE <= 0;
      ALUCTRLE  <= 4'b0;
      RD1E      <= 31'd0;
      RD2E      <= 31'd0;
      SignImmE  <= 31'd0;
      PCPlus4E  <= 31'd0;
      RsE       <= 5'd0;
      RtE       <= 5'd0;
      RdE       <= 5'd0;
    end else if ((~HU.FlushE) && (~HU.StallE)) begin
      RegWriteE <= CU.RegWrite;
      MemToRegE <= CU.MemToReg;
      MemWriteE <= CU.MemWrite;
      ALUSrcE   <= CU.ALUSrc;
      RegDstE   <= CU.RegDst;
      Branch_eE <= CU.Branch_e;
      Branch_nE <= CU.Branch_n;
      ALUCTRLE  <= CU.ALUCTRL;
      RD1E      <= regFile.RD1;
      RD2E      <= regFile.RD2;
      SignImmE  <= SignImmD;
      PCPlus4E  <= PCPlus4D;
      RsE       <= RsD;
      RtE       <= RtD;
      RdE       <= RdD;
    end else if (HU.FlushE && (~HU.StallE)) begin
      RegWriteE <= 0;
      MemToRegE <= 0;
      MemWriteE <= 0;
      ALUSrcE   <= CU.ALUSrc;
      RegDstE   <= CU.RegDst;
      Branch_eE <= 0;
      Branch_nE <= 0;
      ALUCTRLE  <= CU.ALUCTRL;
      RD1E      <= regFile.RD1;
      RD2E      <= regFile.RD2;
      SignImmE  <= SignImmD;
      PCPlus4E  <= PCPlus4D;
      RsE       <= RsD;
      RtE       <= RtD;
      RdE       <= RdD;
    end else;
  end

  // =========================================== Stage 3 =========================================== //
  reg RegWriteM, MemToRegM, MemWriteM;
  reg [31:0] ALUOutM, WriteDataM;
  reg  [ 4:0] WriteRegM;
  wire [ 4:0] WriteRegE;
  wire [31:0] WriteDataE;
  wire [31:0] SrcAE, SrcBE;

  assign SrcAE = (HU.ForwardAE == 2'b00)? RD1E:
	       (HU.ForwardAE == 2'b01)? ResultW:
               (HU.ForwardAE == 2'b10)? ALUOutM: 32'h00000000;

  assign WriteDataE = (HU.ForwardBE == 2'b00)? RD2E:
	            (HU.ForwardBE == 2'b01)? ResultW:
	            (HU.ForwardBE == 2'b10)? ALUOutM: 32'h00000000;

  assign SrcBE = (ALUSrcE) ? SignImmE : WriteDataE;

  assign WriteRegE = (RegDstE) ? RdE : RtE;

  assign PCBranchE = PCPlus4E + (SignImmE << 2);

  assign PCSrcE = (Branch_eE & alu.Zero) | (Branch_nE & (~alu.Zero));
  // ALU =====================================================
  ALU alu (
    .A        (SrcAE),
    .B        (SrcBE),
    .Op       (ALUCTRLE),
    .ALUResult(),
    .Zero     ()
  );

  always @(posedge clk) begin
    if (reset) begin
      RegWriteM  <= 0;
      MemToRegM  <= 0;
      MemWriteM  <= 0;
      ALUOutM    <= 32'd0;
      WriteDataM <= 32'd0;
      WriteRegM  <= 5'b00000;
    end else if (~HU.StallM) begin
      RegWriteM  <= RegWriteE;
      MemToRegM  <= MemToRegE;
      MemWriteM  <= MemWriteE;
      ALUOutM    <= alu.ALUResult;
      WriteDataM <= WriteDataE;
      WriteRegM  <= WriteRegE;
    end else;
  end

  // =========================================== Stage 4 =========================================== //
  reg MemToRegW;
  reg [31:0] ReadDataW, ALUOutW;
  wire [31:0] ReadDataM, MemAddressM, CacheDataInM;
  wire BufferToMem, ReadBuffer;


  assign BufferToMem = ((~MemToRegM) & (~MemWriteM) & (~Cache.BufferWrite) & (~Buffer.empty)) | Buffer.full;
  assign ReadBuffer = BufferToMem;
  assign MemAddressM = (BufferToMem) ? Buffer.addressOut : ALUOutM;

  assign CacheDataInM = (MemWriteM) ? WriteDataM : dmem.read_data;
  assign ReadDataM = (MemToRegM & Cache.Hit) ? Cache.Data_out : dmem.read_data;


  // Data Memory
  async_dmem dmem  // keep the exact instance name
  (
    .clk       (clk),
    .write     (BufferToMem),     //memWrite//BufferToMem
    .address   (MemAddressM),     //(memWrite)? memAddress : ALUOutM//MemAddressM
    .write_data(Buffer.dataOut),  //memData//Buffer.dataOut
    .read_data ()
  );

  cache_mem Cache (
    .clk           (clk),
    .reset         (reset),
    .Data_in       (CacheDataInM),
    .address       (ALUOutM),
    .cacheWrite    (MemWriteM),
    .memToCache    (HU.MemtoCache),
    .bufferFull    (Buffer.full),    //Buffer.full
    .Buffer_address(),
    .Buffer_data   (),
    .BufferWrite   (),
    .Data_out      (),
    .Hit           ()
  );

  FIFObuffer Buffer (
    .clk       (clk),
    .reset     (reset),
    .dataIn    (Cache.Buffer_data),
    .addressIn (Cache.Buffer_address),
    .RD        (ReadBuffer),
    .WR        (Cache.BufferWrite),
    .dataOut   (),
    .addressOut(),
    .empty     (),
    .full      ()
  );

  always @(posedge clk) begin
    if (reset) begin
      RegWriteW <= 0;
      MemToRegW <= 0;
      ReadDataW <= 31'd0;
      ALUOutW   <= 31'd0;
      WriteRegW <= 5'b00000;
    end else if (~HU.StallW) begin
      RegWriteW <= RegWriteM;
      MemToRegW <= MemToRegM;
      ReadDataW <= ReadDataM;
      ALUOutW   <= ALUOutM;
      WriteRegW <= WriteRegM;
    end else;
  end
  // =========================================== Stage 5 =========================================== //
  assign ResultW = (MemToRegW) ? ReadDataW : ALUOutW;




  // MIPS Hazard Unit
  hazard_unit HU (
    .clk        (clk),
    .reset      (reset),
    .RsD        (RsD),
    .RtD        (RtD),
    .RsE        (RsE),
    .RtE        (RtE),
    .WriteRegE  (WriteRegE),
    .WriteRegM  (WriteRegM),
    .WriteRegW  (WriteRegW),
    .MemtoRegE  (MemToRegE),
    .RegWriteE  (RegWriteE),
    .MemtoRegM  (MemToRegM),
    .RegWriteM  (RegWriteM),
    .RegWriteW  (RegWriteW),
    .Branch     (PCSrcE),
    .CacheHit   (Cache.Hit),          //Cache.Hit
    .BufferWrite(Cache.BufferWrite),
    .BufferFull (Buffer.full),        //Buffer.full
    .MemtoCache (),
    .StallF     (),
    .FlushE     (),
    .StallE     (),
    .FlushD     (),
    .StallD     (),
    .StallM     (),
    .StallW     (),
    .ForwardAE  (),
    .ForwardBE  ()
  );


endmodule

