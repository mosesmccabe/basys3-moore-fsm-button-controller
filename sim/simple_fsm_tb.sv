`timescale 1ns / 1ps
// Day 9 FSM-only simulation: exercise all transitions and state holds.
// This is a cleaned-up reproduction of the stimulus discussed in the lesson.
module simple_fsm_tb;
    logic clk;
    logic rst;
    logic start;
    logic finished;
    logic clear;
    logic busy;
    logic done;

    simple_fsm DUT (
        .clk (clk), .rst (rst), .start (start),
        .finished (finished), .clear (clear),
        .busy (busy), .done (done)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst = 1'b1;
        start = 1'b0;
        finished = 1'b0;
        clear = 1'b0;
        #20;
        rst = 1'b0;
        #20; // IDLE hold

        start = 1'b1; #10; // IDLE -> RUN
        start = 1'b0; #20; // RUN hold

        finished = 1'b1; #10; // RUN -> DONE
        finished = 1'b0; #20; // DONE hold

        clear = 1'b1; #10; // DONE -> IDLE
        clear = 1'b0; #20; // IDLE hold
        $finish;
    end
endmodule
