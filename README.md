# Basys 3 Moore FSM Button Controller

**FPGA project | SystemVerilog · Vivado · Basys 3 (Artix-7)**

A three-state **Moore finite-state machine** controlled by three independently conditioned pushbuttons. A START event enters RUN; a FINISHED event enters DONE; and a CLEAR event returns the controller to IDLE. Two LEDs indicate the current operating mode. The project progresses from an FSM-only simulation and synthesis exercise  to an integrated, programmed FPGA implementation .

**Status:** Behavioral simulation, synthesis, and six planned on-board functional checks completed. The user's  Vivado report showed **75 slice registers**, matching the pre-synthesis estimate.

## Hardware behavior

| Current state | Event | Next state | LD0 (`busy`) | LD1 (`done`) |
|---|---|---|---|---|
| IDLE | No START | IDLE | OFF | OFF |
| IDLE | START | RUN | ON | OFF |
| RUN | No FINISHED, including CLEAR or START | RUN | ON | OFF |
| RUN | FINISHED | DONE | OFF | ON |
| DONE | No CLEAR | DONE | OFF | ON |
| DONE | CLEAR | IDLE | OFF | OFF |

Reset is active-high and **synchronous** in the RTL: the FSM enters IDLE when reset is sampled at a clock rising edge.

## Architecture

```text
BTNR (START)    -> START_COND    -- start_pulse ----+
BTNU (FINISHED) -> FINISHED_COND -- finished_pulse -+--> simple_fsm --> busy (LD0)
BTNL (CLEAR)    -> CLEAR_COND    -- clear_pulse ----+               --> done (LD1)

Each button_conditioner:
  button_async -> sync_2ff -> debounce -> edge_detect -> one-clock pulse

Shared clock: 100 MHz board oscillator -> IBUF -> BUFG -> all synchronous blocks
Reset: center button -> synchronous reset input of the stateful blocks
```

`simple_fsm` implements three distinct RTL blocks: an `always_ff` state register, an `always_comb` next-state block, and an `always_comb` Moore output block. The FSM ignores event inputs that are not relevant in its current state. Each button conditioner is a **separate hardware instance**, with its own synchronizer, debounce counter, and edge detector.

![Day 9 FSM architecture](docs/day9_fsm_fundamentals.png)

## Moore vs. Mealy

This project uses a **Moore FSM**: `busy` and `done` depend only on `state`, not directly on the asynchronous buttons or event inputs. The FSM-only exercise also contrasted Moore output logic with Mealy output logic, which can depend on both state and inputs.

![Moore vs Mealy FSM comparison](docs/day9_moore_vs_mealy.png)

## Source files

```text
rtl/
  simple_fsm.sv              # IDLE -> RUN -> DONE -> IDLE Moore FSM
  sync_2ff.sv                # two-stage synchronizer
  debounce.sv                # parameterized stability counter
  edge_detect.sv             # one-cycle rising-edge pulse
  button_conditioner.sv      # reusable chain of the above three modules
  fsm_controller_top.sv      # 3 conditioners + FSM
sim/
  simple_fsm_tb.sv           # Day 9 FSM-only testbench
  fsm_controller_top_tb.sv   # Day 10 integrated testbench
constraints/
  fsm_controller_basys3.xdc  # physical pins and 100 MHz timing constraint
docs/
  *.png                      # course diagrams and actual Vivado screenshots
```

The reusable conditioning modules are included directly in this repository so the project does not depend on a separate Week 2 source directory. `sim/simple_fsm_tb.sv` is a cleaned-up reproduction of the Day 9 stimulus; the integrated testbench reflects the Day 10 test sequence.

## Simulation

In Vivado, add `rtl/*.sv` as **Design Sources**, add `sim/*.sv` as **Simulation Sources**, and run the desired simulation with its corresponding simulation top. The FSM-only testbench checks reset, the three transitions, and hold behavior. View `DUT.state` and `DUT.next_state` to see next-state logic respond between edges while the state register updates on the next edge.

![Day 9 waveform showing state and next_state](docs/day9_fsm_state_next_state_waveform.png)

![Day 9 waveform showing busy and done](docs/day9_fsm_output_waveform.png)

The Day 10 integrated simulation sets `STABLE_CYCLES=5` so that debounce tests finish quickly. It applies a deliberately short START pulse (rejected), a valid START press (IDLE→RUN), FINISHED (RUN→DONE), and CLEAR (DONE→IDLE), with stable input releases between events. The conditioner outputs and FSM state are visible in the waveform.

![Day 10 integrated simulation](docs/day10_integrated_simulation.png)

The simulation's short-pulse test does not substitute for modeling analog metastability; ordinary RTL simulation does not resolve that physical phenomenon.

## Synthesis and FPGA resources

Synthesize `fsm_controller_top` as the design top using the default `STABLE_CYCLES=1_000_000` for the hardware configuration. At a 100 MHz clock rate, this corresponds to about 10 ms of accepted button stability. With the supplied debounce counter, `$clog2(1_000_001)` gives a 20-bit counter.

| Submodule | Slice registers reported |
|---|---:|
| START_COND | 24 |
| FINISHED_COND | 24 |
| CLEAR_COND | 24 |
| FSM | 3 |
| **Total** | **75** |

Vivado reported **58 slice LUTs, 75 slice registers, 7 bonded IOBs and 1 BUFGCTRL** in the Day 10 synthesis utilization report. The three-state enum has a 2-bit **RTL** representation, but Vivado recognized the FSM and synthesized a 3-register **one-hot** implementation. The exact resource numbers are observed for this project/settings, not a universal guarantee across tool options.

![Day 9 one-hot FSM synthesis](docs/day9_onehot_synthesis.png)

![Day 10 integrated synthesized schematic](docs/day10_integrated_synthesis.png)

![Day 10 utilization report](docs/day10_utilization_75_ff.png)

## Basys 3 pin mapping

| Top-level port | Board control | FPGA package pin |
|---|---|---|
| `clk` | 100 MHz oscillator | W5 |
| `rst` | Center pushbutton (BTNC) | U18 |
| `start_button_async` | Right pushbutton (BTNR) | T17 |
| `finished_button_async` | Up pushbutton (BTNU) | T18 |
| `clear_button_async` | Left pushbutton (BTNL) | W19 |
| `busy` | LD0 | U16 |
| `done` | LD1 | E19 |

The XDC uses `LVCMOS33` and a `create_clock` constraint with a **10.000 ns** period. Select the Basys 3 board in Vivado or the Artix-7 FPGA part **XC7A35T-1CPG236C**. Enable only this project's XDC for the top-level implementation; disable older, unrelated constraint files.

## On-board functional checks

The user reported that all six planned Basys 3 hardware checks passed: RESET entered IDLE (both LEDs off); START entered RUN (LD0 on); CLEAR while in RUN was ignored; FINISHED entered DONE (LD1 on); and CLEAR in DONE returned to IDLE (both LEDs off). A held START button in RUN did not create an unintended transition. This repository includes Vivado screenshots but **no Day 10 hardware video**, since none was provided for packaging.

## Implementation notes

- Use `clk` as the only clock; **button pulses are enable/event inputs, not generated clocks**.
- The two-stage synchronizer reduces the risk that metastability propagates; it does not eliminate metastability and is not analog-modeled by behavioral simulation.
- The switch/button input is synchronized and debounced independently in each conditioner.
- The physical reset button is passed directly to the **synchronous** reset inputs in this teaching design. A future production-oriented revision should address asynchronous reset-button conditioning/reset-release requirements and synchronizer placement attributes such as `ASYNC_REG`.
- The `default` branch provides an RTL recovery value for an unexpected enum state. Do not assume that synthesized safe-state recovery is guaranteed after automatic FSM re-encoding without explicitly verifying the implementation/tool settings.

