`timescale 1ns/1ns

// Memory =========================================================================
module async_imem(
   	input [31:0] address,
   	output [127:0] read_data
);
reg [31:0] mem_data [0:(1<<16)-1];

assign read_data = {mem_data[{address[17:4],2'b00}+3], 
		    mem_data[{address[17:4],2'b00}+2], 
		    mem_data[{address[17:4],2'b00}+1], 
		    mem_data[{address[17:4],2'b00}]};	// zero delay, address to read data

endmodule

module async_dmem(
   	input clk,
   	input write,
   	input [31:0] addressRead,
   	input [31:0] addressWrite,
   	input [31:0] write_data,
   	output [31:0] read_data
);
reg [31:0] mem_data [0:(1<<16)-1];

assign read_data = mem_data[addressRead[17:2]];  // zero delay, address to read data

always @( posedge clk )begin
      	if (write)begin
         	mem_data[addressWrite[17:2]] <= write_data;
	end
end

endmodule

module fifo_buffer(
	input clk,
	input reset,
	input [31:0] In0,
	input [31:0] In1,
	input [31:0] In2,
	input [31:0] In3,
	input [2:0]RD, 
	input [2:0]WR, 
	output [31:0] Out0,
	output [31:0] Out1,
	output [31:0] Out2,
	output [31:0] Out3,
	output [3:0] capacity,
	output empty,
	output full
);
reg [31:0] FIFO_data[0:3];
reg [2:0] Writepointer, Readpointer;
reg [3:0] Counter; 

assign Out0  = FIFO_data[Readpointer];
assign Out1  = ((Readpointer+1)>=4)? 32'd0 : FIFO_data[Readpointer+1];
assign Out2  = ((Readpointer+2)>=4)? 32'd0 : FIFO_data[Readpointer+2];
assign Out3  = ((Readpointer+3)>=4)? 32'd0 : FIFO_data[Readpointer+3];

assign capacity = (4 - Counter);
assign empty = (capacity == 4);
assign full = (capacity == 0);

always @ (posedge clk)begin 
	if (reset) begin 
		Counter <= 0; 
		Readpointer <= 0;
		Writepointer <= 0;
	end 
	else begin 
		if (RD && Counter>0) begin 		
			Counter = Counter - RD;
			Readpointer = (Readpointer + RD)%4;	 
		end 

		if (WR && Counter==0) begin
			if(WR==1)begin      
				FIFO_data[0] = In0;	
				FIFO_data[1] = 32'd0;	
				FIFO_data[2] = 32'd0;
				FIFO_data[3] = 32'd0;
			end
			else if(WR==2)begin
				FIFO_data[0] = In0;	
				FIFO_data[1] = In1;
				FIFO_data[2] = 32'd0;
				FIFO_data[3] = 32'd0;
			end
			else if(WR==3)begin
				FIFO_data[0] = In0;	
				FIFO_data[1] = In1;	
				FIFO_data[2] = In2;
				FIFO_data[3] = 32'd0;
			end
			else if(WR==4)begin
				FIFO_data[0] = In0;	
				FIFO_data[1] = In1;	
				FIFO_data[2] = In2;
				FIFO_data[3] = In3;
			end

			Counter = Counter + WR;

			Readpointer =0;
		end 
	end 
end 

endmodule

module FourIssueDataSelector(
	input [31:0]D0,
	input [31:0]D1,
	input [31:0]D2,
	input [31:0]D3,
	input D1_Brnach_Mem,
	input D2_Brnach_Mem,
	input D3_Brnach_Mem,
	input [2:0]I0_SEL,
	input [2:0]I1_SEL,
	input [2:0]I2_SEL,
	input [2:0]I3_SEL,
	output reg[31:0]I0,
	output reg[31:0]I1,
	output reg[31:0]I2,
	output reg[31:0]I3,
	output reg I1_Branch_Act,
	output reg I2_Branch_Act,
	output reg I3_Branch_Act
);


always@(*)begin
	I0 =0; I1 =0; I2 =0; I3 =0; I1_Branch_Act =0; I2_Branch_Act =0; I3_Branch_Act =0;
	case(I0_SEL)
		0: I0 = D0;
		1: I1 = D0;
		2: I2 = D0;
		3: I3 = D0;
	endcase
	case(I1_SEL)
		0: I0 = D1;	
		1:begin I1 = D1;	I1_Branch_Act = D1_Brnach_Mem;	end
		2:begin I2 = D1;	I2_Branch_Act = D1_Brnach_Mem;	end
		3:begin I3 = D1;	I3_Branch_Act = D1_Brnach_Mem;	end
	endcase
	case(I2_SEL)
		0: I0 = D2;
		1:begin I1 = D2;	I1_Branch_Act = D2_Brnach_Mem;	end
		2:begin I2 = D2;	I2_Branch_Act = D2_Brnach_Mem;	end
		3:begin I3 = D2;	I3_Branch_Act = D2_Brnach_Mem;	end
	endcase
	case(I3_SEL)
		0: I0 = D3;
		1:begin I1 = D3;	I1_Branch_Act = D3_Brnach_Mem;	end
		2:begin I2 = D3;	I1_Branch_Act = D3_Brnach_Mem;	end
		3:begin I3 = D3;	I1_Branch_Act = D3_Brnach_Mem;	end
	endcase
end

endmodule

//==============================================================================
//`define DEBUG	// comment this line to disable register content writing below
//==============================================================================
module reg_file(
	input  clk,

	input  write1,
	input  write2,
	input  write3,

	input  [ 4:0] WR1,
	input  [ 4:0] WR2,
	input  [ 4:0] WR3,

	input  [31:0] WD1,
	input  [31:0] WD2,
	input  [31:0] WD3,

	input  [ 4:0] RR1,
	input  [ 4:0] RR2,
	input  [ 4:0] RR3,
	input  [ 4:0] RR4,
	input  [ 4:0] RR5,
	input  [ 4:0] RR6,
	input  [ 4:0] RR7,

	output [31:0] RD1,
	output [31:0] RD2,
	output [31:0] RD3,
	output [31:0] RD4,
	output [31:0] RD5,
	output [31:0] RD6,
	output [31:0] RD7
	);

	reg [31:0] reg_data [0:31];

	assign RD1 = reg_data[RR1];
	assign RD2 = reg_data[RR2];
	assign RD3 = reg_data[RR3];
	assign RD4 = reg_data[RR4];
	assign RD5 = reg_data[RR5];
	assign RD6 = reg_data[RR6];
	assign RD7 = reg_data[RR7];
	
	always @(posedge clk) begin
		if(write1) reg_data[WR1] <= WD1;

		if(write2) reg_data[WR2] <= WD2;

		if(write3) reg_data[WR3] <= WD3;

		reg_data[0] <= 32'h00000000;
	end

endmodule

// ALU ==========================================================================
module ALU (
	input[31:0]A,
	input[31:0]B,
	input[3:0]Op,
	output [31:0]ALUResult,
	output Zero
);
`define ADD   4'd0
`define SUB   4'd1
`define AND   4'd2
`define OR    4'd3
`define XOR   4'd4
`define NOR   4'd5
`define SLT   4'd6
`define SLTU  4'd7
`define LUI   4'd8

wire sub = Op != `ADD;
wire [31:0]bb = sub? ~B : B;
wire [32:0]sum = A + bb + sub;

wire sltu = !sum[32];
wire v = sub?
	(A[31] != B[31] && A[31] != sum[31])
       :(A[31] == B[31] && A[31] != sum[31]);

wire slt = v ^ sum[31];

reg [31:0]x;

always@(*)begin
	case( Op )
		`ADD  : x = sum;
		`SUB  : x = sum;
		`SLT  : x = slt;
		`SLTU : x = sltu;
		`AND  : x = A & B;
		`OR   : x = A | B;
		`NOR  : x = ~(A | B);
		`XOR  : x = A ^ B;
		`LUI  : x = (B << 16);
		default : x = 32'hxxxxxxxx;
	endcase
end

assign ALUResult = x;
assign Zero = (x==32'h00000000)? 1'b1 : 1'b0;

endmodule






