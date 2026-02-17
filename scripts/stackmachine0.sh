#!/bin/bash

UNIT="stackmachine0"

BUILDDIR="build"
mkdir -p ${BUILDDIR}

ghdl analyze   --std=08 --workdir=${BUILDDIR} src/mypkg.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} src/fa.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} src/adder.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} src/stack.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} src/imem.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} src/${UNIT}.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} tb/${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=${BUILDDIR} ${UNIT}_tb
ghdl run       --std=08 --workdir=${BUILDDIR} ${UNIT}_tb --vcd=${BUILDDIR}/wave.vcd
gtkwave ${BUILDDIR}/wave.vcd
rm ${UNIT}_tb
rm e~${UNIT}_tb.o
rm build/*
