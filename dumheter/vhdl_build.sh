#!/bin/bash

UNIT="stackmachine2"

mkdir -p ../build/
cd ..
ghdl analyze   --std=08 --workdir=build src/mypkg.vhd
ghdl analyze   --std=08 --workdir=build src/fa.vhd
ghdl analyze   --std=08 --workdir=build src/adder.vhd
ghdl analyze   --std=08 --workdir=build src/stack.vhd
ghdl analyze   --std=08 --workdir=build src/imem.vhd
ghdl analyze   --std=08 --workdir=build src/memarray.vhd
ghdl analyze   --std=08 --workdir=build src/${UNIT}.vhd
ghdl analyze   --std=08 --workdir=build dumheter/${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=build ${UNIT}_tb