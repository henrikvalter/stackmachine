#!/bin/bash

source pick_the_right_machine.sh

cp pgm.mif ../build/pgm.mif
cd ..
ghdl run --std=08 --workdir=build ${UNIT}_tb
