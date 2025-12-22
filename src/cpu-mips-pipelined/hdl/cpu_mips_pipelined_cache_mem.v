`timescale 1ns/1ns


// Cache Memory ==============================================================
module cache_mem(
	input clk,
	input reset,
	input [31:0]Data_in,
	input [31:0]address,
	input cacheWrite,
	input memToCache,
	input bufferFull,
	output [31:0]Buffer_address,
	output [31:0]Buffer_data,
	output BufferWrite,
	output [31:0]Data_out,
	output Hit
);
reg [31:0]cache_data[0:15];
reg [25:0]cache_tag[0:15];
reg cache_V[0:15];
reg cache_D[0:15];

wire tag_exist;
wire write_hit;


assign tag_exist = (address[31:6] == cache_tag[address[5:2]])? 1'b1 : 1'b0;
assign Hit = tag_exist & cache_V[address[5:2]];
assign Data_out = cache_data[address[5:2]];

assign write_hit = (cacheWrite) & tag_exist;

assign Buffer_data = cache_data[address[5:2]];
assign Buffer_address = {cache_tag[address[5:2]], address[5:2], 2'b00};
assign BufferWrite = (cacheWrite | memToCache) & (~tag_exist) & cache_D[address[5:2]];

integer i;
always @(posedge clk)begin
	if(reset)begin
		for (i = 0; i < 16; i = i + 1)begin
            		cache_tag[i] <= 26'd0;
			cache_V[i] <= 1'b0;
			cache_D[i] <= 1'b0;
		end
	end
	else if(cacheWrite)begin
		if(tag_exist | (~bufferFull))begin
			cache_data[address[5:2]] <= Data_in;
			cache_tag[address[5:2]] <= address[31:6];
			cache_D[address[5:2]] <= 1'b1;
			cache_V[address[5:2]] <= 1'b1;
		end
	end
	else if(memToCache)begin
		if(~bufferFull)begin
			cache_data[address[5:2]] <= Data_in;
			cache_tag[address[5:2]] <= address[31:6];
			cache_D[address[5:2]] <= 1'b0;
			cache_V[address[5:2]] <= 1'b1;		
		end
	end
end

endmodule

// FIFO Write Back Buffer ==========================================================
module FIFObuffer( 
	input clk, 
	input reset,
	input [31:0]dataIn, 
	input [31:0]addressIn,
	input RD, 
	input WR,   
	output [31:0]dataOut,
	output [31:0]addressOut,
	output empty, 
	output full 
); 
reg [31:0] FIFO_data [0:7]; 
reg [31:0] FIFO_address [0:7];
reg [2:0] Writepointer, Readpointer;
reg [2:0] Counter; 

assign empty = (Counter==0)? 1'b1:1'b0; 
assign full = (Counter==8)? 1'b1:1'b0; 

assign dataOut  = FIFO_data[Readpointer];
assign addressOut = FIFO_address[Readpointer];

always @ (posedge clk)begin 
	if (reset) begin 
		Counter <= 0; 
		Readpointer <= 0;
		Writepointer <= 0;
	end 
	else begin 
		if (RD ==1'b1 && Counter>0) begin 		
			Counter <= Counter - 1;
			if(Readpointer<7) Readpointer <= Readpointer + 1;
			else Readpointer <= 0;		 
		end 
		else if (WR==1'b1 && Counter<8) begin
			FIFO_data[Writepointer]  <= dataIn;
			FIFO_address[Writepointer] <= addressIn;
			Counter  <= Counter + 1;
			if(Writepointer <7) Writepointer <= Writepointer + 1;
			else Writepointer <= 0;
		end 
		else; 
	end 
end 

endmodule
