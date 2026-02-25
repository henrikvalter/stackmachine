#!/bin/bash

UNIT="imem"
PROGRAM="iprint.asm"

mkdir -p build/

python3 programs/assembler.py programs/${PROGRAM} build/pgm.mif
ghdl analyze   --std=08 --workdir=build src/mypkg.vhd
ghdl analyze   --std=08 --workdir=build src/${UNIT}.vhd
ghdl analyze   --std=08 --workdir=build tb/${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=build -O0 ${UNIT}_tb
ghdl run       --std=08 --workdir=build ${UNIT}_tb --wave=build/wave.ghw
gtkwave build/wave.ghw
rm ${UNIT}_tb
rm e~${UNIT}_tb.o
rm build/*
