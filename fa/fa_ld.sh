#!/bin/bash

UNIT="fa"

mkdir -p build
ghdl analyze   --std=08 --workdir=build ${UNIT}.vhd -o build/fa
ghdl analyze   --std=08 --workdir=build ${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=build ${UNIT}
ghdl elaborate --std=08 --workdir=build ${UNIT}_tb
ghdl run       --std=08 --workdir=build ${UNIT}_tb --vcd=build/wave.vcd
gtkwave build/wave.vcd
