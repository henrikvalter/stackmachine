#!/bin/bash

UNIT="stackmachine0"
PROGRAM="count_to_100.asm"

mkdir -p build/
python3 programs/assembler.py programs/${PROGRAM} build/pgm.mif
ghdl analyze   --std=08 --workdir=build src/mypkg.vhd
ghdl analyze   --std=08 --workdir=build src/fa.vhd
ghdl analyze   --std=08 --workdir=build src/adder.vhd
ghdl analyze   --std=08 --workdir=build src/stack.vhd
ghdl analyze   --std=08 --workdir=build src/imem.vhd
ghdl analyze   --std=08 --workdir=build src/${UNIT}.vhd
ghdl analyze   --std=08 --workdir=build tb/${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=build ${UNIT}_tb
ghdl run       --std=08 --workdir=build ${UNIT}_tb --vcd=build/wave.vcd
gtkwave build/wave.vcd
rm ${UNIT}_tb
rm e~${UNIT}_tb.o
rm build/*
