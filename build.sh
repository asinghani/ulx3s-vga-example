#!/bin/sh

rm -r build || true

mkdir build

yosys  -p 'read_verilog -sv top.sv; synth_ecp5 -json build/synthesis.json -top top'

nextpnr-ecp5 --12k --json build/synthesis.json --lpf constraints.lpf --textcfg build/pnr_out.config

ecppack --compress build/pnr_out.config build/bitstream.bit
