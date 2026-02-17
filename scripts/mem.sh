#!/bin/bash

UNIT="mem"

BUILDDIR="build"
mkdir -p ${BUILDDIR}

ghdl analyze   --std=08 --workdir=${BUILDDIR} src/mypkg.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} src/${UNIT}.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} tb/${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=${BUILDDIR} ${UNIT}_tb
ghdl run       --std=08 --workdir=${BUILDDIR} ${UNIT}_tb --vcd=${BUILDDIR}/wave.vcd
gtkwave ${BUILDDIR}/wave.vcd
rm ${UNIT}_tb
rm e~${UNIT}_tb.o
