# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_dds_custom_phase(dut):
    dut._log.info("Start DDS test")

    # start the clock: 66 MHz = ~15.15 ns period
    clock = Clock(dut.clk, 15, units="ns")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    dut._log.info("Test project behavior")

    # set phase increment to 2
    dut.ui_in.value = 2

    # trigger frequency load
    dut.uio_in.value = 0b00000001  # set uio_in[0] = 1
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0b00000000  # clear trigger
    await ClockCycles(dut.clk, 2)

    # wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # observe outputs over time
    dut._log.info("Observing DDS output...")
    for i in range(200):
        await ClockCycles(dut.clk, 1)
        amp = dut.uo_out.value.integer
        dut._log.info(f"Cycle {i}: amplitude = {amp}")
