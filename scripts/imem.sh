#!/bin/bash

UNIT="imem"

BUILDDIR="build"
mkdir -p ${BUILDDIR}

ghdl analyze   --std=08 --workdir=${BUILDDIR} src/mypkg.vhd 
ghdl analyze   --std=08 --workdir=${BUILDDIR} src/${UNIT}.vhd
ghdl analyze   --std=08 --workdir=${BUILDDIR} tb/${UNIT}_tb.vhd
ghdl elaborate --std=08 --workdir=${BUILDDIR} -O0 ${UNIT}_tb 
ghdl run       --std=08 --workdir=${BUILDDIR} ${UNIT}_tb --wave=build/wave.ghw
gtkwave ${BUILDDIR}/wave.ghw
rm ${UNIT}_tb
rm e~${UNIT}_tb.o
rm build/*
