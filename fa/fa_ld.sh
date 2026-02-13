#!/bin/bash

UNIT="fa"

mkdir -p build
ghdl analyze   --std=08 --workdir=build ${UNIT}.vhd
ghdl analyze   --std=08 --workdir=build ${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=build ${UNIT}_tb
ghdl run       --std=08 --workdir=build ${UNIT}_tb --vcd=build/wave.vcd
gtkwave build/wave.vcd
rm ${UNIT}_tb
rm e~${UNIT}_tb.o
