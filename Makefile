# ============================================================
#  RISC-V ALU / Register File — Verilator build & test flow
# ============================================================

# Default top module and testbench
TOP      ?= alu_tb
RTL      ?= rtl/alu.sv
TB       ?= tb/alu_tb.sv
BIN      := obj_dir/V$(TOP)

# Verilator flags
VFLAGS   := --binary --timing --Wall --top-module $(TOP)

.PHONY: all build run wave regress synth clean

# ---------- default ----------
all: build

# ---------- build ----------
build:
	verilator $(VFLAGS) $(RTL) $(TB)

# ---------- run ----------
run: build
	./$(BIN)

# ---------- wave (requires --trace; add it if you want VCD) ----------
wave: build
	./$(BIN) +trace
	@echo "Open the generated .vcd with: gtkwave dump.vcd"

# ---------- regression (runs the python test runner) ----------
regress:
	python3 scripts/run_tests.py

# ---------- synth -----------
synth:
	yosys scripts/synth.ys

# ---------- clean ----------
clean:
	rm -rf obj_dir
