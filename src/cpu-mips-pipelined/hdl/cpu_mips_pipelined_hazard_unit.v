`timescale 1ns/1ns


// Hazard Unit ==============================================================
module hazard_unit(
	input clk,
	input reset,
	input [4:0] RsD,
	input [4:0] RtD,
	input [4:0] RsE,
	input [4:0] RtE,
	input [4:0] WriteRegE,
	input [4:0] WriteRegM,
	input [4:0] WriteRegW,
	input MemtoRegE,
	input RegWriteE,
	input RegWriteM,
	input MemtoRegM,
	input RegWriteW,
	input Branch,
	input CacheHit,
	input BufferWrite,
	input BufferFull,
	output reg MemtoCache,
	output StallF,
	output FlushE,
	output StallE,
	output FlushD,
	output StallD,
	output StallM,
	output StallW,
	output reg [1:0] ForwardAE,
	output reg [1:0] ForwardBE
);

reg lwstall, branchstall, lwDelaystall, swBufferstall;

assign StallF = lwstall | lwDelaystall | swBufferstall;
assign FlushD = branchstall;
assign StallD = lwstall | lwDelaystall | swBufferstall;
assign FlushE = lwstall | branchstall;
assign StallE = lwDelaystall | swBufferstall;
assign StallM = lwDelaystall | swBufferstall;
assign StallW = lwDelaystall | swBufferstall;

always @(*)begin
//----- Forwarding logic for ForwardAE
	if ((RsE != 0) && (RsE == WriteRegM) && RegWriteM)
		ForwardAE = 2'b10;
	else if ((RsE != 0) && (RsE == WriteRegW) && RegWriteW)
		ForwardAE = 2'b01;
	else 
		ForwardAE = 2'b00;
//----- Forwarding logic for ForwardBE
	if ((RtE != 0) && (RtE == WriteRegM) && RegWriteM)
		ForwardBE = 2'b10;
	else if ((RtE != 0) && (RtE == WriteRegW) && RegWriteW)
		ForwardBE = 2'b01;
	else 
		ForwardBE = 2'b00;
//----- Stalling logic for lw
	lwstall = ((RsD == RtE) || (RtD == RtE)) && MemtoRegE;
//----- Satlling logic for Branch
	branchstall = Branch;
//----- Stalling logic for write buffer to memory
	swBufferstall = BufferFull & BufferWrite;

end

reg [1:0]State, NxtState;

always @(*)begin
	case(State)
		2'b00:begin
			if(MemtoRegM & (CacheHit))begin		
				NxtState = 2'b00;	lwDelaystall = 0;	MemtoCache = 0; end
			else if(MemtoRegM & (~CacheHit))begin 	
				NxtState = 2'b01;	lwDelaystall = 1; 	MemtoCache = 0; end
			else begin				
				NxtState = 2'b00;	lwDelaystall = 0; 	MemtoCache = 0; end
		end
		2'b01:begin
			if(MemtoRegM)begin	
				NxtState = 2'b10;	lwDelaystall = 1; 	MemtoCache = 0; end
			else begin		
				NxtState = 2'b00;	lwDelaystall = 0; 	MemtoCache = 0; end
		end
		2'b10:begin
			if(~swBufferstall)begin
				NxtState = 2'b00;	lwDelaystall = 0;	MemtoCache = 1; end	
			else begin
				NxtState = 2'b10;	lwDelaystall = 0;	MemtoCache = 1; end	
		end
		default:begin
				NxtState = 2'b00;	lwDelaystall = 0; 	MemtoCache = 0; end
	endcase
end

always @(posedge clk, posedge reset)begin
	if(reset)begin
		State <= 2'b00;
		lwDelaystall <= 0;
		MemtoCache <= 0;
	end
	else State <= NxtState;
end

endmodule


