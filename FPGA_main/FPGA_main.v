// create module
module FPGA_main (
	input wire clk, // 50MHz input clock
	input wire switch,
	output wire LED // LED ouput
);

// create a binary counter
	reg [31:0] cnt; // 32-bit counter

initial begin

cnt <= 32'h00000000; // start at zero

end

always @(posedge clk) begin

cnt <= cnt + 1; // count up

end

//assign LED to 25th bit of the counter to blink the LED at a few Hz
assign LED = cnt[24] & switch;

endmodule