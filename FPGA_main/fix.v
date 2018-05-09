    wire digit3_is0 = (wdata % 10000)/1000 == 0;
	wire digit3_is1 = ((wdata % 10000)/1000 == 1) & (digit3_is0 == 0);
	wire digit3_is2 = ((wdata % 10000)/1000 == 2) & (digit3_is1 == 0);
	wire digit3_is3 = ((wdata % 10000)/1000 == 3) & (digit3_is2 == 0);
	wire digit3_is4 = ((wdata % 10000)/1000 == 4) & (digit3_is3 == 0);
	wire digit3_is5 = ((wdata % 10000)/1000 == 5) & (digit3_is4 == 0);
	wire digit3_is6 = ((wdata % 10000)/1000 == 6) & (digit3_is5 == 0);
	wire digit3_is7 = ((wdata % 10000)/1000 == 7) & (digit3_is6 == 0);
	wire digit3_is8 = ((wdata % 10000)/1000 == 8) & (digit3_is7 == 0);
	wire digit3_is9 = ((wdata % 10000)/1000 == 9) & (digit3_is8 == 0);
	
	wire digit2_is0 = (wdata % 1000)/100 == 0;
	wire digit2_is1 = ((wdata % 1000)/100 == 1) & (digit2_is0 == 0);
	wire digit2_is2 = ((wdata % 1000)/100 == 2) & (digit2_is1 == 0);
	wire digit2_is3 = ((wdata % 1000)/100 == 3) & (digit2_is2 == 0);
	wire digit2_is4 = ((wdata % 1000)/100 == 4) & (digit2_is3 == 0);
	wire digit2_is5 = ((wdata % 1000)/100 == 5) & (digit2_is4 == 0);
	wire digit2_is6 = ((wdata % 1000)/100 == 6) & (digit2_is5 == 0);
	wire digit2_is7 = ((wdata % 1000)/100 == 7) & (digit2_is6 == 0);
	wire digit2_is8 = ((wdata % 1000)/100 == 8) & (digit2_is7 == 0);
	wire digit2_is9 = ((wdata % 1000)/100 == 9) & (digit2_is8 == 0);
	
	wire digit1_is0 = (wdata % 100)/10 == 0;
	wire digit1_is1 = ((wdata % 100)/10 == 1) & (digit1_is0 == 0);
	wire digit1_is2 = ((wdata % 100)/10 == 2) & (digit1_is1 == 0);
	wire digit1_is3 = ((wdata % 100)/10 == 3) & (digit1_is2 == 0);
	wire digit1_is4 = ((wdata % 100)/10 == 4) & (digit1_is3 == 0);
	wire digit1_is5 = ((wdata % 100)/10 == 5) & (digit1_is4 == 0);
	wire digit1_is6 = ((wdata % 100)/10 == 6) & (digit1_is5 == 0);
	wire digit1_is7 = ((wdata % 100)/10 == 7) & (digit1_is6 == 0);
	wire digit1_is8 = ((wdata % 100)/10 == 8) & (digit1_is7 == 0);
	wire digit1_is9 = ((wdata % 100)/10 == 9) & (digit1_is8 == 0);
	
	wire digit0_is0 = wdata % 10 == 0;
	wire digit0_is1 = (wdata % 10 == 1) & (digit1_is0 == 0);
	wire digit0_is2 = (wdata % 10 == 2) & (digit1_is1 == 0);
	wire digit0_is3 = (wdata % 10 == 3) & (digit1_is2 == 0);
	wire digit0_is4 = (wdata % 10 == 4) & (digit1_is3 == 0);
	wire digit0_is5 = (wdata % 10 == 5) & (digit1_is4 == 0);
	wire digit0_is6 = (wdata % 10 == 6) & (digit1_is5 == 0);
	wire digit0_is7 = (wdata % 10 == 7) & (digit1_is6 == 0);
	wire digit0_is8 = (wdata % 10 == 8) & (digit1_is7 == 0);
	wire digit0_is9 = (wdata % 10 == 9) & (digit1_is8 == 0);


