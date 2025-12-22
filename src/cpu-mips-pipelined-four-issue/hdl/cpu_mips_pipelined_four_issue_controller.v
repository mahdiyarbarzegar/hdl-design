module MIPS_FourIssue_Controller(
	input [31:0]I0,
	input [31:0]I1,
	input [31:0]I2,
	input [31:0]I3,

	output reg [3:0]ALUCTRL_0,
	output reg ALUSrc_0,	
	output reg RegDst_0,
	output reg RegWrite_0,
	output reg SignExtend_0,
	output reg Branch_e_0,
	output reg Branch_n_0,

	output reg [3:0]ALUCTRL_1,
	output reg ALUSrc_1,	
	output reg RegDst_1,
	output reg RegWrite_1,
	output reg SignExtend_1,

	output reg MemToReg_2,
	output reg RegWrite_2,

	output reg MemWrite_3
);

wire [5:0] op0, op1, op2, op3;
wire [5:0] func0, func1, func2, func3;

assign op0 = I0[31:26];
assign op1 = I1[31:26];
assign op2 = I2[31:26];
assign op3 = I3[31:26];

assign func0 = I0[5:0];
assign func1 = I1[5:0];
assign func2 = I2[5:0];
assign func3 = I3[5:0];

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
	case(op0)
		`addi:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =1; ALUCTRL_0 = `ADD;
		end
		`addiu:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `ADD;
		end
		`slti:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =1; ALUCTRL_0 = `SLT;
		end
		`sltiu:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `SLTU;
		end
		`andi:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `AND;
		end
		`ori:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `OR;
		end
		`xori:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `XOR;
		end
		`lui:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =1; RegDst_0 =0; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `LUI;
		end
		`beq:begin
			Branch_e_0 =1; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =0; RegWrite_0 =0; SignExtend_0 =1; ALUCTRL_0 = `SUB;
		end
		`bne:begin
			Branch_e_0 =0; Branch_n_0 =1; ALUSrc_0 =0; RegDst_0 =0; RegWrite_0 =0; SignExtend_0 =1; ALUCTRL_0 = `SUB;
		end
		`RType:begin
			case(func0)
				`R_add:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `ADD;
				end
				`R_sub:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `SUB;
				end
				`R_addu:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `ADD;
				end
				`R_subu:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `SUB;
				end
				`R_and:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `AND;
				end
				`R_or:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `OR;
				end
				`R_xor:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `XOR;
				end
				`R_nor:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `NOR;
				end
				`R_slt:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `SLT;
				end
				`R_sltu:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =1; SignExtend_0 =0; ALUCTRL_0 = `SLTU;
				end
				default:begin
					Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =1; RegWrite_0 =0; SignExtend_0 =0; ALUCTRL_0 = `ADD;
				end
			endcase
		end
		default:begin
			Branch_e_0 =0; Branch_n_0 =0; ALUSrc_0 =0; RegDst_0 =0; RegWrite_0 =0; SignExtend_0 =0; ALUCTRL_0 = `ADD;
		end
	endcase
end


always@(*)begin
	case(op1)
		`addi:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =1; ALUCTRL_1 = `ADD;
		end
		`addiu:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `ADD;
		end
		`slti:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =1; ALUCTRL_1 = `SLT;
		end
		`sltiu:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `SLTU;
		end
		`andi:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `AND;
		end
		`ori:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `OR;
		end
		`xori:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `XOR;
		end
		`lui:begin
			ALUSrc_1 =1; RegDst_1 =0; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `LUI;
		end
		`beq:begin
			ALUSrc_1 =0; RegDst_1 =0; RegWrite_1 =0; SignExtend_1 =1; ALUCTRL_1 = `SUB;
		end
		`bne:begin
			ALUSrc_1 =0; RegDst_1 =0; RegWrite_1 =0; SignExtend_1 =1; ALUCTRL_1 = `SUB;
		end
		`RType:begin
			case(func1)
				`R_add:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `ADD;
				end
				`R_sub:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `SUB;
				end
				`R_addu:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `ADD;
				end
				`R_subu:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `SUB;
				end
				`R_and:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `AND;
				end
				`R_or:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `OR;
				end
				`R_xor:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `XOR;
				end
				`R_nor:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `NOR;
				end
				`R_slt:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `SLT;
				end
				`R_sltu:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =1; SignExtend_1 =0; ALUCTRL_1 = `SLTU;
				end
				default:begin
					ALUSrc_1 =0; RegDst_1 =1; RegWrite_1 =0; SignExtend_1 =0; ALUCTRL_1 = `ADD;
				end
			endcase
		end
		default:begin
			ALUSrc_1 =0; RegDst_1 =0; RegWrite_1 =0; SignExtend_1 =0; ALUCTRL_1 = `ADD;
		end
	endcase
end


always@(*)begin
	case(op2)
		`lw:begin
			MemToReg_2 =1;	RegWrite_2 =1;
		end
		default:begin
			MemToReg_2 =0;	RegWrite_2 =0;
		end
	endcase
end

always@(*)begin
	case(op3)
		`sw:begin
			MemWrite_3 =1;
		end
		default:begin
			MemWrite_3 =0;
		end
	endcase
end

endmodule











