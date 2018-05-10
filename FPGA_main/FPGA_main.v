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
	output wire HEX0_pos6,
	
	output wire ledr9,
	output wire ledr7,
	output wire ledr6,
	output wire ledr5,
	output wire ledr4,
	output wire ledr3,
	output wire ledr2,
	output wire ledr1,
	output wire ledr0
);

    reg halt = 0;
	 reg [31:0]count = 0;

    // PC
    reg [15:0]pc = 0;
	 
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
   reg [15:0]rf[0:7];

	wire [3:0]opcode = ins[15:12];
	wire [3:0]xop = ins[7:4];
	
	// encoding
	wire isAdd = (opcode == 0);
	wire isMul = (opcode == 1);
	
	wire isCmp = (opcode == 2);
	
	wire isMovl = (opcode == 8);
	
	wire isMovPC = (opcode == 10);

	wire isJz  = (opcode == 14) & (xop == 0);
	wire isJmp = (opcode == 14) & (xop == 1);
	wire isJmpAddr = (opcode == 14) & (xop == 2);

	wire isLd = (opcode == 15) & (xop == 0);
	wire isSt = (opcode == 15) & (xop == 1);

	// get operands
	wire [3:0]a = ins[11:8];
	wire [3:0]b = isAdd | isMul ? xop : 0;
	wire [3:0]t = ins[3:0];

	// get values of operands
	wire [7:0]ri = ins[11:4];
	wire [15:0]ra = a == 0 ? 0 : rf[a];
	wire [15:0]rb = b == 0 ? 0 : rf[b];
	wire [15:0]rt = t == 0 ? 0 : rf[t];
	
	wire isRecognized;
	wire shouldJump;
	wire shoudChangeReg;
	wire shouldDisplay;
	
	// get values of digits 
	wire[3:0] digit3 = wdata/1000%10;
	wire digit3_is0 = digit3 == 0;
	wire digit3_is1 = digit3 == 1;
	wire digit3_is2 = digit3 == 2;
	wire digit3_is3 = digit3 == 3;
	wire digit3_is4 = digit3 == 4;
	wire digit3_is5 = digit3 == 5;
	wire digit3_is6 = digit3 == 6;
	wire digit3_is7 = digit3 == 7;
	wire digit3_is8 = digit3 == 8;
	wire digit3_is9 = digit3 == 9;
	
	wire[3:0] digit2 = wdata/100%10;
	wire digit2_is0 = digit2 == 0;
	wire digit2_is1 = digit2 == 1;
	wire digit2_is2 = digit2 == 2;
	wire digit2_is3 = digit2 == 3;
	wire digit2_is4 = digit2 == 4;
	wire digit2_is5 = digit2 == 5;
	wire digit2_is6 = digit2 == 6;
	wire digit2_is7 = digit2 == 7;
	wire digit2_is8 = digit2 == 8;
	wire digit2_is9 = digit2 == 9;
	
	wire[3:0] digit1 = wdata/10%10;
	wire digit1_is0 = digit1 == 0;
	wire digit1_is1 = digit1 == 1;
	wire digit1_is2 = digit1 == 2;
	wire digit1_is3 = digit1 == 3;
	wire digit1_is4 = digit1 == 4;
	wire digit1_is5 = digit1 == 5;
	wire digit1_is6 = digit1 == 6;
	wire digit1_is7 = digit1 == 7;
	wire digit1_is8 = digit1 == 8;
	wire digit1_is9 = digit1 == 9;
	
	wire[3:0] digit0 = wdata%10;
	wire digit0_is0 = digit0 == 0;
	wire digit0_is1 = digit0 == 1;
	wire digit0_is2 = digit0 == 2;
	wire digit0_is3 = digit0 == 3;
	wire digit0_is4 = digit0 == 4;
	wire digit0_is5 = digit0 == 5;
	wire digit0_is6 = digit0 == 6;
	wire digit0_is7 = digit0 == 7;
	wire digit0_is8 = digit0 == 8;
	wire digit0_is9 = digit0 == 9;
	
	// change LED display
	assign HEX3_pos0 = !(shouldDisplay & ( digit3_is0 | digit3_is2 | digit3_is3 | digit3_is5 | digit3_is6 | digit3_is7 | digit3_is8 | digit3_is9 ));
	assign HEX3_pos1 = !(shouldDisplay & ( digit3_is0 | digit3_is1 | digit3_is2 | digit3_is3 | digit3_is4 | digit3_is7 | digit3_is8 | digit3_is9 ));
	assign HEX3_pos2 = !(shouldDisplay & ( digit3_is0 | digit3_is1 | digit3_is3 | digit3_is4 | digit3_is5 | digit3_is6 | digit3_is7 | digit3_is8 | digit3_is9 ));
	assign HEX3_pos3 = !(shouldDisplay & ( digit3_is0 | digit3_is2 | digit3_is3 | digit3_is5 | digit3_is6 | digit3_is8 | digit3_is9 ));
	assign HEX3_pos4 = !(shouldDisplay & ( digit3_is0 | digit3_is2 | digit3_is6 | digit3_is8 ));
	assign HEX3_pos5 = !(shouldDisplay & ( digit3_is0 | digit3_is4 | digit3_is5 | digit3_is6 | digit3_is8 | digit3_is9 ));
	assign HEX3_pos6 = !(shouldDisplay & ( digit3_is2 | digit3_is3 | digit3_is4 | digit3_is5 | digit3_is6 | digit3_is8 | digit3_is9 ));
	
	assign HEX2_pos0 = !(shouldDisplay & ( digit2_is0 | digit2_is2 | digit2_is3 | digit2_is5 | digit2_is6 | digit2_is7 | digit2_is8 | digit2_is9 ));
   assign HEX2_pos1 = !(shouldDisplay & ( digit2_is0 | digit2_is1 | digit2_is2 | digit2_is3 | digit2_is4 | digit2_is7 | digit2_is8 | digit2_is9 ));
   assign HEX2_pos2 = !(shouldDisplay & ( digit2_is0 | digit2_is1 | digit2_is3 | digit2_is4 | digit2_is5 | digit2_is6 | digit2_is7 | digit2_is8 | digit2_is9 ));
   assign HEX2_pos3 = !(shouldDisplay & ( digit2_is0 | digit2_is2 | digit2_is3 | digit2_is5 | digit2_is6 | digit2_is8 | digit2_is9 ));
   assign HEX2_pos4 = !(shouldDisplay & ( digit2_is0 | digit2_is2 | digit2_is6 | digit2_is8 ));
   assign HEX2_pos5 = !(shouldDisplay & ( digit2_is0 | digit2_is4 | digit2_is5 | digit2_is6 | digit2_is8 | digit2_is9 ));
   assign HEX2_pos6 = !(shouldDisplay & ( digit2_is2 | digit2_is3 | digit2_is4 | digit2_is5 | digit2_is6 | digit2_is8 | digit2_is9 ));

   assign HEX1_pos0 = !(shouldDisplay & ( digit1_is0 | digit1_is2 | digit1_is3 | digit1_is5 | digit1_is6 | digit1_is7 | digit1_is8 | digit1_is9 ));
   assign HEX1_pos1 = !(shouldDisplay & ( digit1_is0 |digit1_is1 | digit1_is2 | digit1_is3 | digit1_is4 | digit1_is7 | digit1_is8 | digit1_is9 ));
   assign HEX1_pos2 = !(shouldDisplay & ( digit1_is0 |digit1_is1 | digit1_is3 | digit1_is4 | digit1_is5 | digit1_is6 | digit1_is7 | digit1_is8 | digit1_is9 ));
   assign HEX1_pos3 = !(shouldDisplay & ( digit1_is0 |digit1_is2 | digit1_is3 | digit1_is5 | digit1_is6 | digit1_is8 | digit1_is9 ));
   assign HEX1_pos4 = !(shouldDisplay & ( digit1_is0 |digit1_is2 | digit1_is6 | digit1_is8 ));
   assign HEX1_pos5 = !(shouldDisplay & ( digit1_is0 |digit1_is4 | digit1_is5 | digit1_is6 | digit1_is8 | digit1_is9 ));
   assign HEX1_pos6 = !(shouldDisplay & ( digit1_is2 | digit1_is3 | digit1_is4 | digit1_is5 | digit1_is6 | digit1_is8 | digit1_is9 ));

   assign HEX0_pos0 = !(shouldDisplay & ( digit0_is0 | digit0_is2 | digit0_is3 | digit0_is5 | digit0_is6 | digit0_is7 | digit0_is8 | digit0_is9 ));
   assign HEX0_pos1 = !(shouldDisplay & ( digit0_is0 | digit0_is1 | digit0_is2 | digit0_is3 | digit0_is4 | digit0_is7 | digit0_is8 | digit0_is9 ));
   assign HEX0_pos2 = !(shouldDisplay & ( digit0_is0 | digit0_is1 | digit0_is3 | digit0_is4 | digit0_is5 | digit0_is6 | digit0_is7 | digit0_is8 | digit0_is9 ));
   assign HEX0_pos3 = !(shouldDisplay & ( digit0_is0 | digit0_is2 | digit0_is3 | digit0_is5 | digit0_is6 | digit0_is8 | digit0_is9 ));
   assign HEX0_pos4 = !(shouldDisplay & ( digit0_is0 | digit0_is2 | digit0_is6 | digit0_is8 ));
   assign HEX0_pos5 = !(shouldDisplay & ( digit0_is0 | digit0_is4 | digit0_is5 | digit0_is6 | digit0_is8 | digit0_is9 ));
   assign HEX0_pos6 = !(shouldDisplay & ( digit0_is2 | digit0_is3 | digit0_is4 | digit0_is5 | digit0_is6 | digit0_is8 | digit0_is9 ));
	
	// rhs of op
	wire [15:0]out = isAdd  ? ra + rb :
					 isMul ? ra * rb :
					 isCmp ? ra == rb :
				    isMovl ? { {8{ri[7]}}, ri[7:0] } :
					 isMovPC ? pc :
					 isJz  & ra == 0 ? rt :
					 isJmp ? rt :
					 isJmpAddr ? rt + a :
					 isLd ? raData  :
					 isSt ? rt :
					 pc + 2 ; 
					 
	// for the store operation
	assign en = isSt;
	assign raAddr = ra;
	assign waddr = ra;		 
	assign wdata = out;

	assign isRecognized = (isAdd | isMul | isCmp | isMovl | isMovPC | isJz | isJmp | isJmpAddr | isLd | isSt);			 
	assign shouldJump = (isJz | isJmp | isJmpAddr);
	assign shouldChangeReg = (isAdd | isMul | isCmp | isMovPC | isMovl | isLd);
	assign shouldDisplay = (shouldChangeReg & t == 0);
	
	wire [15:0]nextPC = shouldJump ? out : pc + 1;
	
	assign ledr9 = shouldDisplay;
	assign ledr7 = pc[7];
	assign ledr6 = pc[6];
	assign ledr5 = pc[5];
	assign ledr4 = pc[4];
	assign ledr3 = pc[3];
	assign ledr2 = pc[2];
	assign ledr1 = pc[1];
	assign ledr0 = pc[0];

	always @(posedge clk) begin
		count <= count + 1;
		if (count[26]) begin
			halt <= !isRecognized;
			if (halt) $finish;
			if (shouldChangeReg) rf[t] = wdata;	
			pc <= nextPC;
			count <= 0;
		end
	end

endmodule