`timescale 1ns / 1ps

module tb_TopPipeline;

    reg clk;
    reg rst;
wire [1023:0] reg_dump;
    Top_Pipeline uut (
        .clk(clk),
        .rst(rst),
        .reg_dump(reg_dump) 
    );
    
    reg[1023:0] dump_reg;
always @(*)begin
dump_reg=reg_dump;
end

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;

        // Hold reset for few cycles
        #20 rst = 0;

    $monitor("x0=%0d x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d x6=%0d   x7=%0d x8=%0d x9=%0d",
             dump_reg[32*0 +: 32],
             dump_reg[32*1 +: 32],
             dump_reg[32*2 +: 32],
             dump_reg[32*3 +: 32],
             dump_reg[32*4 +: 32],
             dump_reg[32*5 +: 32],
             dump_reg[32*6 +: 32],
             dump_reg[32*7 +: 32],
             dump_reg[32*8 +: 32],
             dump_reg[32*9 +: 32]
             );

        // Run simulation for 1000ns
        #2000;
        $finish;
    end

  always #5 clk = ~clk; // 10ns clock

endmodule
