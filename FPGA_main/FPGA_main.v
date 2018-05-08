// create module
module FPGA_main (
	input wire clk, // 50MHz input clock
	output wire HEX3_pos0,
	output wire HEX3_pos1,
	output wire HEX3_pos2,
	output wire HEX3_pos3,
	output wire HEX3_pos4,
	output wire HEX3_pos5,
	output wire HEX3_pos6,
	
	output wire HEX2_pos0,
	output wire HEX2_pos1,
	output wire HEX2_pos2,
	output wire HEX2_pos3,
	output wire HEX2_pos4,
	output wire HEX2_pos5,
	output wire HEX2_pos6,
	
	output wire HEX1_pos0,
	output wire HEX1_pos1,
	output wire HEX1_pos2,
	output wire HEX1_pos3,
	output wire HEX1_pos4,
	output wire HEX1_pos5,
	output wire HEX1_pos6,
	
	output wire HEX0_pos0,
	output wire HEX0_pos1,
	output wire HEX0_pos2,
	output wire HEX0_pos3,
	output wire HEX0_pos4,
	output wire HEX0_pos5,
	output wire HEX0_pos6
);

    reg halt = 0;
	 reg count = 0;

    // PC
    reg [15:0]pc  = 16'h0000;
	 
    // read from memory
    wire [15:0]ins;

	// write to memory
	wire en;
	wire [15:0]waddr;
	wire [15:0]wdata;

	// load/store data at ra
	wire [15:0]raAddr;
	wire [15:0]raData;

   mem mem(clk, pc, ins, 
 		raAddr, raData,
		en, waddr, wdata);

   // register file
   reg [15:0]rf[0:15];

	wire [3:0]opcode = ins[15:12];
	wire [3:0]xop = ins[7:4];
	
	// encoding
	wire isAdd = (opcode == 0);
	wire isMul = (opcode == 1);
	
	wire isMovl = (opcode == 8);

	wire isJz  = (opcode == 14) & (xop == 0);
	wire isJmp = (opcode == 14) & (xop == 1);

	wire isLd = (opcode == 15) & (xop == 0);
	wire isSt = (opcode == 15) & (xop == 1);

	// get operands
	wire [3:0]a = ins[11:8];
	wire [3:0]b = isAdd | isMul ? xop : 0;
	wire [3:0]t = ins[3:0];

	// get values of operands
	wire [7:0]ri = ins[11:4];
	wire [15:0]ra = a == 16'h0000 ? 16'h0000 : rf[a];
	wire [15:0]rb = b == 16'h0000 ? 16'h0000 : rf[b];
	wire [15:0]rt = t == 16'h0000 ? 16'h0000 : rf[t];
	
	wire isRecognized;
	wire shouldJump;
	wire shoudChangeReg;
	wire shouldDisplay;
	
	// get values of digits 
	wire digit3_is0 = (wdata % 10000)/1000 == 0;
	wire digit3_is1 = (wdata % 10000)/1000 == 1;
	wire digit3_is2 = (wdata % 10000)/1000 == 2;
	wire digit3_is3 = (wdata % 10000)/1000 == 3;
	wire digit3_is4 = (wdata % 10000)/1000 == 4;
	wire digit3_is5 = (wdata % 10000)/1000 == 5;
	wire digit3_is6 = (wdata % 10000)/1000 == 6;
	wire digit3_is7 = (wdata % 10000)/1000 == 7;
	wire digit3_is8 = (wdata % 10000)/1000 == 8;
	wire digit3_is9 = (wdata % 10000)/1000 == 9;
	
	wire digit2_is0 = (wdata % 1000)/100 == 0;
	wire digit2_is1 = (wdata % 1000)/100 == 1;
	wire digit2_is2 = (wdata % 1000)/100 == 2;
	wire digit2_is3 = (wdata % 1000)/100 == 3;
	wire digit2_is4 = (wdata % 1000)/100 == 4;
	wire digit2_is5 = (wdata % 1000)/100 == 5;
	wire digit2_is6 = (wdata % 1000)/100 == 6;
	wire digit2_is7 = (wdata % 1000)/100 == 7;
	wire digit2_is8 = (wdata % 1000)/100 == 8;
	wire digit2_is9 = (wdata % 1000)/100 == 9;
	
	wire digit1_is0 = (wdata % 100)/10 == 0;
	wire digit1_is1 = (wdata % 100)/10 == 1;
	wire digit1_is2 = (wdata % 100)/10 == 2;
	wire digit1_is3 = (wdata % 100)/10 == 3;
	wire digit1_is4 = (wdata % 100)/10 == 4;
	wire digit1_is5 = (wdata % 100)/10 == 5;
	wire digit1_is6 = (wdata % 100)/10 == 6;
	wire digit1_is7 = (wdata % 100)/10 == 7;
	wire digit1_is8 = (wdata % 100)/10 == 8;
	wire digit1_is9 = (wdata % 100)/10 == 9;
	
	wire digit0_is0 = wdata % 10 == 0;
	wire digit0_is1 = wdata % 10 == 1;
	wire digit0_is2 = wdata % 10 == 2;
	wire digit0_is3 = wdata % 10 == 3;
	wire digit0_is4 = wdata % 10 == 4;
	wire digit0_is5 = wdata % 10 == 5;
	wire digit0_is6 = wdata % 10 == 6;
	wire digit0_is7 = wdata % 10 == 7;
	wire digit0_is8 = wdata % 10 == 8;
	wire digit0_is9 = wdata % 10 == 9;
	
	// change LED display
	assign HEX3_pos0 = shouldDisplay & ( digit3_is2 | digit3_is3 | digit3_is5 | digit3_is6 | digit3_is7 | digit3_is8 | digit3_is9 );
	assign HEX3_pos1 = shouldDisplay & ( digit3_is1 | digit3_is2 | digit3_is3 | digit3_is4 | digit3_is7 | digit3_is8 | digit3_is9 );
	assign HEX3_pos2 = shouldDisplay & ( digit3_is1 | digit3_is3 | digit3_is4 | digit3_is5 | digit3_is6 | digit3_is7 | digit3_is8 | digit3_is9 );
	assign HEX3_pos3 = shouldDisplay & ( digit3_is2 | digit3_is3 | digit3_is5 | digit3_is6 | digit3_is8 | digit3_is9 );
	assign HEX3_pos4 = shouldDisplay & ( digit3_is2 | digit3_is6 | digit3_is8 );
	assign HEX3_pos5 = shouldDisplay & ( digit3_is4 | digit3_is5 | digit3_is6 | digit3_is8 | digit3_is9 );
	assign HEX3_pos6 = shouldDisplay & ( digit3_is2 | digit3_is3 | digit3_is4 | digit3_is5 | digit3_is6 | digit3_is8 | digit3_is9 );
	
	assign HEX2_pos0 = shouldDisplay & ( digit2_is2 | digit2_is3 | digit2_is5 | digit2_is6 | digit2_is7 | digit2_is8 | digit2_is9 );
   assign HEX2_pos1 = shouldDisplay & ( digit2_is1 | digit2_is2 | digit2_is3 | digit2_is4 | digit2_is7 | digit2_is8 | digit2_is9 );
   assign HEX2_pos2 = shouldDisplay & ( digit2_is1 | digit2_is3 | digit2_is4 | digit2_is5 | digit2_is6 | digit2_is7 | digit2_is8 | digit2_is9 );
   assign HEX2_pos3 = shouldDisplay & ( digit2_is2 | digit2_is3 | digit2_is5 | digit2_is6 | digit2_is8 | digit2_is9 );
   assign HEX2_pos4 = shouldDisplay & ( digit2_is2 | digit2_is6 | digit2_is8 );
   assign HEX2_pos5 = shouldDisplay & ( digit2_is4 | digit2_is5 | digit2_is6 | digit2_is8 | digit2_is9 );
   assign HEX2_pos6 = shouldDisplay & ( digit2_is2 | digit2_is3 | digit2_is4 | digit2_is5 | digit2_is6 | digit2_is8 | digit2_is9 );

   assign HEX1_pos0 = shouldDisplay & ( digit1_is2 | digit1_is3 | digit1_is5 | digit1_is6 | digit1_is7 | digit1_is8 | digit1_is9 );
   assign HEX1_pos1 = shouldDisplay & ( digit1_is1 | digit1_is2 | digit1_is3 | digit1_is4 | digit1_is7 | digit1_is8 | digit1_is9 );
   assign HEX1_pos2 = shouldDisplay & ( digit1_is1 | digit1_is3 | digit1_is4 | digit1_is5 | digit1_is6 | digit1_is7 | digit1_is8 | digit1_is9 );
   assign HEX1_pos3 = shouldDisplay & ( digit1_is2 | digit1_is3 | digit1_is5 | digit1_is6 | digit1_is8 | digit1_is9 );
   assign HEX1_pos4 = shouldDisplay & ( digit1_is2 | digit1_is6 | digit1_is8 );
   assign HEX1_pos5 = shouldDisplay & ( digit1_is4 | digit1_is5 | digit1_is6 | digit1_is8 | digit1_is9 );
   assign HEX1_pos6 = shouldDisplay & ( digit1_is2 | digit1_is3 | digit1_is4 | digit1_is5 | digit1_is6 | digit1_is8 | digit1_is9 );

   assign HEX0_pos0 = shouldDisplay & ( digit0_is2 | digit0_is3 | digit0_is5 | digit0_is6 | digit0_is7 | digit0_is8 | digit0_is9 );
   assign HEX0_pos1 = shouldDisplay & ( digit0_is1 | digit0_is2 | digit0_is3 | digit0_is4 | digit0_is7 | digit0_is8 | digit0_is9 );
   assign HEX0_pos2 = shouldDisplay & ( digit0_is1 | digit0_is3 | digit0_is4 | digit0_is5 | digit0_is6 | digit0_is7 | digit0_is8 | digit0_is9 );
   assign HEX0_pos3 = shouldDisplay & ( digit0_is2 | digit0_is3 | digit0_is5 | digit0_is6 | digit0_is8 | digit0_is9 );
   assign HEX0_pos4 = shouldDisplay & ( digit0_is2 | digit0_is6 | digit0_is8 );
   assign HEX0_pos5 = shouldDisplay & ( digit0_is4 | digit0_is5 | digit0_is6 | digit0_is8 | digit0_is9 );
   assign HEX0_pos6 = shouldDisplay & ( digit0_is2 | digit0_is3 | digit0_is4 | digit0_is5 | digit0_is6 | digit0_is8 | digit0_is9 );
	
	// rhs of op
	wire [15:0]out = isAdd  ? ra + rb :
					 isMul ? ra * rb :
				    isMovl ? { {8{ri[7]}}, ri[7:0] } :
					 isJz  & ra == 16'h0000 ? rt :
					 isJmp ? rt :
					 isLd ? raData  :
					 isSt ? rt :
					 pc + 2 ; 

	// for the store operation
	assign en = isSt;
	assign raAddr = ra;
	assign waddr = ra;		 
	assign wdata = out;

	assign isRecognized = (isAdd | isMul | isMovl | isJz | isJmp | isLd | isSt);			 
	assign shouldJump = (isJz | isJmp);
	assign shouldChangeReg = (isAdd | isMul | isMovl | isLd);
	assign shouldDisplay = (shouldChangeReg & t == 0);

    always @(posedge clk) begin
		if (count == 0) begin
			pc <= ins;
		end
		else begin
			halt <= !isRecognized;
			if (halt) $finish;
			if (shouldChangeReg) rf[t] = wdata;	
			if (shouldDisplay) #1000;
			pc <= pc + 2;
			if (shouldJump) begin // jmp instruction
				pc <= out;
			end
		end
		count <= count + 1;
	end


endmodule