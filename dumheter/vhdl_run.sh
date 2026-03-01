#!/bin/bash

UNIT="stackmachine2"

cp pgm.mif ../build/pgm.mif
cd ..
ghdl run --std=08 --workdir=build ${UNIT}_tb
