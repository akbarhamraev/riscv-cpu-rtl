import subprocess
import sys


RTL = [
    "rtl/alu.sv",
    "rtl/register_file.sv",
    "rtl/imm_gen.sv",
    "rtl/control_unit.sv",
    "rtl/alu_control.sv",
    "rtl/instruction_memory.sv",
    "rtl/data_memory.sv",
    "rtl/riscv_cpu.sv",
]

TESTBENCH = [
    "tb/riscv_cpu_assertions.sv",
    "tb/riscv_cpu_tb.sv",
]


def run_command(command, name):
    print()
    print("=" * 60)
    print(name)
    print("=" * 60)
    print("[RUN]", " ".join(command))

    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )

    print(result.stdout)

    return result.returncode, result.stdout


def main():

    print("=" * 60)
    print("             RISC-V CPU REGRESSION")
    print("=" * 60)

    # ------------------------------------------------
    # Build
    # ------------------------------------------------

    build_command = [
        "verilator",
        "--binary",
        "--timing",
        "--Wall",
        "-Wno-UNUSEDSIGNAL",
        "--trace",
    ]

    build_command += RTL
    build_command += TESTBENCH
    build_command += [
        "--top-module",
        "riscv_cpu_tb"
    ]

    return_code, output = run_command(
        build_command,
        "BUILD"
    )

    if return_code != 0:
        print("BUILD FAILED")
        sys.exit(1)

    # ------------------------------------------------
    # Simulation
    # ------------------------------------------------

    return_code, output = run_command(
        ["./obj_dir/Vriscv_cpu_tb"],
        "SIMULATION"
    )

    if return_code != 0:
        print("SIMULATION FAILED")
        sys.exit(1)

    # ------------------------------------------------
    # Test result
    # ------------------------------------------------

    if "RISC-V CPU TEST PASSED" not in output:
        print("FUNCTIONAL VERIFICATION FAILED")
        sys.exit(1)

    # ------------------------------------------------
    # Assertion result
    # ------------------------------------------------

    if "ASSERTION FAILED" in output:
        print("ASSERTION VERIFICATION FAILED")
        sys.exit(1)

    # ------------------------------------------------
    # Synthesis
    # ------------------------------------------------

    return_code, output = run_command(
        ["yosys", "scripts/synth.ys"],
        "SYNTHESIS"
    )

    if return_code != 0:
        print("SYNTHESIS FAILED")
        sys.exit(1)

    print()
    print("=" * 60)
    print("             REGRESSION PASSED")
    print("=" * 60)
    print("Functional tests : PASS")
    print("Assertions       : PASS")
    print("=" * 60)


if __name__ == "__main__":
    main()
