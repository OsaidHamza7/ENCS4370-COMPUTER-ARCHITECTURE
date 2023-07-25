			  /*Students Names:

	Osaid Hamza-1200875 
	Mahmoud Hamdan-1201134
	Mohammad Owda-1200089
	
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module Mux2to1 (
    input [31:0] d0, // Input data 0
    input [31:0] d1, // Input data 1
    input  sel, // Select input
    output reg [31:0] y // Output
);
    always @* begin
        case (sel)
            1'b0: y = d0;
            1'b1: y = d1;
            default: y = 32'b0; // default case, should never be reached
        endcase
    end
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
module mux2to1 (
    input z, // Input data 0
    input t, // Input data 1
    input  selc, // Select input
    output reg [1:0] y // Output
);
    always @* begin
        case (z)
            1'b0: y = 2'b00;
            1'b1: y = y + 2'b10;
            default: y = 2'b00; // default case, should never be reached
        endcase
    end
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Mux3to1 (
    input [31:0] d0, // Input data 0
    input [31:0] d1, // Input data 1
	input [31:0] d2, // Input data 1
    input [1:0] sel, // Select input
    output reg [31:0] y // Output
);
    always @* begin
        case (sel)
            2'b00: y = d0;
            2'b01: y = d1;
			2'b10: y = d2;
            default: y = 32'b0; // default case, should never be reached
        endcase
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Extender5(
    input [4:0] in,   // 14-bit input
    output reg [31:0] out  // 32-bit output
);

    always @* begin
            out = {27'b0, in};         // Unsigned extend
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//IF stage
module PC_selector (
  input [31:0] PC_in,
  output reg [31:0] output1
  );		  
  
  assign output1=PC_in;

endmodule	   

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module InstructionMemory (
  input [31:0] address,
  output reg [31:0] instruction,
  output reg [4:0] functionCode, 
  
  output reg [4:0] Rs1,
  output reg [4:0] Rs2,
  output reg [4:0] Rd,
  output reg [1:0] Type,
  output reg stop,
  output reg [13:0] immediate14,
  output reg [23:0] immediate24,
  output reg [4:0] SA
);

  reg [31:0] instruction_memory [0:1023];
  
  initial begin
    // Initialize the instruction memory with example instructions
    //instruction_memory[0] = 32'h18443000;//CMP
    //instruction_memory[1] = 32'h18C41000;//CMP
    // ...	   
	//instruction_memory[1] =  32'h00000062; //j #+12  
	//instruction_memory[1] = 32'h2002003C; //beq   BEQ R1, R0, 00000000000111 stop=0
	
	instruction_memory[0] =	32'h10840206; // SLLV R2, R1, R0, 
	instruction_memory[1] = 32'h08000062; //JAL #12 
	instruction_memory[2] = 32'h00040086;//SLL R1, R0, #1
	
	instruction_memory[9] = 32'h0802001C; //ADDI
	 
	
	instruction_memory[14] = 32'h18440025;//sw	 stop=1
	
	instruction_memory[13] = 32'h10440024;//lw 
	
    instruction_memory[12] = 32'h00040086;//SLL R1, R0, #1
	instruction_memory[11] = 32'h08040086;//SLR
	instruction_memory[10] = 32'h10820206;//SLLV  
	
  end

  //always @(*) begin
   // instruction = instruction_memory[address];
  // end
  
  always @(*) begin
  instruction = instruction_memory[address];
  Type[1:0] = instruction [2:1]; 
  // Extract fields based on Type
  case (Type)
    2'b00: begin // Type 0 is for R-type
      functionCode = instruction[31:27];
      Rs1 = instruction[26:22];
      Rd = instruction[21:17];
      Rs2 = instruction[16:12];
	  stop = instruction[0];
    end
    2'b10: begin // Type 2 is for I-type
      functionCode = instruction[31:27];
      Rs1 = instruction[26:22];
      Rd = instruction[21:17];
      immediate14 = instruction[16:3];
      stop = instruction[0];
    end
    2'b01: begin // Type 1 is for the J-type 
      functionCode = instruction[31:27];
   	  immediate24 = instruction[26:3];
      stop = instruction[0];
    end
    2'b11: begin // Type 3 for the S-type 
      functionCode = instruction[31:27];
      Rs1 = instruction[26:22];
      Rd = instruction[21:17];
      Rs2 = instruction[16:12];
	  SA = instruction[11:7];
	  stop = instruction[0];
    end
  endcase
end
  

endmodule  

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//ID stage
module Register_File(
	input clk,
	input en, enWB,
	input reset,
	input RegWr,
	input [4:0] RA,
	input [4:0] RB, 
	input [4:0] RW,
	input [31:0] BusW,
	output reg [31:0] BusA,
	output reg [31:0] BusB
	); 
	
	reg [31:0] registers[31:0];
	
	initial begin
	 registers[0]=32'h3;
	 registers[1]=32'h3;
	 registers[2]=32'h3;

	end
	

	always @(posedge clk) begin	 
		if(en == 1) begin
			BusA = registers[RA];
			BusB = registers[RB];
				
		end	
		if (enWB == 1) begin
			if(RegWr==1) begin
					registers[RW] = BusW;
			end				
		end
	end
endmodule



//*****************************************



//EX stage 
module ALU(
	input en,
    input [31:0] operand1,
    input [31:0] operand2,
    input [2:0] ALUOp,
    output reg [31:0] result,
    output reg zero,
    output reg negative,
    output reg carry
);
	always @(*) begin
		if (en == 1) begin
	
	        carry = 0;
	        case (ALUOp)
	            3'b000: result = operand1 & operand2; // AND operation
				
	            3'b001: begin // ADD operation
	                result = operand1 + operand2;
	                if (operand1 > ~operand2) carry = 1; // carry in case of addition
	            end
				
	            3'b010: begin // SUB operation
	                result = operand1 - operand2;
	                if (operand1 < operand2) carry = 1; // carry in case of subtraction (no borrow)
	            end	
				
	            3'b011: begin // CMP operation
	                result = operand1 - operand2;
	                carry = (operand1 < operand2) ? 1'b1 : 1'b0; // carry in case of subtraction (no borrow)
	            end
				
	            3'b100: result = operand1 << operand2; // SLL operation	 
				
	            3'b101: result = operand1 >> operand2; // SLR operation
				
	            default: result = 32'b0; // default case, should never be reached  
					
	        endcase	
			
			// Always compute the zero and negative signals based on the result	 
			if (result == 0)
				zero = 1;
			else
				zero = 0;
			//zero = (result == 0) ? 1'b1 : 1'b0;	 
			negative = (result[31] == 1) ? 1'b1 : 1'b0; // most significant bit is sign bit
			
		end
    end

    

endmodule


//*****************************************
// Test Bench

//MEM stage
`timescale 1ns/1ps

module data_memory (
	input clk, 
	input en,
	input reset,
	input [31:0] Address,
	input [31:0] Data_in,
	input MemRd, 
	input MemWr,
	output reg [31:0] Data_out
	
	);  
	
reg [31:0] mem[1023:0];

always @(posedge clk) begin
	if(reset == 1) begin
            mem = '{1024{32'h0}};
	end
	
	if (en ==1) begin
	
		if(MemRd == 1) begin
			$display("read data from memory...");
			Data_out = mem[Address];
		end		
		
		if(MemWr == 1) begin  
			$display("write data to memory...");
			mem[Address] = Data_in;
		end	  
	end
	
  end
endmodule

//*****************************************

module Extender(
    input [13:0] in,   // 14-bit input
    input ExtOp,       // 0: unsigned extend, 1: signed extend
    output reg [31:0] out  // 32-bit output
);

    always @* begin
        if (ExtOp)
            out = { {18{in[13]}}, in}; // Signed extend
        else
            out = {18'b0, in};         // Unsigned extend
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Extender24(
    input [23:0] in,   // 14-bit input
    input ExtOp,       // 0: unsigned extend, 1: signed extend
    output reg [31:0] out  // 32-bit output
);

    always @* begin
        if (ExtOp)
            out = { {8{in[23]}}, in}; // Signed extend
        else
            out = {8'b0, in};         // Unsigned extend
    end

endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Mux4to1 (
    input [31:0] d0, // Input data 0
    input [31:0] d1, // Input data 1
    input [31:0] d2, // Input data 2
	input [31:0] d3, // Input data 3
    input  [1:0] sel, // Select input
    output reg [31:0] y // Output
);
    always @* begin
        case (sel)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
			2'b11: y = d3;
            default: y = 32'b0; // default case, should never be reached
        endcase
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module adder_32bit (
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum
); 

   always @* begin
		sum=a+b;
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Stack (
	input en,
    input clk,
    input push,
    input pop,
    input [31:0] data_in,
    output reg [31:0] data_out
);
    reg [31:0] stack_mem [0:1023]; // size of stack is 1024
    reg [9:0] sp; // stack pointer	 
	
	initial begin
		sp = 0;
	end

    always @(posedge clk) begin	
	//	if (en == 1) begin
	    	if (push) begin
	            stack_mem[sp] <= data_in; // Push data onto stack
	            sp <= sp + 1; // Increment stack pointer
	        end
			if (pop) begin
	            sp <= sp - 1; // Decrement stack pointer
	            data_out <= stack_mem[sp]; // Pop data from stack
	        end	 
		
	//	end
		
    end
endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*module ProgramCounter (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire[31:0] jumpAddress,
    output reg[31:0] pc
);


    always @(posedge clk or posedge reset) begin
        if (enable) begin
            pc <= pc + 4;
        end
        else begin
            pc <= jumpAddress;
        end
    end
endmodule

*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module ControlUnit (	
  input en, enEX,
  input [1:0] instr_type,
  input [4:0] funct,
  input stop,
  input zero,
  output reg RegSrc,
  output reg RegWrite,
  output reg ExtOp,
  output reg [1:0] ALUSrc,
  output reg MemRead,
  output reg MemWrite,
  output reg WBdata,
  output  reg [1:0] PCSrc,
  output reg [2:0] ALUOp,
  output reg pop,
  output reg push
);		 


	initial begin 
		PCSrc = 2'b00;
	end
	
	always @(enEX or zero) begin
	//	if(enEX == 1) begin
			if (instr_type == 2'b10 & funct== 5'b00100 ) begin   
				if (zero == 1) 
					PCSrc=2'b10;		
		
				else 
					PCSrc=2'b00;
			end
			
		
	//	end
		
		
	end



  always @(*) begin
    
	
	if (en == 1) begin
			// Default outputs
	    RegSrc = 0;
	    RegWrite = 0;
	    ExtOp = 1;
	    ALUSrc = 2'b01;
	    MemRead = 0;
	    MemWrite = 0;
	    WBdata = 1;
	    PCSrc = 0;
	    ALUOp = 3'b111;
	    pop = 0;
	    push = 0;
		
		
	    case(instr_type)
	      2'b00: begin // R-Type Instructions
	        RegSrc = 0;
	        RegWrite = 1;
	        ALUSrc = 2'b01;
	        WBdata = 0;
	        case(funct)
	          5'b00000: ALUOp = 3'b000; // AND
	          5'b00001: ALUOp = 3'b001; // ADD
	          5'b00010: ALUOp = 3'b010; // SUB
	          5'b00011: begin 
				  ALUOp = 3'b011;
				  RegWrite = 0; // CMP
					  end
	          default: ;
	        endcase
	      end
	      2'b10: begin // I-Type Instructions
	        ExtOp = 1;
	        ALUSrc = 2'b00;
			RegSrc = 1;
	        case(funct)
	          5'b00000: begin RegWrite = 1; ALUOp = 3'b000; WBdata = 0; // ANDI	   
				  end
	          5'b00001: begin RegWrite = 1; ALUOp = 3'b001; WBdata = 0; // ADDI	 
				  end
	          5'b00010: begin RegWrite = 1; ALUOp = 3'b001; MemRead = 1; // LW 
				  end
	          5'b00011: begin RegWrite = 0; ALUOp = 3'b001; MemWrite = 1; // SW	
				  end
	          5'b00100: begin RegWrite = 0; ALUOp = 3'b010 ; ALUSrc = 2'b01;  // BEQ	 
				  end
	          default: ;
	        endcase
	      end
	      2'b01: begin // J-Type Instructions
	        PCSrc = 2'b01; 
	        if(funct == 5'b00001) push = 1; // JAL
	      end
	      2'b11: begin // S-Type Instructions
	        RegWrite = 1;
	        	 
			WBdata = 0;
	        case(funct)
	          5'b00000: begin ALUSrc = 2'b10; ALUOp = 3'b100; // SLL  
				  end
	          5'b00001: begin ALUSrc = 2'b10; ALUOp = 3'b101;  // SLR 
				  end
	          5'b00010: begin ALUSrc = 2'b01; RegSrc = 2'b00; ALUOp = 3'b100;  // SLLV
				  end
	          5'b00011: begin ALUSrc = 2'b01; RegSrc = 2'b00; ALUOp = 3'b101; // SLRV	 
				  end
	          default: ;
	        endcase
	      end
	      default: ;
	    endcase
	
	    // handle Stop bit
	    if(stop) begin
	      pop = 1;
	      push = 0;
		  PCSrc = 2'b11;
	    end
	  end	 
  end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////	 
`timescale 1ns/1ps

module CPU ( 
	
	output zero,
	input clk, reset,
	//input [1:0] PCSrc,
	input  sel,
	
    output reg  [31:0] JTA,
    output reg [31:0] BTA,
    output reg [31:0] RA,
	output reg [31:0] NextPC,
	
	output reg [31:0]BusW,
	output reg [4:0] RB,
	output reg [31:0] PC,PC_out,instruction, 
	output reg [4:0] functionCode,
	output reg [4:0] Rs1,
	output reg [4:0] Rd,
	output reg [4:0] Rs2,
	output reg [4:0] SA	,
	output reg [1:0] Type,
	output reg stop,
	output reg [13:0] immediate14,
	output reg [23:0] immediate24,

	output reg RegSrc,
	output reg RegWrite,
	output reg ExtOp,
	output reg [1:0] ALUSrc,
	output reg MemRead,
	output reg MemWrite,
	output reg WBdata,
    output reg [1:0] PCSrc,
	output reg [2:0] ALUOp,
	output reg pop,
	output reg push,
	output reg [31:0]BusA,
	output reg [31:0]BusB,
  
	input [31:0] operand1,
	output [31:0] operand2,
	output reg [31:0] result,
	output reg negative,
	output reg carry,
	
	output reg [31:0] Data_out, 
	output reg [31:0] Ext, Ext24,
	output reg [31:0] ExtSA,	  
	output reg enIF, enID, enEX, enMEM, enWB,
	);

	reg [2:0] state;
	
	initial begin
		state = 3'b000;	
		PC = 0;	   
		NextPC = 0;
		
	end
	
	
	
	always @(posedge clk) begin	
		case (state)
			3'b000: begin  // IF
				enIF=1;
				enID=0;
				enEX=0;
				enMEM=0;
				enWB=0;
				state = 3'b001;
			end	
			//////////////////////////////////////////////////////////////////////////////////////////////////
			3'b001: begin  // ID
				enIF=0;
				enID=1;
				enEX=0;
				enMEM=0;
				enWB=0;	
				
				if (Type == 2'b01)// ckeck if its J-Type		
					state = 3'b000;	 // end instruction and back to fetch Stage
				else
					state = 3'b010;	// cotinue to Execute Stage
					
					
				//state = 3'b010;
					
				
			end	
			//////////////////////////////////////////////////////////////////////////////////////////////////
			3'b010: begin	 // EX
				enIF=0;
				enID=0;
				enEX=1;
				enMEM=0;
				enWB=0;			
				
				case (Type)
					2'b00: begin // R-Type
						if (functionCode == 5'b00011)  // if CMP
							state = 3'b000;	// go to Fetch Stage
						else
							state = 3'b100; // go to WB Stage
					end	  
					 /////////////////////////
					2'b10: begin //	 I-Type	 
						if (functionCode == 5'b00001 | functionCode == 5'b00000) //ANDI or ADDI
							state = 3'b100; // go to  WB Stage
							
						else if (functionCode == 5'b00010 | functionCode == 5'b00011) //LW  or SW
							state = 3'b011;	 // go to MEM Stage	
							
						else if (functionCode == 5'b00100)  // BEQ
							state = 3'b000;	 // go to fetch Stage	
					end	 
					/////////////////////////////
					
					2'b11: begin   // S-Type   
						state = 3'b100; // go to WB Stage
					end	
				endcase	
				//state = 3'b011;
				
					
			end	
			//////////////////////////////////////////////////////////////////////////////////////////////////
			
			3'b011: begin	   // MEM	
				enIF=0;
				enID=0;
				enEX=0;
				enMEM=1;
				enWB=0;
				
				if (functionCode == 5'b00011) //SW
					state = 3'b000; // go to  Fetch Stage
				else  // LW
					state = 3'b100;	// go to WB Stage 
					
				//state = 3'b100;
				
			end						 
			
			//////////////////////////////////////////////////////////////////////////////////////////////////
			3'b100: begin	   //WB	
				enIF=0;
				enID=0;
				enEX=0;
				enMEM=0;
				enWB=1;
				state = 3'b000;
			end				
			
		endcase		 
		
		
			 
	end				 
	
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////		
	//IF
		
	Mux4to1 pcreg(.d0(NextPC),.d1(JTA),.d2(BTA),.d3(RA),.sel(PCSrc),.y(PC_out));//mux before PC	
	
	always @(posedge clk) begin		
		if(enIF == 1)	 begin 
			PC = PC_out;	
		end
			 
	end

	//PC_selector PC1(.PC_in(PC_out),.output1(PC));
	
	
	InstructionMemory  im(.address(PC), .instruction(instruction), .functionCode(functionCode),
                         .Rs1(Rs1), .Rs2(Rs2), .Rd(Rd), .Type(Type), .stop(stop),
                         .immediate14(immediate14), .immediate24(immediate24), .SA(SA));
	
						 
	///////////////////////////////////////////////////////////////////////////////////////////////////					 
	// ID	
	
	// increment the pc after fetch the instruction
		always @(posedge clk) begin	 
			if (enID == 1)begin
				NextPC = PC + 1;
			end
		end
	
	Mux2to1  src(.d0(Rs2),.d1(Rd),.sel(RegSrc),.y(RB)); //mux before REgister File
	
	
	// stack with stack pointer inside it
	Stack st(.en(enID), .clk(clk), .push(push), .pop(pop), .data_in(NextPC), .data_out(RA));
	
	// control unit
	ControlUnit  control(
	.enEX(enEX),
	.en(enID),
	.instr_type(Type),
    .funct(functionCode),
    .stop(stop),
    .zero(zero),
    .RegSrc(RegSrc),
    .RegWrite(RegWrite),
    .ExtOp(ExtOp),
    .ALUSrc(ALUSrc),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .WBdata(WBdata),
    .PCSrc(PCSrc),
    .ALUOp(ALUOp),
    .pop(pop),
    .push(push)
	
	);	
	
	
	
	// register file
   	Register_File  RF (	
	   	.enWB(enWB),
	   	.en(enID),
        .clk(clk),
        .reset(reset),
        .RegWr(RegWrite),
        .RA(Rs1),
        .RB(RB),
        .RW(Rd),
        .BusW(BusW),
        .BusA(BusA),
        .BusB(BusB)
    ); 	  
	
	Extender  ex(immediate14,ExtOp,Ext);//extender   
	
	Extender24  ex2(immediate24,ExtOp,Ext24);//extender 
	
	Extender5  ex3(SA,ExtSA);//extender5  
	
	adder_32bit add(.a(NextPC),.b(Ext),.sum(BTA));
	
	adder_32bit add2(.a(PC),.b(Ext24),.sum(JTA));
	
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	// EX
	
	Mux3to1  mu(Ext,BusB,ExtSA,ALUSrc,operand2); // mux before ALU
	
	
    ALU  uutt (
		.en(enEX),
        .operand1(BusA), 
        .operand2(operand2), 
        .ALUOp(ALUOp), 
        .result(result), 
        .zero(zero),
        .negative(negative),
        .carry(carry)
    );
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	// MEM
    data_memory DM (
		.en(enMEM),
        .clk(clk), 
        .reset(reset), 
        .Address(result), 
        .Data_in(BusB), 
        .MemRd(MemRead),
        .MemWr(MemWrite),
        .Data_out(Data_out)
    );
	
	
	Mux2to1 n(.d0(result),.d1(Data_out),.sel(WBdata),.y(BusW));	//last mux	 
	
	
	
	
	
	
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module multiCycle_tb;
	
  wire [31:0] NextPC;
  wire [31:0] JTA;
  wire [31:0] BTA;
  wire [31:0] RA;
  
  wire zero;
  reg clk;
  reg reset;
  wire  [1:0] PCSrc;
  reg [31:0]BusW;
  reg sel;
  reg RegSrc;
  wire [31:0] PC,PC_out,instruction;
  wire [4:0] functionCode;
  wire [4:0] Rs1;
  wire [4:0] Rd;
  wire [4:0] Rs2;
  wire [4:0] SA;
  wire [1:0] Type;
  reg stop;
  wire [13:0] immediate14;
  wire [23:0] immediate24;

  
  wire [4:0] RB;
  wire RegWrite;
  wire ExtOp;
  wire [1:0] ALUSrc;
  wire MemRead;
  wire MemWrite;
  wire WBdata;
  wire [2:0] ALUOp;
  wire pop;
  wire push;
  
  wire [31:0]BusA;
  wire [31:0]BusB;

  wire [31:0]result;

  reg negative;
  reg carry;
  wire [31:0] Data_out;
  wire [31:0] Ext, Ext24;
  wire [31:0] operand2;
  wire [31:0] ExtSA;	
  wire enIF, enID, enEX, enMEM, enWB;
  // Instantiate the module under test
	  
  CPU ut (
    .sel(sel),
  	.PCSrc(PCSrc),
    .clk(clk),
    .reset(reset),
    .instruction(instruction),
	.PC(PC),
    .PC_out(PC_out),
    .functionCode(functionCode),
    .Rs1(Rs1),
    .Rs2(Rs2),
    .Rd(Rd),
    .Type(Type),
    .immediate14(immediate14),
    .immediate24(immediate24),
    .SA(SA)	,
	.ExtSA(ExtSA),
	
	.RB(RB),
    .stop(stop),
    .zero(zero),
    .RegSrc(RegSrc),
    .RegWrite(RegWrite),
    .ExtOp(ExtOp),
    .ALUSrc(ALUSrc),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .WBdata(WBdata),
    .ALUOp(ALUOp),
    .pop(pop),
    .push(push),
	.BusA(BusA),
	.BusB(BusB),
	.BusW(BusW),
	
	
    .operand1(BusA), 
    .operand2(operand2), 
    .result(result),  
    .negative(negative),
    .carry(carry), 
	.Data_out(Data_out)	,
	.Ext(Ext),
	.Ext24(Ext24),
	.NextPC(NextPC),
	.JTA(JTA),
	.BTA(BTA),
	.RA(RA),
	.enIF(enIF),
	.enID(enID),
	.enEX(enEX),
	.enMEM(enMEM),
	.enWB(enWB)
	
  );

  initial begin
    // Initialize inputs
    clk = 1'b0;
    reset = 1'b0;
//	NextPC=32'h0;
	//BTA = 32'h0;
	//JTA=32'h1; 
    // Generate clock
    forever begin
      #5 clk = ~clk;
    end
	
  end							

  // Test Scenario 
  initial begin
 	
  //  #10 NextPC = NextPC + 32'h1; // Reset signal 
	
//	#20 NextPC = NextPC + 32'h1; // Reset signal	
  end
	
    // Finish testing
   
 
	  
  // Monitor outputs
  initial begin
    $monitor($time, "  instruction=%h PC_out=%h functionCode=%h Rs1=%h Rs2=%h Rd=%h Type=%h stop=%b immediate14=%h immediate24=%h SA=%h\n",
            instruction, PC_out, functionCode, Rs1, Rs2, Rd, Type, stop, immediate14, immediate24, SA);
  $monitor($time, "funct=$b Type=%b  RegSrc=%b RegWrite=%b ExtOp=%b ALUSrc=%b MemRead=%b MemWrite=%b WBdata=%b stop=%b PCSrc=%b ALUOp=%b pop=%b push=%b\n",
            functionCode,Type,RegSrc, RegWrite, ExtOp, ALUSrc, MemRead, MemWrite, WBdata, stop, PCSrc, ALUOp, pop,push);	   
   
    #400 $finish;
  end
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
