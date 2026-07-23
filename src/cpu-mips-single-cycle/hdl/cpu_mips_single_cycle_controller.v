`timescale 1ns / 1ns

module MIPS_Controller(
	input [5:0]Opcode,
	input [5:0]funct,
	output reg MemToReg,
	output reg MemWrite,
	output reg Branch_e,
	output reg Branch_n,
	output reg ALUSrc,
	output reg RegDst,
	output reg RegWrite,
	output reg SignExtend,
	output reg [3:0]ALUCTRL
);

// R-Format Instructions
`define RType	6'b000000
`define R_add	6'b100000
`define R_sub	6'b100010
`define R_addu	6'b100001
`define R_subu	6'b100011
`define R_and	6'b100100
`define R_or	6'b100101
`define R_xor	6'b100110
`define R_nor	6'b100111
`define R_slt	6'b101010
`define R_sltu	6'b101011
// I-Format Instructions
`define addi	6'b001000
`define addiu	6'b001001
`define slti	6'b001010
`define sltiu	6'b001011
`define andi	6'b001100
`define ori	6'b001101
`define xori	6'b001110
`define lui	6'b001111
`define beq	6'b000100
`define bne	6'b000101
`define lw	6'b100011
`define sw	6'b101011
// ALU Commands
`define ADD   4'd0
`define SUB   4'd1
`define AND   4'd2
`define OR    4'd3
`define XOR   4'd4
`define NOR   4'd5
`define SLT   4'd6
`define SLTU  4'd7
`define LUI   4'd8

always@(*)begin
	case(Opcode)
		`addi:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =1; ALUCTRL = `ADD;
		end
		`addiu:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =0; ALUCTRL = `ADD;
		end
		`slti:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =1; ALUCTRL = `SLT;
		end
		`sltiu:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =0; ALUCTRL = `SLTU;
		end
		`andi:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =0; ALUCTRL = `AND;
		end
		`ori:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =0; ALUCTRL = `OR;
		end
		`xori:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =0; ALUCTRL = `XOR;
		end
		`lui:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =0; ALUCTRL = `LUI;
		end
		`beq:begin
			MemToReg =0; MemWrite =0; Branch_e =1; Branch_n =0; ALUSrc =0; RegDst =0; RegWrite =0; SignExtend =1; ALUCTRL = `SUB;
		end
		`bne:begin
			MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =1; ALUSrc =0; RegDst =0; RegWrite =0; SignExtend =1; ALUCTRL = `SUB;
		end
		`lw:begin
			MemToReg =1; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =1; SignExtend =1; ALUCTRL = `ADD;
		end
		`sw:begin
			MemToReg =1; MemWrite =1; Branch_e =0; Branch_n =0; ALUSrc =1; RegDst =0; RegWrite =0; SignExtend =1; ALUCTRL = `ADD;
		end
		`RType:begin
			case(funct)
				`R_add:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `ADD;
				end
				`R_sub:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `SUB;
				end
				`R_addu:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `ADD;
				end
				`R_subu:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `SUB;
				end
				`R_and:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `AND;
				end
				`R_or:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `OR;
				end
				`R_xor:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `XOR;
				end
				`R_nor:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `NOR;
				end
				`R_slt:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `SLT;
				end
				`R_sltu:begin
					MemToReg =0; MemWrite =0; Branch_e =0; Branch_n =0; ALUSrc =0; RegDst =1; RegWrite =1; SignExtend =0; ALUCTRL = `SLTU;
				end
			endcase
		end
	endcase
end



endmodule

