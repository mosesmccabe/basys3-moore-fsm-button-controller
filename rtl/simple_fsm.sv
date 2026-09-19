`timescale 1ns / 1ps
// Day 9: three-state Moore FSM, synchronous active-high reset.
module simple_fsm (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic finished,
    input  logic clear,
    output logic busy,
    output logic done
);
    typedef enum logic [1:0] {
        IDLE,
        RUN,
        DONE
    } state_t;

    state_t state;
    state_t next_state;

    // 1. State register
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // 2. Next-state logic: hold current state unless a transition is enabled
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = RUN;
            end
            RUN: begin
                if (finished)
                    next_state = DONE;
            end
            DONE: begin
                if (clear)
                    next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // 3. Moore output logic
    always_comb begin
        busy = 1'b0;
        done = 1'b0;
        case (state)
            IDLE: begin
                // Default outputs represent IDLE.
            end
            RUN: begin
                busy = 1'b1;
            end
            DONE: begin
                done = 1'b1;
            end
            default: begin
                busy = 1'b0;
                done = 1'b0;
            end
        endcase
    end
endmodule
