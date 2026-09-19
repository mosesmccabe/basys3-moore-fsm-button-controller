`timescale 1ns / 1ps
// Day 10 top: three independent button conditioners + Day 9 Moore FSM.
module fsm_controller_top #(
    parameter integer STABLE_CYCLES = 1_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic start_button_async,
    input  logic finished_button_async,
    input  logic clear_button_async,
    output logic busy,
    output logic done
);
    logic start_pulse;
    logic finished_pulse;
    logic clear_pulse;

    button_conditioner #(
        .STABLE_CYCLES(STABLE_CYCLES)
    ) START_COND (
        .clk          (clk),
        .rst          (rst),
        .button_async (start_button_async),
        .button_pulse (start_pulse)
    );

    button_conditioner #(
        .STABLE_CYCLES(STABLE_CYCLES)
    ) FINISHED_COND (
        .clk          (clk),
        .rst          (rst),
        .button_async (finished_button_async),
        .button_pulse (finished_pulse)
    );

    button_conditioner #(
        .STABLE_CYCLES(STABLE_CYCLES)
    ) CLEAR_COND (
        .clk          (clk),
        .rst          (rst),
        .button_async (clear_button_async),
        .button_pulse (clear_pulse)
    );

    simple_fsm FSM (
        .clk      (clk),
        .rst      (rst),
        .start    (start_pulse),
        .finished (finished_pulse),
        .clear    (clear_pulse),
        .busy     (busy),
        .done     (done)
    );
endmodule
