module Issue_Controller(
	input [31:0]I1,
	input [31:0]I2,
	input [31:0]I3,
	input [31:0]I4,
	input fifo_empty,
	output reg [2:0]fifo_ReadLine,
	output [2:0]DataSel_1,
	output [2:0]DataSel_2,
	output [2:0]DataSel_3,
	output [2:0]DataSel_4,
	output reg I2_Branch_Mem,
	output reg I3_Branch_Mem,
	output reg I4_Branch_Mem,
	output reg [3:0]BranchPlusX
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
`define IType	6'b111111
`define BranchType 6'b111110
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
`define wrong   6'b111101

wire [5:0] op1, op2, op3, op4;
wire [5:0] func1, func2, func3, func4;
wire [4:0] rs1, rs2, rs3, rs4;
wire [4:0] rt1, rt2, rt3, rt4;
wire [4:0] rd1, rd2, rd3, rd4;
wire [31:0] imm1, imm2, imm3, imm4;

assign op1 = I1[31:26];
assign op2 = I2[31:26];
assign op3 = I3[31:26];
assign op4 = I4[31:26];

assign func1 = I1[5:0];
assign func2 = I2[5:0];
assign func3 = I3[5:0];
assign func4 = I4[5:0];

assign rs1 = I1[25:21];
assign rs2 = I2[25:21];
assign rs3 = I3[25:21];
assign rs4 = I4[25:21];

assign rt1 = I1[20:16];
assign rt2 = I2[20:16];
assign rt3 = I3[20:16];
assign rt4 = I4[20:16];

assign rd1 = I1[15:11];
assign rd2 = I2[15:11];
assign rd3 = I3[15:11];
assign rd4 = I4[15:11];

assign imm1 = {{16{I1[15]}},I1[15:0]};
assign imm2 = {{16{I2[15]}},I2[15:0]};
assign imm3 = {{16{I3[15]}},I3[15:0]};
assign imm4 = {{16{I4[15]}},I4[15:0]};

reg [5:0] I1_Type, I2_Type, I3_Type, I4_Type;
reg [2:0] NOIL;
reg branchIsUsed;


always@(*)begin
	case(op1)
		`RType:begin
			case(func1)
				`R_add: I1_Type =`RType;
				`R_sub: I1_Type =`RType;
				`R_addu:I1_Type =`RType;
				`R_subu:I1_Type =`RType;
				`R_and: I1_Type =`RType;
				`R_or:  I1_Type =`RType;
				`R_xor: I1_Type =`RType;
				`R_nor: I1_Type =`RType;
				`R_slt: I1_Type =`RType;
				`R_sltu:I1_Type =`RType;
				default: I1_Type =`wrong;
			endcase
		end
		`addi: 	I1_Type =`IType;
		`lui:	I1_Type =`IType;
		`xori:	I1_Type =`IType;
		`andi:	I1_Type =`IType;
		`sltiu:	I1_Type =`IType;
		`slti:	I1_Type =`IType;
		`addiu: I1_Type =`IType;
		`ori: 	I1_Type =`IType;
		`beq:   I1_Type =`BranchType;
		`bne:	I1_Type =`BranchType;
		`lw: 	I1_Type =`lw;
		`sw: 	I1_Type =`sw;
	endcase
	case(op2)
		`RType:begin
			case(func2)
				`R_add: I2_Type =`RType;
				`R_sub: I2_Type =`RType;
				`R_addu:I2_Type =`RType;
				`R_subu:I2_Type =`RType;
				`R_and: I2_Type =`RType;
				`R_or:  I2_Type =`RType;
				`R_xor: I2_Type =`RType;
				`R_nor: I2_Type =`RType;
				`R_slt: I2_Type =`RType;
				`R_sltu:I2_Type =`RType;
				default: I2_Type =`wrong;
			endcase
		end
		`addi: 	I2_Type =`IType;
		`lui:	I2_Type =`IType;
		`xori:	I2_Type =`IType;
		`andi:	I2_Type =`IType;
		`sltiu:	I2_Type =`IType;
		`slti:	I2_Type =`IType;
		`addiu: I2_Type =`IType;
		`ori: 	I2_Type =`IType;
		`beq:   I2_Type =`BranchType;
		`bne:	I2_Type =`BranchType;
		`lw: 	I2_Type =`lw;
		`sw: 	I2_Type =`sw;
	endcase
	case(op3)
		`RType:begin
			case(func3)
				`R_add: I3_Type =`RType;
				`R_sub: I3_Type =`RType;
				`R_addu:I3_Type =`RType;
				`R_subu:I3_Type =`RType;
				`R_and: I3_Type =`RType;
				`R_or:  I3_Type =`RType;
				`R_xor: I3_Type =`RType;
				`R_nor: I3_Type =`RType;
				`R_slt: I3_Type =`RType;
				`R_sltu:I3_Type =`RType;
				default: I3_Type =`wrong;
			endcase
		end
		`addi: 	I3_Type =`IType;
		`lui:	I3_Type =`IType;
		`xori:	I3_Type =`IType;
		`andi:	I3_Type =`IType;
		`sltiu:	I3_Type =`IType;
		`slti:	I3_Type =`IType;
		`addiu: I3_Type =`IType;
		`ori: 	I3_Type =`IType;
		`beq:   I3_Type =`BranchType;
		`bne:	I3_Type =`BranchType;
		`lw: 	I3_Type =`lw;
		`sw: 	I3_Type =`sw;
	endcase
	case(op4)
		`RType:begin
			case(func4)
				`R_add: I4_Type =`RType;
				`R_sub: I4_Type =`RType;
				`R_addu:I4_Type =`RType;
				`R_subu:I4_Type =`RType;
				`R_and: I4_Type =`RType;
				`R_or:  I4_Type =`RType;
				`R_xor: I4_Type =`RType;
				`R_nor: I4_Type =`RType;
				`R_slt: I4_Type =`RType;
				`R_sltu:I4_Type =`RType;
				default: I4_Type =`wrong;
			endcase
		end
		`addi: 	I4_Type =`IType;
		`lui:	I4_Type =`IType;
		`xori:	I4_Type =`IType;
		`andi:	I4_Type =`IType;
		`sltiu:	I4_Type =`IType;
		`slti:	I4_Type =`IType;
		`addiu: I4_Type =`IType;
		`ori: 	I4_Type =`IType;
		`beq:   I4_Type =`BranchType;
		`bne:	I4_Type =`BranchType;
		`lw: 	I4_Type =`lw;
		`sw: 	I4_Type =`sw;
	endcase
end

reg I2_is_dependent, I3_is_dependent, I4_is_dependent;

always@(*)begin
	I2_is_dependent =0; I3_is_dependent =0; I4_is_dependent =0;
	if(I1_Type == `RType)begin
		if(I2_Type == `RType)begin		if((rd1==rt2)||(rd1==rs2)) 	I2_is_dependent = 1;	end
		else if(I2_Type == `IType)begin		if(rd1==rs2) 			I2_is_dependent = 1;	end
		else if(I2_Type == `BranchType)begin	if((rd1==rs2)||(rd1==rt2)) 	I2_is_dependent = 1;	end
		else if(I2_Type == `lw)begin		if(rd1==rs2) 			I2_is_dependent = 1;	end
		else if(I2_Type == `sw)begin		if((rd1==rt2)||(rd1==rs2)) 	I2_is_dependent = 1;	end
		else;

		if(I3_Type == `RType)begin		if((rd1==rt3)||(rd1==rs3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `IType)begin		if(rd1==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `BranchType)begin	if((rd1==rs3)||(rd1==rt3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `lw)begin		if(rd1==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `sw)begin		if((rd1==rt3)||(rd1==rs3)) 	I3_is_dependent = 1;	end
		else;

		if(I4_Type == `RType)begin		if((rd1==rt4)||(rd1==rs4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `IType)begin		if(rd1==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `BranchType)begin	if((rd1==rs4)||(rd1==rt4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `lw)begin		if(rd1==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `sw)begin		if((rd1==rt4)||(rd1==rs4)) 	I4_is_dependent = 1;	end
		else;
	end
	else if((I1_Type == `IType) || (I1_Type == `lw))begin
		if(I2_Type == `RType)begin		if((rt1==rt2)||(rt1==rs2)) 	I2_is_dependent = 1;	end
		else if(I2_Type == `IType)begin		if(rt1==rs2) 			I2_is_dependent = 1;	end
		else if(I2_Type == `BranchType)begin	if((rt1==rs2)||(rt1==rt2)) 	I2_is_dependent = 1;	end
		else if(I2_Type == `lw)begin		if(rt1==rs2) 			I2_is_dependent = 1;	end
		else if(I2_Type == `sw)begin		if((rt1==rt2)||(rt1==rs2)) 	I2_is_dependent = 1;	end
		else;

		if(I3_Type == `RType)begin		if((rt1==rt3)||(rt1==rs3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `IType)begin		if(rt1==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `BranchType)begin	if((rt1==rs3)||(rt1==rt3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `lw)begin		if(rt1==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `sw)begin		if((rt1==rt3)||(rt1==rs3)) 	I3_is_dependent = 1;	end
		else;

		if(I4_Type == `RType)begin		if((rt1==rt4)||(rt1==rs4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `IType)begin		if(rt1==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `BranchType)begin	if((rt1==rs4)||(rt1==rt4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `lw)begin		if(rt1==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `sw)begin		if((rt1==rt4)||(rt1==rs4)) 	I4_is_dependent = 1;	end
		else;
	end
	else if(I1_Type == `sw)begin
		if(I2_Type == `lw)begin			if((rs1==rs2)&&(imm1==imm2))	I2_is_dependent = 1;	end
		if(I3_Type == `lw)begin			if((rs1==rs3)&&(imm1==imm3))	I3_is_dependent = 1;	end	
		if(I4_Type == `lw)begin			if((rs1==rs4)&&(imm1==imm4))	I4_is_dependent = 1;	end		
	end
	else;

	if(I2_Type == `RType)begin
		if(I3_Type == `RType)begin		if((rd2==rt3)||(rd2==rs3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `IType)begin		if(rd2==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `BranchType)begin	if((rd2==rs3)||(rd2==rt3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `lw)begin		if(rd2==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `sw)begin		if((rd2==rt3)||(rd2==rs3)) 	I3_is_dependent = 1;	end
		else;

		if(I4_Type == `RType)begin		if((rd2==rt4)||(rd2==rs4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `IType)begin		if(rd2==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `BranchType)begin	if((rd2==rs4)||(rd2==rt4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `lw)begin		if(rd2==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `sw)begin		if((rd2==rt4)||(rd2==rs4)) 	I4_is_dependent = 1;	end
		else;
	end
	else if((I2_Type == `IType) || (I2_Type == `lw))begin
		if(I3_Type == `RType)begin		if((rt2==rt3)||(rt2==rs3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `IType)begin		if(rt2==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `BranchType)begin	if((rt2==rs3)||(rt2==rt3)) 	I3_is_dependent = 1;	end
		else if(I3_Type == `lw)begin		if(rt2==rs3) 			I3_is_dependent = 1;	end
		else if(I3_Type == `sw)begin		if((rt2==rt3)||(rt2==rs3)) 	I3_is_dependent = 1;	end
		else;

		if(I4_Type == `RType)begin		if((rt2==rt4)||(rt2==rs4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `IType)begin		if(rt2==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `BranchType)begin	if((rt2==rs4)||(rt2==rt4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `lw)begin		if(rt2==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `sw)begin		if((rt2==rt4)||(rt2==rs4)) 	I4_is_dependent = 1;	end
		else;
	end
	else if(I2_Type == `sw)begin
		if(I3_Type == `lw)begin			if((rs2==rs3)&&(imm2==imm3))	I3_is_dependent = 1;	end	
		if(I4_Type == `lw)begin			if((rs2==rs4)&&(imm2==imm4))	I4_is_dependent = 1;	end		
	end
	else;

	if(I3_Type == `RType)begin
		if(I4_Type == `RType)begin		if((rd3==rt4)||(rd3==rs4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `IType)begin		if(rd3==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `BranchType)begin	if((rd3==rs4)||(rd3==rt4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `lw)begin		if(rd3==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `sw)begin		if((rd3==rt4)||(rd3==rs4)) 	I4_is_dependent = 1;	end
		else;
	end
	else if((I3_Type == `IType) || (I3_Type == `lw))begin
		if(I4_Type == `RType)begin		if((rt3==rt4)||(rt3==rs4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `IType)begin		if(rt3==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `BranchType)begin	if((rt3==rs4)||(rt3==rt4)) 	I4_is_dependent = 1;	end
		else if(I4_Type == `lw)begin		if(rt3==rs4) 			I4_is_dependent = 1;	end
		else if(I4_Type == `sw)begin		if((rt3==rt4)||(rt3==rs4)) 	I4_is_dependent = 1;	end
		else;
	end
	else if(I3_Type == `sw)begin
		if(I4_Type == `lw)begin			if((rs3==rs4)&&(imm3==imm4))	I4_is_dependent = 1;	end		
	end
	else;
end

reg [2:0]I1_sel, I2_sel, I3_sel, I4_sel;

always@(*)begin
	I1_sel =4; I2_sel =4; I3_sel =4; I4_sel =4;

	if(I1_Type==`RType)		I1_sel =0;
	else if(I1_Type==`IType)	I1_sel =0;
	else if(I1_Type==`BranchType)	I1_sel =0;
	else if(I1_Type==`lw)		I1_sel =2;
	else if(I1_Type==`sw)		I1_sel =3;
	else 				I1_sel =4;

	if((I2_Type==`RType) || (I2_Type==`IType))begin
		if((I1_Type==`RType) || (I1_Type==`IType) || (I1_Type==`BranchType))		I2_sel =1;
		else if((I1_Type==`lw) || (I1_Type==`sw))					I2_sel =0;
		else 										I2_sel =4;
	end
	else if(I2_Type==`BranchType)begin
		if((I1_Type==`RType) || (I1_Type==`IType))begin			I1_sel =1;	I2_sel =0;	end
		else if(I1_Type==`BranchType)							I2_sel =4;
		else if((I1_Type==`lw) || (I1_Type==`sw))					I2_sel =0;
		else 										I2_sel =4;
	end
	else if(I2_Type==`lw)begin
		if((I1_Type==`RType) || (I1_Type==`IType) || (I1_Type==`BranchType) || (I1_Type==`sw))		
												I2_sel =2;
		else if(I1_Type==`lw)								I2_sel =4;
		else										I2_sel =4;
	end
	else if(I2_Type==`sw)begin
		if((I1_Type==`RType) || (I1_Type==`IType) || (I1_Type==`BranchType) || (I1_Type==`lw))		
												I2_sel =3;
		else if(I1_Type==`sw)								I2_sel =4;
		else										I2_sel =4;
	end
	else I2_sel =4;
	
	if(I2_sel != 4)begin
		if((I3_Type==`RType) || (I3_Type==`IType))begin
			if((I1_sel!=0) && (I2_sel!=0))						I3_sel =0;
			else if((I1_sel!=1) && (I2_sel!=1))					I3_sel =1;
			else									I3_sel =4;
		end
		else if(I3_Type==`BranchType)begin
			if((I1_sel!=0) && (I2_sel!=0))						I3_sel =0;		
			else if((I1_sel==0) && (I2_sel!=1) && (I1_Type!=`BranchType))begin	I3_sel =0;
												I1_sel =1;	end
			else if((I2_sel==0) && (I1_sel!=1) && (I2_Type!=`BranchType))begin	I3_sel =0;
												I2_sel =1;	end	
			else									I3_sel =4;			
		end
		else if(I3_Type==`lw)begin
			if((I1_sel!=2) && (I2_sel!=2))						I3_sel =2;
			else 									I3_sel =4;
		end
		else if(I3_Type==`sw)begin
			if((I1_sel!=3) && (I2_sel!=3))						I3_sel =3;
			else									I3_sel =4;
		end
		else										I3_sel =4;
	end
	else I3_sel =4;

	if(I3_sel != 4)begin
		if((I4_Type==`RType) || (I4_Type==`IType))begin
			if((I1_sel!=0) && (I2_sel!=0) && (I3_sel!=0))				I4_sel =0;
			else if((I1_sel!=1) && (I2_sel!=1) && (I3_sel!=1))			I4_sel =1;
			else									I4_sel =4;
		end
		else if(I4_Type==`BranchType)begin
			if((I1_sel!=0) && (I2_sel!=0) && (I3_sel!=0))				I4_sel =0;
			else if((I1_sel==0) && (I2_sel!=1) && (I3_sel!=1) && (I1_Type!=`BranchType))begin	
												I4_sel =0;
												I1_sel =1;	end	
			else if((I2_sel==0) && (I1_sel!=1) && (I3_sel!=1) && (I2_Type!=`BranchType))begin	
												I4_sel =0;
												I2_sel =1;	end	
			else if((I3_sel==0) && (I1_sel!=1) && (I2_sel!=1) && (I3_Type!=`BranchType))begin	
												I4_sel =0;
												I3_sel =1;	end
			else									I4_sel =4;
		end
		else if(I4_Type==`lw)begin
			if((I1_sel!=2) && (I2_sel!=2) && (I2_sel!=2))				I4_sel =2;
			else 									I4_sel =4;
		end
		else if(I4_Type==`sw)begin
			if((I1_sel!=3) && (I2_sel!=3) && (I2_sel!=3))				I4_sel =3;
			else 									I4_sel =4;
		end
		else										I4_sel =4;
	end
	else I4_sel =4;
end


assign DataSel_1 = (fifo_empty)?								3'd4 : I1_sel;
assign DataSel_2 = (fifo_empty || (I2_is_dependent==1))?					3'd4 : I2_sel;
assign DataSel_3 = (fifo_empty || (I2_is_dependent==1) || (I3_is_dependent==1))?		3'd4 : I3_sel;
assign DataSel_4 = (fifo_empty || (I2_is_dependent==1) || (I3_is_dependent==1) || (I4_is_dependent==1))?	
												3'd4 : I4_sel;
always@(*)begin
	if((DataSel_1!=4) && (DataSel_2!=4) && (DataSel_3!=4) && (DataSel_4!=4))	fifo_ReadLine = 4;
	else if((DataSel_1!=4) && (DataSel_2!=4) && (DataSel_3!=4))			fifo_ReadLine = 3;
	else if((DataSel_1!=4) && (DataSel_2!=4))					fifo_ReadLine = 2;
	else if(DataSel_1!=4)								fifo_ReadLine = 1;
	else										fifo_ReadLine = 0;
end

always@(*)begin
	if(I1_Type == `BranchType)begin
		I2_Branch_Mem =1;	I3_Branch_Mem =1;	I4_Branch_Mem =1;	BranchPlusX =0;
	end
	else if(I2_Type == `BranchType)begin
		I2_Branch_Mem =0;	I3_Branch_Mem =1;	I4_Branch_Mem =1;	BranchPlusX =4;
	end
	else if(I3_Type == `BranchType)begin
		I2_Branch_Mem =0;	I3_Branch_Mem =0;	I4_Branch_Mem =1;	BranchPlusX =8;
	end
	else if(I4_Type == `BranchType)begin
		I2_Branch_Mem =0;	I3_Branch_Mem =0;	I4_Branch_Mem =0;	BranchPlusX =12;
	end
	else begin
		I2_Branch_Mem =0;	I3_Branch_Mem =0;	I4_Branch_Mem =0;	BranchPlusX =0;
	end
end


endmodule




