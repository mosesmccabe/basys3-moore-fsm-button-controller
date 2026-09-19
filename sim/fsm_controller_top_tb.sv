`timescale 1ns / 1ps
// Day 10 integrated simulation: short START rejection and 3 valid event paths.
module fsm_controller_top_tb;
    logic clk;
    logic rst;
    logic start_button_async;
    logic finished_button_async;
    logic clear_button_async;
    logic busy;
    logic done;

    fsm_controller_top #(
        .STABLE_CYCLES(5)
    ) DUT (
        .clk                   (clk),
        .rst                   (rst),
        .start_button_async    (start_button_async),
        .finished_button_async (finished_button_async),
        .clear_button_async    (clear_button_async),
        .busy                  (busy),
        .done                  (done)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        start_button_async    = 1'b0;
        finished_button_async = 1'b0;
        clear_button_async    = 1'b0;
        rst                   = 1'b1;
        #100;

        rst = 1'b0;
        #20; // Hold IDLE

        // Short START pulse: does not pass the 5-cycle debouncer
        start_button_async = 1'b1; #20;
        start_button_async = 1'b0; #20;

        // Valid START press: IDLE -> RUN
        start_button_async = 1'b1; #100;
        start_button_async = 1'b0; #100; // Hold RUN

        // Valid FINISHED press: RUN -> DONE
        finished_button_async = 1'b1; #100;
        finished_button_async = 1'b0; #100; // Hold DONE

        // Valid CLEAR press: DONE -> IDLE
        clear_button_async = 1'b1; #100;
        clear_button_async = 1'b0; #100; // Hold IDLE

        $finish;
    end
endmodule
