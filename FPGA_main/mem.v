module mem(input clk,
    input [15:1]raddr0, output [15:0]rdata,
    input [15:1]raddr1, output [15:0]raData,
    input wen0, input [15:0]waddr0, input [15:0]wdata0);

    reg [15:0]data[0:16'hff];

    /* Simulation -- read initial content from file */
    initial begin
        $readmemh("init_file.mif",data);
    end

    // get instruction
    assign rdata = data[raddr0];
	
    // get data at ra
    assign raData = data[raddr1];

    always @(posedge clk) begin
        if (wen0) begin
            data[waddr0] <= wdata0;
        end
    end

endmodule